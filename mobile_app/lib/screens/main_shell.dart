import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../core/providers/auth_provider.dart';
import 'home/home_screen.dart';
import 'orders/order_history_screen.dart';
import 'profile/profile_screen.dart';
import 'feedback/feedback_screen.dart';
import 'cart/cart_screen.dart';
import 'favorites/favorites_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentTab = 0;
  int _drawerIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Widget> get _tabs => [
    HomeScreen(
      onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      onProfilePressed: () => _onNavTap(4),
    ),
    OrderHistoryScreen(onBackPressed: () => _onNavTap(0)),
    const CartScreen(), // Center tab — Cart
    const FavoritesScreen(), // Favs placeholder
    const ProfileScreen(),
  ];

  void _onNavTap(int index) {
    setState(() => _currentTab = index);
  }

  void _onDrawerItemTap(int index) {
    Navigator.pop(context); // Close drawer
    switch (index) {
      case 0:
        setState(() => _currentTab = 0);
        break;
      case 1:
        Navigator.pushNamed(context, '/order-history');
        break;
      case 2:
      case 3:
        Navigator.pushNamed(context, '/rewards');
        break;
      case 4:
        Navigator.pushNamed(context, '/settings');
        break;
      case 5:
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming Soon!')));
        break;
      case 6:
        Navigator.pushNamed(context, '/feedback');
        break;
      case 7:
        context.read<AuthProvider>().logout();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        break;
    }
    setState(() => _drawerIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        selectedIndex: _drawerIndex,
        onItemTap: _onDrawerItemTap,
      ),
      body: IndexedStack(index: _currentTab, children: _tabs),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentTab,
        onTap: _onNavTap,
      ),
    );
  }
}
