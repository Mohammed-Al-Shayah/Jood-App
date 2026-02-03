import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jood/core/widgets/main_bottom_nav.dart';
import 'package:jood/features/home/presentation/pages/home_screen.dart';
import 'package:jood/features/bookings/presentation/pages/orders_screen.dart';
import 'package:jood/features/users/presentation/pages/profile_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;
  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = const [HomeTab(), OrdersTab(), ProfileTab()];
  }

  void _onTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) {
        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(index: _currentIndex, children: _tabs),
        bottomNavigationBar: MainBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onTap,
        ),
      ),
    );
  }
}