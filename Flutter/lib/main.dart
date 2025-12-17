import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Technical Implementation: Phase 2
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase integration
import 'package:trade_match/theme.dart';
import 'package:trade_match/auth/auth_page.dart';
import 'package:trade_match/auth/welcome_page.dart';
import 'package:trade_match/auth/forgot_password.dart';
import 'package:trade_match/chat/chat_list.dart';
import 'package:trade_match/profile/profile.dart';
import 'package:trade_match/profile/settings_page.dart';
import 'package:trade_match/screens/add_item_page.dart';
import 'package:trade_match/screens/explore_screen.dart';
import 'package:trade_match/screens/item_detail_page.dart';
import 'package:trade_match/screens/library_screen.dart';
import 'package:trade_match/screens/matches_page.dart';
import 'package:trade_match/screens/notifications_page.dart';
import 'package:trade_match/screens/reviews_page.dart';
import 'package:trade_match/screens/search_filter_page.dart';
import 'package:trade_match/screens/trade_history_page.dart';
import 'package:trade_match/screens/trade_offer_page.dart';
import 'package:trade_match/models/barter_item.dart';

import 'package:trade_match/services/constants.dart';
import 'package:trade_match/services/storage_service.dart'; // Phase 2
import 'package:trade_match/services/cache_manager.dart'; // Phase 2

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // SUPABASE INITIALIZATION
  // Initialize Supabase for future migration (doesn't affect existing Laravel API)
  try {
    await Supabase.initialize(
      url: SUPABASE_URL,
      anonKey: SUPABASE_ANON_KEY,
    );
    print('✅ Supabase initialized successfully');
  } catch (e) {
    print('⚠️ Supabase initialization failed: $e');
    // App continues - Supabase is optional for now
  }
  
  // PHASE 2: Initialize Hive + StorageService + CacheManager with fallback
  // CRITICAL: App continues even if init fails (zero regression)
  try {
    await Hive.initFlutter();
    print('✅ Hive initialized successfully');
    
    // Initialize StorageService (register adapters, open boxes)
    await StorageService.init();
    
    // Cleanup expired cache entries on startup
    await CacheManager.cleanupExpiredData();
  } catch (e) {
    print('⚠️ Storage initialization failed, app will continue without caching: $e');
    // App continues normally - caching features will gracefully degrade
  }
  
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
          if (item != null) {
            return MaterialPageRoute(builder: (_) => TradeOfferPage(theirItem: item));
          }
        }
        if (settings.name == '/reviews') {
          final userId = settings.arguments as int?;
          if (userId != null) {
            return MaterialPageRoute(builder: (_) => ReviewsPage(userId: userId));
          }
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
      // Start with the SplashPage to check for persistent login
      home: const SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  void _checkLogin() async {
    // Check if user is already authenticated with Supabase
    final session = Supabase.instance.client.auth.currentSession;
    
    if (session != null) {
      try {
        // User is authenticated, get their profile
        final userId = session.user.id;
        AUTH_USER_ID = userId;
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main');
        }
      } catch (e) {
        print('Error loading user profile: $e');
        if (mounted) {
          // Error loading profile, go to Welcome
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WelcomePage()));
        }
      }
    } else {
      if (mounted) {
        // No active session, go to Welcome
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WelcomePage()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
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

  final List<Widget> _pages = [
    const ExploreScreen(),
    const ChatListScreen(),
    const LibraryScreen(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    // Add a check to prevent navigation to a non-existent page
    if (index < _pages.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_item'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 2.0,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 3.0,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(Icons.swap_horiz, 'Explore', 0),
            _buildNavItem(Icons.chat_bubble_outline, 'Chat', 1),
            const SizedBox(width: 40), // The space for the FAB
            _buildNavItem(Icons.inventory_2_outlined, 'Library', 2),
            _buildNavItem(Icons.person_outline, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? Theme.of(context).colorScheme.primary : Colors.grey;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: color),
            const SizedBox(height: 2), 
            Text(
              label,
              style: TextStyle(color: color, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}


