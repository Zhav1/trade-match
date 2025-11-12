import 'package:flutter/material.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:shimmer/shimmer.dart';
import '../models/barter_item.dart';
import '../services/api_service.dart'; // Import the ApiService

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with SingleTickerProviderStateMixin {
  final AppinioSwiperController _swiperController = AppinioSwiperController();
  late final AnimationController _likeController;
  late final Animation<double> _likeScale;
  bool _showLike = false;

  late Future<List<BarterItem>> _itemsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _itemsFuture = _apiService.getFeed(); // Fetch items from the API

    _likeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) setState(() => _showLike = false);
          });
        }
      });
    _likeScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.3).chain(CurveTween(curve: Curves.easeOutBack)), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 30),
    ]).animate(_likeController);
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

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
                      IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined, color: Colors.grey)),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        onPressed: () {},
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
                        _swiperController.unswipe();
                      }),
                      _smallAction(icon: Icons.star, color: primary, onTap: () => _swiperController.swipeUp()),
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
      child: Column(
        children: List.generate(3, (i) => Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          height: 320,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        )),
      ),
    );
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  Widget _buildCard(BarterItem item) {
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
            Image.network(item.imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image))),
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
                      '${item.namaBarang} • ${item.kondisi}',
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
                      const CircleAvatar(radius: 14, backgroundImage: AssetImage('assets/images/pp-1.png')),
                      const SizedBox(width: 8),
                      Text('Ditawarkan oleh ${item.namaUser}', style: const TextStyle(color: Colors.white70)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(10)),
                        child: Row(children: [const Icon(Icons.location_on, size: 14, color: Colors.white), const SizedBox(width: 4), Text(item.jarak, style: const TextStyle(color: Colors.white, shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1))]))]),
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
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 100),
          child: SizedBox(
            width: 64,
            height: 64,
            child: Icon(icon, color: color, size: 30),
          ),
        ),
      ),
    );
  }

  Widget _bigAction({required IconData icon, required Color color, required VoidCallback onTap}) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      elevation: 6,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        splashColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.12),
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 100),
          child: SizedBox(
            width: 84,
            height: 84,
            child: Icon(icon, color: Colors.white, size: 38),
          ),
        ),
      ),
    );
  }
}
