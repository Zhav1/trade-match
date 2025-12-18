import 'package:flutter/material.dart';
import 'package:trade_match/chat/location_picker_modal.dart';
import 'package:trade_match/chat/location_message_bubble.dart';

import 'package:trade_match/widget_Template/loading_overlay.dart';
import 'package:trade_match/services/supabase_service.dart';
import 'package:trade_match/services/notification_service.dart';
import 'package:trade_match/widgets/trade_complete_dialog.dart';
import 'package:trade_match/screens/submit_review_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatDetailPage extends StatefulWidget {
  final String matchId;
  final String otherUserName;
  final String? otherUserImage;

  const ChatDetailPage({
    super.key,
    required this.matchId,
    required this.otherUserName,
    this.otherUserImage,
  });

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SupabaseService _supabaseService = SupabaseService();
  List<dynamic> messages = [];
  String? currentUserId;
  bool isLoading = false;
  Map<String, dynamic>? swapData;
  RealtimeChannel? _messageChannel;
  RealtimeChannel? _notificationChannel;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _loadSwapData();
    // Use Supabase user ID directly
    currentUserId = _supabaseService.userId;
    _subscribeToMessages();
    _subscribeToNotifications();
  }

  void _subscribeToNotifications() {
    try {
      _notificationChannel = _supabaseService.subscribeToNotifications((
        notification,
      ) {
        // Check if this is a location_accepted notification for this swap
        if (notification['type'] == 'location_accepted' && mounted) {
          final notificationSwapId = notification['data']?['swap_id']
              ?.toString();
          if (notificationSwapId == widget.matchId) {
            // Show local notification to sender
            NotificationService().showNotification(
              id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
              title: 'Location Accepted! 📍',
              body: '${widget.otherUserName} agreed to your meeting location',
              payload: widget.matchId,
            );
            // Reload swap data to update UI
            _loadSwapData();
          }
        }
      });
    } catch (e) {
      print('Error subscribing to notifications: $e');
    }
  }

  Future<void> _loadSwapData() async {
    try {
      final swapId = int.tryParse(widget.matchId);
      if (swapId == null) return;

      final data = await _supabaseService.getSwap(swapId);
      if (mounted) {
        setState(() {
          swapData = data;
        });
      }
    } catch (e) {
      print('Error loading swap data: $e');
    }
  }

  Future<void> _confirmTrade() async {
    try {
      setState(() => isLoading = true);

      final swapId = int.tryParse(widget.matchId);
      if (swapId == null) throw Exception('Invalid swap ID');

      final response = await _supabaseService.confirmTrade(swapId);

      // Reload swap data to get updated confirmation status
      await _loadSwapData();

      if (mounted) {
        setState(() => isLoading = false);

        // Check if both users have confirmed
        final bothConfirmed =
            swapData?['item_a_owner_confirmed'] == true &&
            swapData?['item_b_owner_confirmed'] == true;

        if (bothConfirmed) {
          // Show trade complete dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => TradeCompleteDialog(
              onLeaveReview: () {
                Navigator.of(context).pop();
                // Navigate to review page - determine other user
                final String? userAId = swapData?['user_a_id']?.toString();
                final String? userBId = swapData?['user_b_id']?.toString();
                final String? otherUserId = (userAId == currentUserId)
                    ? userBId
                    : userAId;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubmitReviewPage(
                      swapId: swapId,
                      reviewedUserId: otherUserId,
                      reviewedUserName: widget.otherUserName,
                    ),
                  ),
                );
              },
              onClose: () => Navigator.of(context).pop(),
            ),
          );
        } else {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trade confirmed! Waiting for partner...'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error confirming trade: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _subscribeToMessages() {
    final swapId = int.tryParse(widget.matchId);
    if (swapId == null) {
      print('Invalid swap ID for realtime subscription');
      return;
    }

    try {
      _messageChannel = Supabase.instance.client
          .channel('messages:swap_$swapId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'messages',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'swap_id',
              value: swapId,
            ),
            callback: (payload) {
              if (mounted) {
                setState(() {
                  // Check if message already exists to avoid duplicates
                  final newMessage = payload.newRecord;
                  final exists = messages.any(
                    (m) => m['id'] == newMessage['id'],
                  );
                  if (!exists) {
                    messages.add(newMessage);
                    _scrollToBottom();
                  }
                });
              }
            },
          )
          .subscribe();
      print('✅ Subscribed to messages for swap $swapId');
    } catch (e) {
      print('❌ Error subscribing to messages: $e');
    }
  }

  Future<void> _loadMessages() async {
    if (mounted) {
      setState(() => isLoading = true);
    }

    try {
      final swapId = int.tryParse(widget.matchId);
      if (swapId == null) {
        throw Exception('Invalid swap ID');
      }

      final messagesData = await _supabaseService.getMessages(swapId);

      // Mark messages as read when viewing the chat
      await _supabaseService.markMessagesAsRead(swapId);

      if (mounted) {
        setState(() {
          messages = messagesData;
          isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      print('Error loading messages: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage({
    required String content,
    String type = 'text',
    Map<String, dynamic>? locationData,
  }) async {
    if (content.isEmpty) return;

    try {
      final swapId = int.tryParse(widget.matchId);
      if (swapId == null) {
        throw Exception('Invalid swap ID');
      }

      print('📤 Sending message to swap $swapId: $content');

      // Send message with optional location data
      await _supabaseService.sendMessage(
        swapId,
        content,
        type: type,
        locationLat: locationData?['lat']?.toDouble(),
        locationLon: locationData?['lng']?.toDouble(),
        locationName: locationData?['location_name'],
        locationAddress: locationData?['location_address'],
      );

      print('✅ Message sent successfully');
      _messageController.clear();
      await _loadMessages();
    } catch (e, stackTrace) {
      print('❌ Error sending message: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sending message: $e')));
      }
    }
  }

  Future<void> _showLocationPicker() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => LocationPickerModal(
        onLocationPicked: (name, address, lat, lng) {
          _sendMessage(
            content: 'Meeting location: $name',
            type: 'location',
            locationData: {
              'lat': lat,
              'lng': lng,
              'location_name': name,
              'location_address': address,
            },
          );
        },
      ),
    );
  }

  Future<void> _agreeToLocation(String messageId) async {
    try {
      final swapId = int.tryParse(widget.matchId);
      if (swapId == null) throw Exception('Invalid swap ID');

      // Use Supabase service instead of legacy HTTP
      await _supabaseService.acceptLocation(swapId);
      await _loadSwapData(); // Reload to get updated status
      await _loadMessages();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Location accepted!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error agreeing to location: $e')),
        );
      }
    }
  }

  Widget _buildMessage(dynamic message) {
    // Supabase uses 'sender_user_id', old API used 'user_id'
    final senderId =
        message['sender_user_id']?.toString() ?? message['user_id']?.toString();
    final bool isMe = senderId == currentUserId;
    final String messageType = message['type'] ?? 'text';
    final String messageContent =
        message['message_text'] ?? message['content'] ?? '';

    switch (messageType) {
      case 'location':
        // Use swap-level status for agreement tracking
        final isLocationAgreed = swapData?['status'] == 'location_agreed';
        final isLocationSuggested = swapData?['status'] == 'location_suggested';
        return LocationMessageBubble(
          locationName: message['location_name'] ?? '',
          address: message['location_address'] ?? '',
          latitude: message['location_lat']?.toDouble(),
          longitude: message['location_lon']?.toDouble(),
          isMe: isMe,
          isAgreed: isLocationAgreed,
          isOtherUserAgreed: isLocationAgreed,
          onAgree: !isMe && isLocationSuggested
              ? () => _agreeToLocation(message['id'].toString())
              : null,
        );

      case 'location_agreement':
        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            messageContent,
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        );

      default:
        return Container(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(messageContent),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Row(
          children: [
            if (widget.otherUserImage != null &&
                widget.otherUserImage!.isNotEmpty)
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[200],
                backgroundImage: widget.otherUserImage!.startsWith('http')
                    ? NetworkImage(widget.otherUserImage!)
                    : AssetImage('assets/images/${widget.otherUserImage}')
                          as ImageProvider,
              )
            else
              CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.2),
                child: Text(
                  widget.otherUserName.isNotEmpty
                      ? widget.otherUserName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName,
                  style: const TextStyle(color: Colors.black87),
                ),
                Text(
                  'Tap for trade details',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: isLoading,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    // Display messages in natural order (oldest first, newest last at bottom)
                    return AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      child: _buildMessage(messages[index]),
                    );
                  },
                ),
              ),
              // Confirm Trade button above input (not floating)
              if (_shouldShowConfirmTrade())
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.green.shade50,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _confirmTrade,
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text(
                      'Confirm Trade',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTapDown: (_) => setState(() {}),
                      onTapUp: (_) => setState(() {}),
                      onTap: _showLocationPicker,
                      child: AnimatedScale(
                        scale: 1.0,
                        duration: Duration(milliseconds: 100),
                        child: Icon(
                          Icons.location_on,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    GestureDetector(
                      onTapDown: (_) => setState(() {}),
                      onTapUp: (_) => setState(() {}),
                      onTap: () {
                        if (_messageController.text.trim().isNotEmpty) {
                          _sendMessage(content: _messageController.text.trim());
                        }
                      },
                      child: AnimatedScale(
                        scale: 1.0,
                        duration: Duration(milliseconds: 100),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.send, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Check if Confirm Trade button should be shown
  bool _shouldShowConfirmTrade() {
    if (swapData == null) return false;

    final status = swapData?['status'];
    final userAId = swapData?['user_a_id'];
    final isUserA = userAId == currentUserId;
    final bool userConfirmed = isUserA
        ? (swapData?['item_a_owner_confirmed'] == true)
        : (swapData?['item_b_owner_confirmed'] == true);

    // Only show if:
    // 1. Status is active or location_agreed
    // 2. User hasn't confirmed yet
    // 3. Trade not complete
    if (status == 'trade_complete' || userConfirmed) {
      return false;
    }

    if (!['active', 'location_agreed'].contains(status)) {
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    _messageChannel?.unsubscribe();
    _notificationChannel?.unsubscribe();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
