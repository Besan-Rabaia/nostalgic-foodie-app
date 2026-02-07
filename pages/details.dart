import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nostalgic_foodie/service/database.dart';
import 'package:nostalgic_foodie/service/shared_pref.dart';
import 'package:nostalgic_foodie/widgets/widgets_support.dart';
import 'package:flutter/material.dart';

class Details extends StatefulWidget {
  final String image, name, detail, price;
  const Details({
    super.key,
    required this.detail,
    required this.image,
    required this.name,
    required this.price,
  });

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  int a = 1, total = 0;
  String? id;

  getthesharedpref() async {
    id = await SharedPreferenceHelper().getUserId();
    setState(() {});
  }
  getUserId() async {
    // First, check if Firebase already has a user (Registered or Guest)
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      id = user.uid;
    } else {
      // If NO user exists, sign them in anonymously as a guest right now
      UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
      id = userCredential.user?.uid;
    }
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
  }

  @override
  void initState() {
    super.initState();
    ontheload();
    // We initialize the ID, but we will ALSO check it inside the button
    id = FirebaseAuth.instance.currentUser?.uid;
    total = int.parse(widget.price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        // Remove left/right margin from the main container so the image can go full-width if desired
        margin: const EdgeInsets.only(top: 50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black),
              ),
            ),
            const SizedBox(height: 20.0),
            // FIX: Perfected Image Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  widget.image,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2.5, // Increased height for better visibility
                  fit: BoxFit.cover, // Ensures the photo fills the box perfectly without stretching
                ),
              ),
            ),
            const SizedBox(height: 15.0),
            // Content Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.name,
                            style: AppWidget.headlineTextFieldStyle(),
                            maxLines: 2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Quantity controls
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (a > 1) {
                                  a--;
                                  total = total - int.parse(widget.price);
                                  setState(() {});
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.remove, color: Colors.white, size: 20),
                              ),
                            ),
                            const SizedBox(width: 15.0),
                            Text(a.toString(), style: AppWidget.semiBoldTextFieldStyle()),
                            const SizedBox(width: 15.0),
                            GestureDetector(
                              onTap: () {
                                a++;
                                total = total + int.parse(widget.price);
                                setState(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.add, color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Text(widget.detail, style: AppWidget.lightTextFieldStyle()),
                    const SizedBox(height: 30.0),
                    Row(
                      children: [
                        Text("Delivery Time", style: AppWidget.semiBoldTextFieldStyle()),
                        const SizedBox(width: 25.0),
                        const Icon(Icons.alarm, color: Colors.black54),
                        const SizedBox(width: 5.0),
                        Text("30 min", style: AppWidget.semiBoldTextFieldStyle()),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ),
            ),
            // Bottom Bar
            Container(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Total Price", style: AppWidget.semiBoldTextFieldStyle()),
                      Text("AED $total", style: AppWidget.headlineTextFieldStyle()),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      String? currentUid = FirebaseAuth.instance.currentUser?.uid;

                      if (currentUid == null || currentUid.isEmpty) {
                        UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
                        currentUid = userCredential.user?.uid;
                      }

                      if (currentUid != null && currentUid.isNotEmpty) {
                        try {
                          // 1. Reference to the user's cart
                          var cartRef = FirebaseFirestore.instance
                              .collection("users")
                              .doc(currentUid)
                              .collection("Cart");

                          // 2. Check if this specific food item is already in the cart
                          var query = await cartRef.where("Name", isEqualTo: widget.name).get();

                          if (query.docs.isNotEmpty) {
                            // --- ITEM EXISTS: Update Quantity & Total ---
                            var existingDoc = query.docs.first;
                            int existingQty = int.parse(existingDoc["Quantity"]);
                            int existingTotal = int.parse(existingDoc["Total"]);

                            int newQty = existingQty + a;
                            int newTotal = existingTotal + total;

                            await cartRef.doc(existingDoc.id).update({
                              "Quantity": newQty.toString(),
                              "Total": newTotal.toString(),
                            });

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                backgroundColor: Colors.green,
                                content: Text("Cart Updated! Quantity increased.")));
                          } else {
                            // --- ITEM IS NEW: Add fresh document ---
                            Map<String, dynamic> addFoodtoCart = {
                              "Name": widget.name,
                              "Quantity": a.toString(),
                              "Total": total.toString(),
                              "Image": widget.image,
                            };

                            await DatabaseMethods().addFoodToCart(addFoodtoCart, currentUid);

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                backgroundColor: Colors.orangeAccent,
                                content: Text("Food Added to Cart")));
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                        }
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2.2,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Show a small loader if ID is still fetching
                          id == null
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text("Add to cart", style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 10.0),
                          const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}