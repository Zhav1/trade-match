import 'package:flutter/material.dart';
import 'package:Flutter/theme.dart';
import 'package:Flutter/auth/auth_page.dart';
import 'package:Flutter/chat/chat_list.dart';
import 'package:Flutter/profile/profile.dart';
import 'package:Flutter/profile/settings_page.dart';
import 'package:Flutter/screens/add_item_page.dart';
import 'package:Flutter/screens/explore_screen.dart';
import 'package:Flutter/screens/item_detail_page.dart';
import 'package:Flutter/screens/library_screen.dart';
import 'package:Flutter/screens/matches_page.dart';
import 'package:Flutter/screens/notifications_page.dart';
import 'package:Flutter/screens/reviews_page.dart';
import 'package:Flutter/screens/search_filter_page.dart';
import 'package:Flutter/screens/trade_history_page.dart';
import 'package:Flutter/screens/trade_offer_page.dart';
import 'package:Flutter/services/mock_data_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradeMatch',
      // Use centralized app theme (colors + font)
      theme: AppTheme.lightTheme(),
      // ensure routes kept below
      // Added route for settings page
      routes: {
        '/settings': (context) => const SettingsPage(),
        '/add_item': (context) => const AddItemPage(),
        '/item_detail': (context) => const ItemDetailPage(),
        '/matches': (context) => const MatchesPage(),
        '/notifications': (context) => const NotificationsPage(),
        '/reviews': (context) => const ReviewsPage(),
        '/search': (context) => const SearchFilterPage(),
        '/trade_history': (context) => const TradeHistoryPage(),
        '/trade_offer': (context) => const TradeOfferPage(),
        '/auth': (context) => const AuthPage(),
      },
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void _showPageMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.add_box),
            title: const Text('Add New Item'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/add_item');
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Matches'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/matches');
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Trade History'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/trade_history');
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Reviews'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/reviews');
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search & Filter'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/search');
            },
          ),
        ],
      ),
    );
  }

  final List<Widget> _pages = [

    ExploreScreen(),
    ChatListScreen(),
    LibraryScreen(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPageMenu(context),
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
  selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}


