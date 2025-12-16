import 'package:flutter/material.dart';
import 'package:trade_match/models/item.dart';
import 'package:trade_match/services/api_service.dart';

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
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Library', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.grey)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.tune, color: Colors.grey)),
          const SizedBox(width: 6)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)]),
              child: Row(
                children: [
                  Expanded(child: Text('Your saved items', style: TextStyle(fontWeight: FontWeight.bold, color: primary))),
                  TextButton(onPressed: () {}, child: const Text('Manage'))
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: FutureBuilder<List<Item>>(
                future: _itemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No items found. Add one!'));
                  } else {
                    final items = snapshot.data!;
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 10, mainAxisSpacing: 10),
                      itemCount: items.length,
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
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)]),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                                    child: (it.images != null && it.images!.isNotEmpty)
                                        ? Image.network(it.images!.first.imageUrl, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Center(child: Icon(Icons.broken_image)))
                                        : const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(it.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 6),
                                    Text('Cond: ${it.condition}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
