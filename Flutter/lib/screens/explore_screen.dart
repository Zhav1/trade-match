import 'package:flutter/material.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import '../models/barter_item.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final AppinioSwiperController _swiperController = AppinioSwiperController();

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.grey[700]),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Discover",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            Text(
              "Chicago, IL",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded,
                color: Colors.orange, size: 30),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            // 🔒 Aman dari divide-by-zero
            child: items.isEmpty
                ? const Center(
              child: Text(
                "Tidak ada barang untuk ditampilkan 😅",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
                : AppinioSwiper(
              controller: _swiperController,
              cardCount: items.length,
              loop: true,
              cardBuilder: (BuildContext context, int index) {
                return _buildBarterCard(items[index]);
              },
              onSwipeEnd: (previousIndex, targetIndex, activity) {
                debugPrint(
                    "Swiped from $previousIndex to $targetIndex (${activity.runtimeType})");
              },
              onEnd: () {
                debugPrint("Semua kartu telah di-swipe!");
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  onPressed: () => _swiperController.swipeLeft(),
                  icon: Icons.close,
                  color: Colors.red[400]!,
                  size: 30,
                ),
                _buildActionButton(
                  onPressed: () => _swiperController.unswipe(),
                  icon: Icons.favorite,
                  color: Colors.orange,
                  size: 40,
                  isPrimary: true,
                ),
                _buildActionButton(
                  onPressed: () => _swiperController.swipeUp(),
                  icon: Icons.star,
                  color: Colors.purple[400]!,
                  size: 30,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarterCard(BarterItem item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey));
                },
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 25,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${item.namaBarang} (${item.kondisi})",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Ditawarkan oleh ${item.namaUser}",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 15,
              left: 15,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(item.jarak,
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
    double size = 30,
    bool isPrimary = false,
  }) {
    if (isPrimary) {
      return FloatingActionButton(
        heroTag: UniqueKey(),
        onPressed: onPressed,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white, size: 36),
      );
    }
    return FloatingActionButton(
      heroTag: UniqueKey(),
      onPressed: onPressed,
      backgroundColor: Colors.white,
      elevation: 5,
      child: Icon(icon, color: color, size: size),
    );
  }
}
