import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trade_match/models/barter_item.dart';
import 'package:trade_match/models/item.dart';
import 'package:trade_match/profile/profile.dart';
import 'package:trade_match/screens/trade_offer_page.dart';
import 'package:trade_match/services/supabase_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Phase 3: Performance
import 'package:trade_match/theme.dart';

final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

class ItemDetailPage extends StatefulWidget {
  final BarterItem item;

  const ItemDetailPage({super.key, required this.item});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLiking = false;

  void _handleShare() {
    final shareText = 'Check out this item on BarterSwap: ${widget.item.title}';
    Share.share(shareText, subject: widget.item.title);
  }

  Future<void> _handleLike() async {
    if (_isLiking) return;

    setState(() {
      _isLiking = true;
    });

    try {
      // Get current user's items to find an item to use for swiping
      final userItemsData = await _supabaseService.getUserItems();
      final userItems = userItemsData.map((data) => Item.fromJson(data)).toList();
      
      if (userItems.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need to create an item first before liking others'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          _isLiking = false;
        });
        return;
      }

      // Use the first available item as the swiper item
      final swiperItemId = userItems.first.id;

      // Call swipe API with 'like' action
      await _supabaseService.swipe(swiperItemId, widget.item.id, 'like');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Liked ${widget.item.title}!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'View Matches',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/matches');
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to like item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLiking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _handleShare,
                tooltip: 'Share',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: PageView.builder(
                itemCount: widget.item.images.isNotEmpty ? widget.item.images.length : 1,
                itemBuilder: (context, index) {
                  if (widget.item.images.isEmpty) {
                    return const Center(child: Icon(Icons.image_not_supported));
                  }
                  return CachedNetworkImage(
                    imageUrl: widget.item.images[index].imageUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: 1200, // Full-size detail images
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.broken_image, size: 50),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Item details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Value
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.title,
                          style: AppTextStyles.heading2,
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (widget.item.estimatedValue != null)
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppRadius.chip),
                            ),
                            child: Text(
                              currencyFormatter.format(widget.item.estimatedValue),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Owner info
                  InkWell(
                    onTap: () {
                      // TODO: Navigate to specific user profile
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: widget.item.user.profilePictureUrl != null
                              ? NetworkImage(widget.item.user.profilePictureUrl!)
                              : null,
                          child: widget.item.user.profilePictureUrl == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.user.name,
                              style: AppTextStyles.labelBold,
                            ),
                            Text(
                              widget.item.user.createdAt != null
                                  ? 'Joined ${DateFormat.yMMMd().format(widget.item.user.createdAt!)}'
                                  : 'Member',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (widget.item.user.rating != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppRadius.button),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.item.user.rating!.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Description',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.item.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Looking for
                  const Text(
                    'Looking to Trade For',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 8),
                  if (widget.item.wants.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.item.wants.map((want) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                        ),
                        child: Text(want.category?.name ?? 'Unknown'),
                      )).toList(),
                    )
                  else
                    Text(
                      'Open to offers',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  const SizedBox(height: 24),

                  // Location
                  const Text(
                    'Location',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.item.locationCity,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16).copyWith(top: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLiking ? null : _handleLike,
                icon: _isLiking
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.favorite_border),
                label: Text(_isLiking ? 'Liking...' : 'Like'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side: BorderSide(color: Theme.of(context).colorScheme.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/trade_offer', arguments: widget.item);
                },
                icon: const Icon(Icons.swap_horiz, color: Colors.white),
                label: const Text('Offer Trade'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                ).copyWith(
                  elevation: WidgetStateProperty.all(0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}