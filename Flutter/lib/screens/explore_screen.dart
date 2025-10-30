import 'package:flutter/material.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import '../models/barter_item.dart';

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

  final List<BarterItem> items = [
    BarterItem(
      namaBarang: "Labubu",
      kondisi: "Baik",
      namaUser: "Rudi",
      jarak: "2 km",
      imageUrl: "assets/images/barang-1.jpg",
    ),
    BarterItem(
      namaBarang: "kipas portable",
      kondisi: "Seperti Baru",
      namaUser: "Andi",
      jarak: "4 km",
      imageUrl: "assets/images/barang-2.jpg",
    ),
    BarterItem(
      namaBarang: "smartwatch",
      kondisi: "Mulus",
      namaUser: "Budi",
      jarak: "1 km",
      imageUrl: "assets/images/barang-3.jpg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFFFD7E14);

    // Build a Stack so we can overlay the heart animation when liking
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header: avatar, title, filter/search
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
                    child: items.isEmpty
                        ? const Center(child: Text('Tidak ada barang untuk ditampilkan 😅', style: TextStyle(color: Colors.grey)))
                        : AppinioSwiper(controller: _swiperController, cardCount: items.length, loop: true, cardBuilder: (context, index) => _buildCard(items[index])),
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
                      _smallAction(icon: Icons.star, color: Colors.purple[300]!, onTap: () => _swiperController.swipeUp()),
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

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // hide after a short delay
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
            Image.asset(item.imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image))),
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.45), borderRadius: BorderRadius.circular(12)),
                    child: Text('${item.namaBarang} • ${item.kondisi}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(radius: 14, backgroundImage: AssetImage('assets/images/pp-1.png')),
                      const SizedBox(width: 8),
                      Text('Ditawarkan oleh ${item.namaUser}', style: const TextStyle(color: Colors.white70)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.45), borderRadius: BorderRadius.circular(10)),
                        child: Row(children: [const Icon(Icons.location_on, size: 14, color: Colors.white), const SizedBox(width: 4), Text(item.jarak, style: const TextStyle(color: Colors.white))]),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)]),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }

  Widget _bigAction({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12)]),
        child: Icon(icon, color: Colors.white, size: 38),
      ),
    );
  }
}
