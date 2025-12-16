import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trade_match/models/item.dart';
import 'package:trade_match/screens/add_item_page.dart';
import 'package:trade_match/services/api_service.dart';
import 'package:trade_match/theme.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Phase 3: Performance

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Item>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    setState(() {
      _itemsFuture = _apiService.getUserItems();
    });
  }

  Future<void> _deleteItem(int id) async {
    try {
      await _apiService.deleteItem(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item deleted successfully")));
        _loadItems();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete: $e")));
      }
    }
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item?'),
        content: const Text('Are you sure you want to delete this item? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteItem(id);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Library', style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary)),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search, color: AppColors.textSecondary)),
          IconButton(onPressed: () {}, icon: Icon(Icons.tune, color: AppColors.textSecondary)),
          const SizedBox(width: AppSpacing.xs)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.button), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)]),
              child: Row(
                children: [
                  Expanded(child: Text('Your saved items', style: AppTextStyles.labelBold.copyWith(color: primary))),
                  TextButton(onPressed: () {}, child: const Text('Manage'))
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: FutureBuilder<List<Item>>(
                future: _itemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Skeleton loading grid
                    return GridView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveUtils.getGridColumns(
                          context,
                          mobile: 2,
                          tablet: 3,
                          desktop: 4,
                        ),
                        crossAxisSpacing: AppSpacing.sm,
                        mainAxisSpacing: AppSpacing.sm,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: 6, // Show 6 skeleton cards
                      itemBuilder: (context, index) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: GlassCard(
                            padding: EdgeInsets.zero,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(color: Colors.white),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 12,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        height: 10,
                                        width: 60,
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
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No items found. Add one!'));
                  } else {
                    final items = snapshot.data!;
                    return GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ResponsiveUtils.getGridColumns(
              context,
              mobile: 2,
              tablet: 3,
              desktop: 4,
            ),
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 0.8,
          ),itemCount: items.length,
                      itemBuilder: (context, i) {
                        final it = items[i];
                        // Dynamic height not easily doable in standard GridView without staggered, keeping fixed aspect ratio for now
                        // Used logic from previous code for image height visual variety if desired, but standard grid is safer
                        
                        return GestureDetector(
                          onTap: () {
                             // Navigate to Edit Mode
                             Navigator.push(
                               context,
                               MaterialPageRoute(builder: (_) => AddItemPage(item: it)),
                             ).then((_) => _loadItems());
                          },
                          onLongPress: () => _confirmDelete(it.id),
                          child: Container(
                            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)]),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(AppRadius.card), topRight: Radius.circular(AppRadius.card)),
                                    child: (it.images != null && it.images!.isNotEmpty)
                                        ? CachedNetworkImage(
                                            imageUrl: it.images!.first.imageUrl,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            memCacheWidth: 600, // Smaller thumbnail
                                            placeholder: (context, url) => Container(
                                              color: Colors.grey[200],
                                              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                            ),
                                            errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image)),
                                          )
                                        : const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(it.title, style: AppTextStyles.labelBold, maxLines: 1, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text('Cond: ${it.condition}', style: AppTextStyles.caption),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add item page, then refresh on return
           Navigator.pushNamed(context, '/add-item').then((_) => _loadItems());
        },
        backgroundColor: primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
