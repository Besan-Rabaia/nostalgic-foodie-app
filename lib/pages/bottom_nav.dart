import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:nostalgic_foodie/pages/home.dart';
import 'package:nostalgic_foodie/pages/order.dart';
import 'package:nostalgic_foodie/pages/profile.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Only 3 pages: Home, Orders, and Profile
    final List<Widget> pages = [
      const Home(),
      const OrderPage(),
      const Profile(),
    ];

    return Scaffold(
      extendBody: true, // ⭐ important
      backgroundColor: const Color(0xfff8f8f8),
      body: pages[currentTabIndex],
      bottomNavigationBar: SafeArea( // ⭐ prevents pushing down
        top: false,
        child: CurvedNavigationBar(
          index: currentTabIndex,
          height: 60.0,
          // reduce height
          backgroundColor: const Color(0xfff8f8f8),
          color: Colors.black,
          buttonBackgroundColor: Colors.black,
          animationDuration: const Duration(milliseconds: 400),
          onTap: (int index) {
            setState(() {
              currentTabIndex = index;
            });
          },
          items: const [
            Icon(Icons.home_outlined, color: Colors.white),
            Icon(Icons.local_shipping_outlined, color: Colors.white),
            Icon(Icons.person_outline, color: Colors.white),
          ],
        ),
      ),
    );
  }
}