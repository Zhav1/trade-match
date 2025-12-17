import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trade_match/models/category.dart';
import 'package:trade_match/models/barter_item.dart';
import 'package:trade_match/models/item.dart';
import 'package:trade_match/services/supabase_service.dart';
import 'package:trade_match/services/permission_service.dart'; // Technical Implementation: Permissions
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Phase 3: Performance
import 'package:trade_match/theme.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with SingleTickerProviderStateMixin {
  final SupabaseService _supabaseService = SupabaseService();
  final AppinioSwiperController _swiperController = AppinioSwiperController();
  late AnimationController _likeController;
  late Animation<double> _likeScale;
  bool _showLike = false;
  late Future<List<BarterItem>> _itemsFuture;
  
  // Dynamic user data
  int? _currentUserItemId;
  String _userLocation = 'Loading...';
  double? _userLat;
  double? _userLon;
  bool _isLoadingUserData = true;
  bool _hasLocationPermission = false; // Track location permission status

  @override
  void initState() {
    super.initState();
    _itemsFuture = _loadExploreItems();
    _likeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _likeScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2).chain(CurveTween(curve: Curves.elasticOut)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.5).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
    ]).animate(_likeController);

    _likeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showLike = false);
        _likeController.reset();
      }
    });
    
    _loadUserData();
  }
  
  @override
  void dispose() {
    _likeController.dispose(); // CRITICAL FIX: Prevent memory leak
    super.dispose();
  }
  
  /// Load explore items from Supabase
  Future<List<BarterItem>> _loadExploreItems() async {
    try {
      final itemsData = await _supabaseService.getExploreFeed(limit: 20);
      return itemsData.map((data) => BarterItem.fromJson(data)).toList();
    } catch (e) {
      print('Error loading explore items: $e');
      rethrow;
    }
  }
  
  /// Load user's data for dynamic item selection and location
  Future<void> _loadUserData() async {
    try {
      // PHASE 1: Request location permission (lazy request pattern)
      if (mounted) {
        _hasLocationPermission = await PermissionService.requestLocationPermission(context);
      }
      
      // Get user profile for location
      final userData = await _supabaseService.getCurrentUserProfile();
      
      // Get user's items to select one for offering
      final userItemsData = await _supabaseService.getUserItems();
      final userItems = userItemsData.map((data) => Item.fromJson(data)).toList();
      
      if (mounted && userData != null) {
        setState(() {
          _userLocation = userData['default_location_city'] ?? 'Unknown';
          
          // Only set coordinates if permission granted
          if (_hasLocationPermission) {
            _userLat = userData['default_lat'] != null ? double.tryParse(userData['default_lat'].toString()) : null;
            _userLon = userData['default_lon'] != null ? double.tryParse(userData['default_lon'].toString()) : null;
          } else {
            // Graceful degradation: no coordinates if permission denied
            _userLat = null;
            _userLon = null;
          }
          
          // Select user's first active item, or null if none
          if (userItems.isNotEmpty) {
            final activeItems = userItems.where((item) => item.status == 'active').toList();
            _currentUserItemId = activeItems.isNotEmpty ? activeItems.first.id : userItems.first.id;
          }
          
          _isLoadingUserData = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _userLocation = 'Unknown';
          _isLoadingUserData = false;
        });
      }
    }
  }
  
  /// Calculate distance between user and item using Haversine formula
  /// Returns null if location permission denied (graceful degradation)
  String? _calculateDistance(BarterItem item) {
    // Graceful degradation: Return null if no permission or coordinates
    if (!_hasLocationPermission || _userLat == null || _userLon == null) {
      return null;
    }
    
    try {
      final distanceInMeters = Geolocator.distanceBetween(
        _userLat!,
        _userLon!,
        item.locationLat,
        item.locationLon,
      );
      
      final distanceInKm = distanceInMeters / 1000;
      
      if (distanceInKm < 1) {
        return '${distanceInMeters.toStringAsFixed(0)} m';
      }
      return '${distanceInKm.toStringAsFixed(1)} km';
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: const CircleAvatar(radius: 22, backgroundImage: AssetImage('assets/images/profile.jpg')),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Discover', style: AppTextStyles.heading2),
                            const SizedBox(height: 2),
                            Text('Nearby • $_userLocation', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      IconButton(onPressed: () => Navigator.pushNamed(context, '/notifications'), icon: Icon(Icons.notifications_outlined, color: AppColors.textSecondary)),
                      const SizedBox(width: AppSpacing.xs),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10),
                        ),
                        onPressed: () => Navigator.pushNamed(context, '/search'),
                        child: const Icon(Icons.filter_list, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Card stack / swiper
                Expanded(
                  child: FutureBuilder<List<BarterItem>>(
                    future: _itemsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildShimmer();
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No items found.'));
                      } else {
                        final items = snapshot.data!;
                        return AppinioSwiper(
                          controller: _swiperController,
                          cardCount: items.length,
                          loop: true,
                          onSwipeEnd: (previousIndex, targetIndex, direction) {
                            final int idx = (previousIndex is int) ? previousIndex : int.parse(previousIndex.toString());
                            final item = items[idx];
                            
                            // Only proceed if user has selected an item to offer
                            if (_currentUserItemId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please add an item to start trading')),
                              );
                              return;
                            }
                            
                            if (direction == AxisDirection.right) {
                              _supabaseService.swipe(_currentUserItemId!, item.id, 'like');
                            } else if (direction == AxisDirection.left) {
                              _supabaseService.swipe(_currentUserItemId!, item.id, 'dislike');
                            }
                          },
                          cardBuilder: (context, index) {
                            final int idx = (index is int) ? index : int.parse(index.toString());
                            return _buildCard(items[idx]);
                          },
                        );
                      }
                    },
                  ),
                ),

                // Action Row
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _smallAction(icon: Icons.close, color: Colors.red[400]!, onTap: () => _swiperController.swipeLeft()),
                      _bigAction(icon: Icons.favorite, color: primary, onTap: () {
                        setState(() => _showLike = true);
                        _likeController.forward(from: 0);
                        _swiperController.swipeRight();
                      }),
                      _smallAction(icon: Icons.star, color: Colors.amber, onTap: () => _swiperController.swipeUp()),
                    ],
                  ),
                ),
              ],
            ),

            // Heart/like animation overlay
            if (_showLike)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _likeController,
                      builder: (context, child) {
                        final scale = _likeScale.value;
                        final opacity = (_likeController.value > 0.1) ? (1.0 - _likeController.value * 0.8) : 1.0;
                        return Opacity(
                          opacity: opacity,
                          child: Transform.scale(scale: scale, child: child),
                        );
                      },
                      child: Icon(Icons.favorite, color: primary, size: 120),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Center(
      child: SizedBox(
        width: ResponsiveUtils.getCardWidth(
          context,
          mobilePercentage: 0.9,
          tabletPercentage: 0.75,
          desktopPercentage: 0.6,
        ),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Image placeholder
                Expanded(
                  child: Container(
                    color: Colors.white,
                  ),
                ),
                // Details placeholder
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 24,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 16,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _likeController.dispose();
    _swiperController.dispose();
    super.dispose();
  }

  Widget _buildCard(BarterItem item) {
    final String? distance = _calculateDistance(item);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (item.images.isNotEmpty)
              CachedNetworkImage(
                imageUrl: item.images.first.imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 1200, // Optimize memory for card-sized images
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
                ),
              )
            else
              const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50)),
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.68), borderRadius: BorderRadius.circular(AppRadius.button)),
                    child: Text(
                      '${item.title} • ${item.condition}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        shadows: [Shadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 1))],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundImage: item.user.profilePictureUrl != null
                            ? NetworkImage(item.user.profilePictureUrl!)
                            : const AssetImage('assets/images/pp-1.png') as ImageProvider,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Offered by ${item.user.name}', style: const TextStyle(color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
                      const Spacer(),
                      // Graceful degradation: Only show distance if location permission granted
                      if (distance != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(10)),
                          child: Row(children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(distance, style: const TextStyle(color: Colors.white, shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1))]))
                          ]),
                        ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _smallAction({required IconData icon, required Color color, required VoidCallback onTap}) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.2),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        splashColor: color.withOpacity(0.12),
        child: SizedBox(
          width: 64,
          height: 64,
          child: Icon(icon, color: color, size: 30),
        ),
      ),
    );
  }

  Widget _bigAction({required IconData icon, required Color color, required VoidCallback onTap}) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      elevation: 6,
      shadowColor: color.withOpacity(0.4),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        splashColor: Colors.white.withOpacity(0.2),
        child: SizedBox(
          width: 84,
          height: 84,
          child: Icon(icon, color: Colors.white, size: 38),
        ),
      ),
    );
  }
}
