import 'package:flutter/material.dart';
import 'package:Flutter/theme.dart';
import 'package:Flutter/auth/auth_page.dart';
import 'package:Flutter/auth/welcome_page.dart';
import 'package:Flutter/auth/forgot_password.dart';
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
import 'package:Flutter/models/barter_item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradeMatch',
      theme: AppTheme.lightTheme(),
      // Routes. Some routes read ModalRoute.arguments to receive objects.
      routes: {
        '/settings': (context) => const SettingsPage(),
        '/add_item': (context) => const AddItemPage(),
        '/matches': (context) => const MatchesPage(),
        '/notifications': (context) => const NotificationsPage(),
        '/reviews': (context) => const ReviewsPage(),
        '/search': (context) => const SearchFilterPage(),
        '/trade_history': (context) => const TradeHistoryPage(),
        '/auth': (context) => const AuthPage(),
        '/main': (context) => const MainPage(),
      },
      // Named routes that need arguments are provided here using closures.
      onGenerateRoute: (settings) {
        if (settings.name == '/item_detail') {
          final item = settings.arguments as BarterItem?;
          if (item != null) {
            return MaterialPageRoute(builder: (_) => ItemDetailPage(item: item));
          }
        }
        if (settings.name == '/trade_offer') {
          final item = settings.arguments as BarterItem?;
          return MaterialPageRoute(builder: (_) => TradeOfferPage(theirItem: item));
        }
        // If the route is not found or arguments are invalid, show an error page.
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Error: Route not found or arguments are invalid.'),
            ),
          ),
        );
      },
      debugShowCheckedModeBanner: false,
      // Start with the welcome screen so users see onboarding first
      home: const WelcomePage(),
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
    const ExploreScreen(),
    const ChatListScreen(),
    const LibraryScreen(),
    const ProfilePage(),
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
            label: 'Explore',
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


