import 'package:flutter/material.dart';
import 'package:trade_match/services/supabase_service.dart';
import 'package:trade_match/models/item.dart';
import 'settings_page.dart';
import 'package:trade_match/theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseService _supabaseService = SupabaseService();
  Map<String, dynamic>? _userData;
  List<Item> _userItems = [];
  List<Map<String, dynamic>> _completedTrades = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userData = await _supabaseService.getCurrentUserProfile();
      final userItemsData = await _supabaseService.getUserItems();
      final completedTrades = await _supabaseService.getCompletedTrades();
      final userItems = userItemsData
          .map((data) => Item.fromJson(data))
          .toList();

      if (mounted) {
        setState(() {
          _userData = userData;
          _userItems = userItems;
          _completedTrades = completedTrades;
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
        backgroundColor: AppColors.surface,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_errorMessage),
                    const SizedBox(height: AppSpacing.md),
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
                    backgroundColor: AppColors.surface,
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(
                          Icons.settings,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SettingsPage(),
                          ),
                        ),
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
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.95),
                                ],
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
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 56,
                                  backgroundImage:
                                      _userData?['profile_picture_url'] != null
                                      ? NetworkImage(
                                              _userData!['profile_picture_url'],
                                            )
                                            as ImageProvider
                                      : const AssetImage(
                                          'assets/images/pp-1.png',
                                        ),
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
                          labelColor: AppColors.textPrimary,
                          unselectedLabelColor: AppColors.textSecondary,
                          indicatorColor: Theme.of(context).colorScheme.primary,
                          tabs: const [
                            Tab(text: 'Ditawarkan'),
                            Tab(text: 'History'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 12.0,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _ProfileInfo(
                            userData: _userData,
                            itemCount: _userItems.length,
                            tradesCount: _completedTrades.length,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                body: TabBarView(
                  children: [
                    _ItemList(items: _userItems, isOffer: true),
                    _TradeHistoryList(
                      trades: _completedTrades,
                      currentUserId: _supabaseService.userId,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final int itemCount;
  final int tradesCount;

  const _ProfileInfo({this.userData, required this.itemCount, this.tradesCount = 0});

  @override
  Widget build(BuildContext context) {
    final name = userData?['name'] ?? 'User';
    final location = userData?['default_location_city'] ?? 'Location not set';
    // Use actual item list length for "Offers" if available, else fallback to API count
    final offersCount = itemCount > 0
        ? itemCount.toString()
        : (userData?['offers_count']?.toString() ?? '0');
    final requestsCount = userData?['requests_count']?.toString() ?? '0';
    final displayTradesCount = tradesCount > 0 
        ? tradesCount.toString() 
        : (userData?['trades_count']?.toString() ?? '0');

    return Column(
      children: [
        Text(name, style: AppTextStyles.heading3),
        const SizedBox(height: AppSpacing.xs),
        Text(
          location,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(value: offersCount, title: 'Offers'),
            _StatItem(value: requestsCount, title: 'Requests'),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/trade_history'),
              child: _StatItem(value: displayTradesCount, title: 'Trades'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
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
        Text(value, style: AppTextStyles.heading3),
        const SizedBox(height: AppSpacing.xs),
        Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
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
            Icon(
              isOffer ? Icons.inventory_2_outlined : Icons.search_outlined,
              size: 48,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              isOffer ? 'No items offered yet' : 'No requests yet',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: items.length,
      separatorBuilder: (context, index) => Divider(color: AppColors.divider),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(AppRadius.sm),
              image: (item.images != null && item.images!.isNotEmpty)
                  ? DecorationImage(
                      image: NetworkImage(item.images!.first.imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (item.images == null || item.images!.isEmpty)
                ? const Icon(Icons.inventory_2_outlined, color: Colors.black54)
                : null,
          ),
          title: Text(item.title, style: AppTextStyles.labelBold),
          subtitle: Text(
            item.condition,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
          onTap: () {
            // TODO: Navigate to item detail
          },
        );
      },
    );
  }
}

/// Widget to display trade history - items that have been traded
class _TradeHistoryList extends StatelessWidget {
  final List<Map<String, dynamic>> trades;
  final String? currentUserId;

  const _TradeHistoryList({required this.trades, this.currentUserId});

  @override
  Widget build(BuildContext context) {
    if (trades.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No completed trades yet',
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 8),
            Text(
              'Your traded items will appear here',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: trades.length,
      separatorBuilder: (context, index) => Divider(color: AppColors.divider),
      itemBuilder: (context, index) {
        final trade = trades[index];
        // Use snapshots if available (for deleted items), otherwise use relational data
        final itemA = trade['item_a_snapshot'] ?? trade['itemA'];
        final itemB = trade['item_b_snapshot'] ?? trade['itemB'];
        
        // Determine which item was the user's and which was the partner's
        // Note: For snapshots, user_id is in the top level of the item object
        final isUserItemA = itemA?['user_id'] == currentUserId;
        final myItem = isUserItemA ? itemA : itemB;
        final theirItem = isUserItemA ? itemB : itemA;
        
        final myItemImages = myItem?['images'] as List<dynamic>? ?? [];
        final theirItemImages = theirItem?['images'] as List<dynamic>? ?? [];
        
        final updatedAt = DateTime.tryParse(trade['updated_at'] ?? '');
        final formattedDate = updatedAt != null 
            ? '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}'
            : '';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Trade #${trade['id']}',
                      style: AppTextStyles.caption.copyWith(color: Colors.grey[600]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Completed',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Trade items
                Row(
                  children: [
                    // My item
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              image: myItemImages.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(myItemImages.first['image_url'] ?? ''),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: myItemImages.isEmpty
                                ? const Icon(Icons.inventory_2_outlined, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            myItem?['title'] ?? 'Your Item',
                            style: AppTextStyles.caption,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Swap icon
                    Icon(
                      Icons.swap_horiz,
                      color: Theme.of(context).colorScheme.primary,
                      size: 30,
                    ),
                    // Their item
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              image: theirItemImages.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(theirItemImages.first['image_url'] ?? ''),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: theirItemImages.isEmpty
                                ? const Icon(Icons.inventory_2_outlined, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            theirItem?['title'] ?? 'Their Item',
                            style: AppTextStyles.caption,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Date
                Text(
                  formattedDate,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

