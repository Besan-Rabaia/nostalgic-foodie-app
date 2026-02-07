import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nostalgic_foodie/pages/bottom_nav.dart';
import 'package:nostalgic_foodie/pages/checkoutPage.dart';
import 'package:nostalgic_foodie/pages/login.dart';
import 'package:nostalgic_foodie/pages/signup.dart';
import 'package:nostalgic_foodie/service/database.dart';
import 'package:nostalgic_foodie/widgets/widgets_support.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  String? id;
  int total = 0;
  Stream<QuerySnapshot>? foodStream;

  clearFullCart() async {
    if (id == null) return;

    // 1. Get all items in the current user's cart
    var snapshots = await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Cart")
        .get();

    // 2. Prepare a batch delete
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }

    // 3. Commit the changes
    await batch.commit();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cart cleared successfully!")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    // 1. Get the fresh current user directly from Firebase Auth
    User? user = FirebaseAuth.instance.currentUser;

    // 2. Ensure we use the NEW uid if they just registered
    id = user?.uid;

    if (id != null) {
      // 3. Re-initialize the stream with the specific user ID
      foodStream = DatabaseMethods().getFoodCart(id!);
      print("Loading cart for User ID: $id");
    } else {
      print("No User ID found for cart");
    }

    // 4. Update UI to show the items and recalculated total
    if (mounted) {
      setState(() {});
    }
  }

  void checkout() {
    if (total == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cart is empty!")),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null || user.isAnonymous) {
      // Pass the total to SignUp so it knows to return to Checkout later
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignUp(total: total)), // Ensure SignUp accepts 'total'
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CheckoutPage(total: total.toString())),
      );
    }
  }
  Widget foodCart() {
    return StreamBuilder<QuerySnapshot>(
      stream: foodStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text("Your cart is empty 😔"));

        int tempTotal = 0;
        for (var doc in docs) {
          tempTotal += int.parse(doc["Total"]);
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && total != tempTotal) {
            setState(() => total = tempTotal);
          }
        });

        return ListView.builder(
          padding: const EdgeInsets.only(top: 10),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var ds = docs[index];
            int currentQty = int.parse(ds["Quantity"]);
            int currentItemTotal = int.parse(ds["Total"]);
            int pricePerItem = currentItemTotal ~/ currentQty; // Calculate base price

            return Dismissible(
              key: Key(ds.id),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) async {
                // Calls your database delete method
                await DatabaseMethods().deleteCartItem(id!, ds.id);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${ds["Name"]} removed from cart")));
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(ds["Image"], height: 70, width: 70, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ds["Name"], style: AppWidget.semiBoldTextFieldStyle()),
                              Text("AED ${ds["Total"]}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        // --- QUANTITY CONTROLS ---
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                // CHANGE: Only decrease if quantity is GREATER than 1
                                if (currentQty > 1) {
                                  await DatabaseMethods().updateCartItemQuantity(
                                      id!, ds.id, currentQty - 1, pricePerItem);
                                } else {
                                  // Optional: Show a message instead of deleting
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Swipe the item to the left to delete it!"),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(5)),
                                child: const Icon(Icons.remove, color: Colors.white, size: 20),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(currentQty.toString(), style: AppWidget.semiBoldTextFieldStyle()),
                            ),
                            GestureDetector(
                              onTap: () async {
                                // Calls your database update method
                                await DatabaseMethods().updateCartItemQuantity(
                                    id!, ds.id, currentQty + 1, pricePerItem);
                              },
                              child: Container(
                                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(5)),
                                child: const Icon(Icons.add, color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER WITH REPAIRED BACK ARROW ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const BottomNav()),
                            (route) => false,
                      );
                    },
                    child: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black),
                  ),
                  const SizedBox(width: 20.0),
                  Text("Food Cart", style: AppWidget.headlineTextFieldStyle()),
                  const Spacer(),
                  // --- NEW CLEAR ALL BUTTON ---
                  GestureDetector(
                    onTap: () {
                      _showConfirmationDialog("Clear Cart", "Are you sure you want to remove all items?", clearFullCart);
                    },
                    child: const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 28),
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: () => loadData(),
                    child: const Icon(Icons.refresh, color: Colors.black),
                  ),
                ],
              ),
            ),
            // --- WRAP THE LIST IN A REFRESH INDICATOR ---
            Expanded(
              child: RefreshIndicator(
                onRefresh: loadData, // Pull down to refresh
                color: const Color(0xFFFBB25A),
                child: foodCart(),
              ),
            ),
            // --- BOTTOM CHECKOUT SECTION ---
            Container(
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1)],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  )),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total", style: AppWidget.semiBoldTextFieldStyle()),
                      Text("AED $total", style: AppWidget.headlineTextFieldStyle()),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    // If total is 0, clicking does nothing
                    onTap: total == 0 ? null : checkout,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        // Turns Gray if total is 0, otherwise stays your Brand Orange
                          color: total == 0 ? Colors.grey : const Color(0xFFFBB25A),
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child: Center(
                        child: Text(
                          "CHECKOUT",
                          style: TextStyle(
                              color: total == 0 ? Colors.white70 : Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showConfirmationDialog(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: AppWidget.semiBoldTextFieldStyle()),
        content: Text(content, style: AppWidget.lightTextFieldStyle()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.black))
          ),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: const Text("Yes, Clear", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}
