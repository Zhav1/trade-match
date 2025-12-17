import 'package:flutter/material.dart';
import 'package:trade_match/chat/location_picker_modal.dart';
import 'package:trade_match/chat/location_message_bubble.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:trade_match/widget_Template/loading_overlay.dart';
import 'package:trade_match/services/constants.dart';
import 'package:trade_match/services/supabase_service.dart';
import 'package:trade_match/widgets/trade_complete_dialog.dart';
import 'package:trade_match/screens/submit_review_page.dart';
import 'package:trade_match/models/barter_item.dart';
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

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _loadSwapData();
    // TODO: Wire this to your auth service. For local dev you can set
    // AUTH_USER_ID in `lib/services/constants.dart`.
    currentUserId = AUTH_USER_ID;
    _subscribeToMessages();
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
                // Navigate to review page with BarterMatch object
                if (swapData != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubmitReviewPage(
                        swap: BarterMatch.fromJson(swapData!),
                      ),
                    ),
                  );
                }
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
      final response = await http.get(
        Uri.parse('$API_BASE/api/swaps/${widget.matchId}/messages'),
        headers: {'Authorization': 'Bearer $AUTH_TOKEN'},
      );

      if (response.statusCode == 200 && mounted) {
        setState(() {
          messages = json.decode(response.body)['messages'];
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
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage({
    required String content,
    String type = 'text',
    Map<String, dynamic>? locationData,
  }) async {
    if (content.isEmpty) return;

    try {
      final Map<String, dynamic> body = {'content': content, 'type': type};

      if (locationData != null) {
        body.addAll(locationData);
      }

      final response = await http.post(
        Uri.parse('$API_BASE/api/swaps/${widget.matchId}/messages'),
        headers: {
          'Authorization': 'Bearer $AUTH_TOKEN',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        _messageController.clear();
        await _loadMessages();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending message: $e')));
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
      final response = await http.post(
        Uri.parse('$API_BASE/api/swaps/${widget.matchId}/accept-location'),
        headers: {
          'Authorization': 'Bearer $AUTH_TOKEN',
          'Content-Type': 'application/json',
        },
        body: json.encode({'message_id': messageId}),
      );

      if (response.statusCode == 200) {
        await _loadMessages();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error agreeing to location: $e')));
    }
  }

  Widget _buildMessage(dynamic message) {
    final bool isMe = message['user_id'].toString() == currentUserId;

    switch (message['type']) {
      case 'location':
        return LocationMessageBubble(
          locationName: message['location_name'],
          address: message['location_address'],
          isMe: isMe,
          isAgreed: isMe
              ? message['location_agreed_by_user_a'] ?? false
              : message['location_agreed_by_user_b'] ?? false,
          isOtherUserAgreed: isMe
              ? message['location_agreed_by_user_b'] ?? false
              : message['location_agreed_by_user_a'] ?? false,
          onAgree: !isMe && !(message['location_agreed_by_user_b'] ?? false)
              ? () => _agreeToLocation(message['id'].toString())
              : null,
        );

      case 'location_agreement':
        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            message['content'],
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
            child: Text(message['content']),
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
                  itemBuilder: (context, index) => AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: _buildMessage(messages[index]),
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
      floatingActionButton: _buildConfirmTradeFAB(),
    );
  }

  Widget? _buildConfirmTradeFAB() {
    if (swapData == null) return null;

    final status = swapData?['status'];
    final userAId = swapData?['user_a_id'];
    final isUserA = userAId == currentUserId;
    final userConfirmed = isUserA
        ? (swapData?['item_a_owner_confirmed'] == true)
        : (swapData?['item_b_owner_confirmed'] == true);

    // Only show if:
    // 1. Status is active or location_agreed
    // 2. User hasn't confirmed yet
    // 3. Trade not complete
    if (status == 'trade_complete' || userConfirmed) {
      return null;
    }

    if (!['active', 'location_agreed'].contains(status)) {
      return null;
    }

    return FloatingActionButton.extended(
      onPressed: isLoading ? null : _confirmTrade,
      icon: const Icon(Icons.check_circle),
      label: const Text('Confirm Trade'),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }

  @override
  void dispose() {
    _messageChannel?.unsubscribe();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
