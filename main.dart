import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nostalgic_foodie/pages/bottom_nav.dart';
import 'pages/onboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 1. Initialize SharedPreferences here
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // 2. Get the value
  bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    await signInAsGuest();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  // 3. Pass the 'isFirstTime' variable into MyApp
  runApp(MyApp(
    isFirstTime: isFirstTime,
    isLoggedIn: currentUser != null,
  ));
}
Future<void> signInAsGuest() async {
  try {
    await FirebaseAuth.instance.signInAnonymously().timeout(const Duration(seconds: 10));
    print("Guest Login Success");
  } catch (e) {
    print("Guest Login Error: $e");
  }
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;
  final bool isLoggedIn;

  const MyApp({
    super.key,
    this.isFirstTime = false,
    this.isLoggedIn = false
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Delivery App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      // If it's the first time, show Onboard. Otherwise, go to SignUp/Login.
      // 1. If it's the very first time, show Onboard.
      // 2. Otherwise, go to BottomNav automatically (isLoggedIn handles the Guest/User state).
      home: isFirstTime ? const Onboard() : const BottomNav(),
    );
  }
}
