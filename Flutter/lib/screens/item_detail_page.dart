import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trade_match/models/barter_item.dart';
import 'package:trade_match/profile/profile.dart';
import 'package:trade_match/screens/trade_offer_page.dart';

final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

class ItemDetailPage extends StatelessWidget {
  final BarterItem item;

  const ItemDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: PageView.builder(
                itemCount: item.images.isNotEmpty ? item.images.length : 1,
                itemBuilder: (context, index) {
                  if (item.images.isEmpty) {
                    return const Center(child: Icon(Icons.image_not_supported));
                  }
                  return Image.network(
                    item.images[index].imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image)),
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(color: Colors.white),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          
          // Item details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                          item.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (item.estimatedValue != null)
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              currencyFormatter.format(item.estimatedValue),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
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
                          backgroundImage: item.user.profilePictureUrl != null
                              ? NetworkImage(item.user.profilePictureUrl!)
                              : null,
                          child: item.user.profilePictureUrl == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.user.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Joined ${DateFormat.yMMMd().format(item.createdAt)}', // Using item creation for now
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (item.user.rating != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
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
                                  item.user.rating!.toStringAsFixed(1),
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Looking for
                  const Text(
                    'Looking to Trade For',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (item.wants.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: item.wants.map((want) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(want.category?.name ?? 'Unknown'),
                      )).toList(),
                    )
                  else
                    Text(
                      'Open to offers',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  const SizedBox(height: 24),

                  // Location
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                        item.locationCity,
                        style: TextStyle(
                          color: Colors.grey[600],
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
                onPressed: () {
                  // TODO: Implement save functionality
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to favorites (demo)')));
                },
                icon: const Icon(Icons.favorite_border),
                label: const Text('Save'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side: BorderSide(color: Theme.of(context).colorScheme.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/trade_offer', arguments: item);
                },
                icon: const Icon(Icons.swap_horiz, color: Colors.white),
                label: const Text('Offer Trade'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ).copyWith(
                  elevation: MaterialStateProperty.all(0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}