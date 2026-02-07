import 'package:nostalgic_foodie/pages/bottom_nav.dart';
import 'package:nostalgic_foodie/widgets/content_model.dart';
import 'package:nostalgic_foodie/widgets/widgets_support.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Onboard extends StatefulWidget {
  const Onboard({super.key});

  @override
  State<Onboard> createState() => _OnboardState();
}

class _OnboardState extends State<Onboard> {
  int currentIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea( // Ensures content doesn't hit the status bar or bottom notch
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: contents.length,
                onPageChanged: (int index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (_, i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          contents[i].image,
                          // Reduced height slightly to give the button more room
                          height: screenHeight / 2.5,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        Text(
                          contents[i].title,
                          style: AppWidget.headlineTextFieldStyle(),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20.0),
                        Text(
                          contents[i].description,
                          style: AppWidget.lightTextFieldStyle(),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                contents.length,
                    (index) => buildDot(index, context),
              ),
            ),
            GestureDetector(
              onTap: () async {
                if (currentIndex == contents.length - 1) {
                  // 1. Save the flag permanently
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isFirstTime', false);

                  if (!mounted) return;

                  // 2. SKIP LOGIN and go straight to the main app
                  // The main.dart logic we wrote will handle the Guest sign-in automatically!
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => const BottomNav()));
                } else {
                  _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    color: const Color(0xFFFBB25A), // Matching your app's theme color
                    borderRadius: BorderRadius.circular(20)),
                height: 60.0,
                // Reduced bottom margin from 40 to 20 to keep it on screen
                margin: const EdgeInsets.only(left: 40, right: 40, top: 20, bottom: 20),
                width: double.infinity,
                child: Center(
                  child: Text(
                    currentIndex == contents.length - 1 ? "Get Started" : "Next",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10.0,
      width: currentIndex == index ? 18 : 7,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: currentIndex == index ? const Color(0xFFFBB25A) : Colors.black38),
    );
  }
}