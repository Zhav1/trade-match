import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trade_match/models/category.dart';
import 'package:trade_match/models/barter_item.dart'; // Added import
import 'package:trade_match/services/api_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:appinio_swiper/appinio_swiper.dart';

import 'package:shimmer/shimmer.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final AppinioSwiperController _swiperController = AppinioSwiperController();
  late AnimationController _likeController;
  late Animation<double> _likeScale;
  bool _showLike = false;
  late Future<List<BarterItem>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _apiService.getExploreItems();
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
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    // A placeholder for the item the user is offering.
    // In a real app, this would be selected by the user.
    const int _currentUserItemId = 1;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: const CircleAvatar(radius: 22, backgroundImage: AssetImage('assets/images/profile.jpg')),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Discover', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            SizedBox(height: 2),
                            Text('Nearby • Jakarta', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ),
                      IconButton(onPressed: () => Navigator.pushNamed(context, '/notifications'), icon: const Icon(Icons.notifications_outlined, color: Colors.grey)),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        onPressed: () => Navigator.pushNamed(context, '/search'),
                        child: const Icon(Icons.filter_list, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Card stack / swiper
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                              final item = items[previousIndex];
                              if (direction == AxisDirection.right) {
                                _apiService.swipe(_currentUserItemId, item.id, 'like');
                              } else if (direction == AxisDirection.left) {
                                _apiService.swipe(_currentUserItemId, item.id, 'dislike');
                              }
                            },
                            cardBuilder: (context, index) => _buildCard(items[index]),
                          );
                        }
                      },
                    ),
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
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
    // Placeholder for distance calculation
    const String distance = "2 km";

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (item.images.isNotEmpty)
              Image.network(
                item.images.first.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
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
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.68), borderRadius: BorderRadius.circular(12)),
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
                      const SizedBox(width: 8),
                      Text('Offered by ${item.user.name}', style: const TextStyle(color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(10)),
                        child: Row(children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(distance, style: const TextStyle(color: Colors.white, shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1))]))
                        ]),
                      )
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
      color: Colors.white,
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
