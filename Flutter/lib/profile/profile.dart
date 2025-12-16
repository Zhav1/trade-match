import 'package:flutter/material.dart';
import 'package:trade_match/services/api_service.dart';
import 'package:trade_match/models/item.dart';
import 'settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userData;
  List<Item> _userItems = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _apiService.getUser(),
        _apiService.getUserItems(),
      ]);
      
      if (mounted) {
        setState(() {
          _userData = results[0] as Map<String, dynamic>;
          _userItems = results[1] as List<Item>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load profile: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
  final Color primary = Theme.of(context).colorScheme.primary;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_errorMessage),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : NestedScrollView(
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.black87),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsPage())),
                ),
              ],
              expandedHeight: 300,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/profile.jpg',
                      fit: BoxFit.cover,
                      color: Colors.black.withOpacity(0.12),
                      colorBlendMode: BlendMode.darken,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.white.withOpacity(0.95)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 56,
                            backgroundImage: _userData?['profile_picture_url'] != null
                                ? NetworkImage(_userData!['profile_picture_url']) as ImageProvider
                                : const AssetImage('assets/images/pp-1.png'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(72),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TabBar(
                    labelColor: Colors.black87,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    tabs: const [Tab(text: 'Ditawarkan'), Tab(text: 'Dicari')],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _ProfileInfo(userData: _userData, itemCount: _userItems.length),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(children: [
            _ItemList(items: _userItems, isOffer: true),
            const _ItemList(items: [], isOffer: false) // Placeholder for 'Dicari'
          ]),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile editing coming soon')),
            );
          },
          icon: const Icon(Icons.edit),
          label: const Text('Edit Profile'),
          backgroundColor: primary,
        ),
      ),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final int itemCount;
  
  const _ProfileInfo({this.userData, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    final name = userData?['name'] ?? 'User';
    final location = userData?['default_location_city'] ?? 'Location not set';
    // Use actual item list length for "Offers" if available, else fallback to API count
    final offersCount = itemCount > 0 ? itemCount.toString() : (userData?['offers_count']?.toString() ?? '0');
    final requestsCount = userData?['requests_count']?.toString() ?? '0';
    final tradesCount = userData?['trades_count']?.toString() ?? '0';

    return Column(
      children: [
        Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(location, style: TextStyle(color: Colors.grey[700])),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(value: offersCount, title: 'Offers'),
            _StatItem(value: requestsCount, title: 'Requests'),
            _StatItem(value: tradesCount, title: 'Trades'),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String title;
  const _StatItem({required this.value, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
      ],
    );
  }
}

class _ItemList extends StatelessWidget {
  final bool isOffer;
  final List<Item> items;
  
  const _ItemList({required this.isOffer, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
       return Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Icon(isOffer ? Icons.inventory_2_outlined : Icons.search_outlined, size: 48, color: Colors.grey[300]),
             const SizedBox(height: 16),
             Text(isOffer ? 'No items offered yet' : 'No requests yet', style: TextStyle(color: Colors.grey[500])),
           ],
         ),
       );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: items.length,
      separatorBuilder: (context, index) => Divider(color: Colors.grey[200]),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              image: (item.images != null && item.images!.isNotEmpty) 
                  ? DecorationImage(image: NetworkImage(item.images!.first.imageUrl), fit: BoxFit.cover)
                  : null
            ),
            child: (item.images == null || item.images!.isEmpty) 
               ? const Icon(Icons.inventory_2_outlined, color: Colors.black54) 
               : null,
          ),
          title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(item.condition, style: TextStyle(color: Colors.grey[700])),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: () {
            // TODO: Navigate to item detail
          },
        );
      },
    );
  }
}