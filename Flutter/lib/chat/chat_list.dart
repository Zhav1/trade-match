import 'package:flutter/material.dart';
import 'package:trade_match/chat/chat_detail.dart';
import 'package:trade_match/models/barter_item.dart';
import 'package:trade_match/models/user.dart';
import 'package:trade_match/services/api_service.dart';
import 'package:trade_match/services/constants.dart';
import 'package:trade_match/theme.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<BarterMatch> _swaps = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSwaps();
  }

  Future<void> _loadSwaps() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final swaps = await ApiService().getSwaps();
      if (mounted) {
        setState(() {
          _swaps = swaps;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// Determine the "other user" in a swap based on current user
  User _getOtherUser(BarterMatch swap) {
    // Compare current user ID with item owners
    final currentUserId = int.tryParse(AUTH_USER_ID) ?? 0;
    if (swap.itemA.user.id == currentUserId) {
      return swap.itemB.user;
    }
    return swap.itemA.user;
  }

  /// Get other user's item for display
  BarterItem _getOtherItem(BarterMatch swap) {
    final currentUserId = int.tryParse(AUTH_USER_ID) ?? 0;
    if (swap.itemA.user.id == currentUserId) {
      return swap.itemB;
    }
    return swap.itemA;
  }

  /// Format time ago
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  /// Get message preview text
  String _getMessagePreview(BarterMatch swap) {
    if (swap.latestMessage == null) {
      return 'Start chatting about the trade...';
    }
    
    final msg = swap.latestMessage!;
    switch (msg.type) {
      case 'location':
        return '📍 Meeting location suggested';
      case 'location_agreement':
        return '✅ Location agreed!';
      default:
        return msg.messageText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    final Color background = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: ResponsiveUtils.getResponsivePadding(
            context,
            mobile: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
            tablet: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Messages",
                    style: AppTextStyles.heading1.copyWith(
                      color: Color(0xFF441606),
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 3),
                          blurRadius: 5,
                        )
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/filter.png',
                        width: 26,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search messages...",
                    hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to new conversation or matches
        },
        backgroundColor: primary,
        child: const Icon(Icons.message_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Failed to load conversations',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadSwaps,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_swaps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When you match with someone,\nyour chat will appear here',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSwaps,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: _swaps.length,
        itemBuilder: (context, index) {
          final swap = _swaps[index];
          final otherUser = _getOtherUser(swap);
          final otherItem = _getOtherItem(swap);
          
          return _conversationTile(
            context,
            swap.id.toString(),
            otherUser.name,
            otherUser.profilePictureUrl,
            otherItem.title,
            _getMessagePreview(swap),
            _formatTimeAgo(swap.updatedAt),
          );
        },
      ),
    );
  }

  Widget _conversationTile(
    BuildContext context,
    String swapId,
    String name,
    String? imageUrl,
    String itemTitle,
    String preview,
    String time,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: Colors.grey[200],
        backgroundImage: imageUrl != null && imageUrl.isNotEmpty
            ? NetworkImage(imageUrl)
            : null,
        child: imageUrl == null || imageUrl.isEmpty
            ? Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.labelBold,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            time,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Re: $itemTitle',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            preview,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatDetailPage(
              matchId: swapId,
              otherUserName: name,
              otherUserImage: imageUrl,
            ),
          ),
        );
      },
    );
  }
}