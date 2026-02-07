import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nostalgic_foodie/pages/cart.dart';
import 'package:nostalgic_foodie/pages/details.dart';

import 'package:nostalgic_foodie/service/database.dart';
import 'package:nostalgic_foodie/widgets/widgets_support.dart';
import 'package:flutter/material.dart';
import 'package:nostalgic_foodie/service/shared_pref.dart';

class Home extends StatefulWidget {

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static bool hasShownWelcome = false;

  bool icecream = false,
      pizza = true,
      salad = false,
      burger = false,
      sidedish = false,
      drinks = false;
  Stream? fooditemStream;

  ontheload() async {
    fooditemStream =  DatabaseMethods().getFoodItem("Pizza");
    setState(() {});
  }

  String? name;

  getthesharedpref() async {
    // 1. Try to get name from Shared Preferences first
    name = await SharedPreferenceHelper().getUserName();

    // 2. If name is empty or "Guest", check Firebase Auth and Firestore
    if (name == null || name!.isEmpty || name == "Guest") {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null && !currentUser.isAnonymous) {
        // Fetch the latest name from your Firestore 'users' collection
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            name = userDoc["Name"]; // This will pull "Besan Rabaia" from the DB
          });
          // Save it locally so it loads faster next time
          await SharedPreferenceHelper().saveUserName(name!);
        }
      }
    } else {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    // Load data first
    getthesharedpref().then((_) {
      // Only show notification AFTER name is loaded
      showWelcomeNotification();
    });
    ontheload();
  }

  showWelcomeNotification() async {
    // If it has already shown once during this app session, stop here!
    if (hasShownWelcome) return;

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.isAnonymous) {
      String finalName = name ?? user.displayName ?? "User";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Welcome Back, $finalName! 👋"),
          backgroundColor: const Color(0xFFFBB25A),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );

      // This 'true' will now stick even if you go to the Cart and back
      setState(() {
        hasShownWelcome = true;
      });
    }
  }
  // Modified to work inside a SingleChildScrollView
  Widget allItemsVertically() {
    return StreamBuilder(
      stream: fooditemStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            // Important: Allows the parent to handle scrolling
            itemCount: snapshot.data.docs.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.docs[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              Details(
                                detail: ds["Detail"],
                                name: ds["Name"],
                                image: ds["Image"],
                                price: ds["Price"],
                              )));
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 20, bottom: 20),
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              ds["Image"],
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ds["Name"],
                                    style: AppWidget.semiBoldTextFieldStyle()),
                                const SizedBox(height: 5),
                                Text(ds["Detail"],
                                    style: AppWidget.lightTextFieldStyle(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 5),
                                Text("AED " + ds["Price"],
                                    style: AppWidget.semiBoldTextFieldStyle()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            })
            : const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f8f8), // Match the BottomNav background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.only(top: 20.0, left: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Hello ${name ?? 'Guest'},", style: AppWidget.boldTextFieldStyle()),
                    GestureDetector(
                      onTap: () {
                        // Directly pushes the Cart page as a new screen
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const Cart()));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 20.0),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text("Delicious Food",
                    style: AppWidget.headlineTextFieldStyle()),
                Text("Discover and Get Great Food",
                    style: AppWidget.lightTextFieldStyle()),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.only(right: 20.0),
                  height: 75,
                  child: showItem(),
                ),
                const SizedBox(height: 30),
                allItemsVertically(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Updated showItem to use your brand colors
  Widget showItem() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          categoryIcon("images/ice-cream.png", icecream, () async {
            icecream = true;
            pizza = false;
            salad = false;
            burger = false;
            sidedish = false;
            drinks = false;
            fooditemStream =  DatabaseMethods().getFoodItem("Ice-cream");
            setState(() {});
          }),
          const SizedBox(width: 20),
          categoryIcon("images/pizza.png", pizza, () async {
            icecream = false;
            pizza = true;
            salad = false;
            burger = false;
            sidedish = false;
            drinks = false;
            fooditemStream =  DatabaseMethods().getFoodItem("Pizza");
            setState(() {});
          }),
          const SizedBox(width: 20),
          categoryIcon("images/salad.png", salad, () async {
            icecream = false;
            pizza = false;
            salad = true;
            burger = false;
            sidedish = false;
            drinks = false;
            fooditemStream =  DatabaseMethods().getFoodItem("Salad");
            setState(() {});
          }),
          const SizedBox(width: 15),
          categoryIcon("images/burger.png", burger, () async {
            icecream = false;
            pizza = false;
            salad = false;
            burger = true;
            sidedish = false;
            drinks = false;
            fooditemStream =  DatabaseMethods().getFoodItem("Burger");
            setState(() {});
          }),
          const SizedBox(width: 15),
          categoryIcon("images/sidedish.png", sidedish, () async {
            icecream = false;
            pizza = false;
            salad = false;
            burger = false;
            sidedish = true;
            drinks = false;
            fooditemStream =  DatabaseMethods().getFoodItem("SideDish");
            setState(() {});
          }),
          const SizedBox(width: 15),
          categoryIcon("images/shake.png", drinks, () async {
            icecream = false;
            pizza = false;
            salad = false;
            burger = false;
            sidedish = false;
            drinks = true;
            fooditemStream =  DatabaseMethods().getFoodItem("Drinks");
            setState(() {});
          }),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

// Helper widget to reduce code duplication and fix selection colors
  Widget categoryIcon(String imagePath, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            // Highlight with Orange when active
              color: isActive ? const Color(0xFFFBB25A) : Colors.white,
              borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            imagePath,
            height: 50.0,
            width: 50.0,
            fit: BoxFit.cover,
            // Icons turn white when selected for better contrast
            color: isActive ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}