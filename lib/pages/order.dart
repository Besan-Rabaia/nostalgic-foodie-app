import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nostalgic_foodie/service/database.dart';
import 'package:nostalgic_foodie/service/shared_pref.dart';
import 'package:flutter/material.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String? userId, userName, userEmail;
  Stream<QuerySnapshot>? orderStream;
  bool _isDialogActive = false;
  final TextEditingController reviewCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    userId = await SharedPreferenceHelper().getUserId();
    userName = await SharedPreferenceHelper().getUserName();
    userEmail = await SharedPreferenceHelper().getUserEmail();

    if (userId != null) {
      orderStream = FirebaseFirestore.instance
          .collection("Orders")
          .where("UserId", isEqualTo: userId)
          .snapshots();
      setState(() {});
    }
  }

  // Helper method to handle moving order to Ratings and removing from Orders
  void _processRatingAction({
    required String orderId,
    required Map<String, dynamic> data,
    required int rating,
    required String review
  }) async {
    // 1. Finalize moves the order to 'Ratings' and deletes it from 'Orders'
    await DatabaseMethods().finalizeAndRemoveOrder(
      orderId: orderId,
      rating: rating,
      review: review,
      orderData: {
        ...data,
        "UserName": userName ?? "Guest",
        "UserEmail": userEmail ?? "N/A",
      },
    );

    // 2. Cleanup and Feedback
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Thank you for your feedback!"),
          backgroundColor: Colors.green,
        ),
      );
    }

    _isDialogActive = false;
    reviewCtrl.clear();
  }

  // ================= PROGRESS TRACKER =================

  Widget _buildProgressTracker(String status) {
    int step = 1;
    if (status == "On the Way") step = 2;
    if (status == "Delivered") step = 3;

    return Row(
      children: [
        _trackerNode(true, Icons.fiber_manual_record),
        _trackerLine(step >= 2),
        _trackerNode(step >= 2, Icons.local_shipping),
        _trackerLine(step >= 3),
        _trackerNode(step >= 3, Icons.check_circle),
      ],
    );
  }

  Widget _trackerNode(bool active, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? Colors.green : Colors.grey[300],
      ),
      child: Icon(icon, size: 16, color: Colors.white),
    );
  }

  Widget _trackerLine(bool active) {
    return Expanded(
      child: Container(
        height: 3,
        color: active ? Colors.green : Colors.grey[300],
      ),
    );
  }

  // ================= MAIN UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f8f8),
      appBar: AppBar(
        title: const Text("Current Orders", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: orderStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No active orders"));
          }

          // Check if any order is Delivered to show rating dialog
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data["Status"] == "Delivered" && !_isDialogActive) {
              _isDialogActive = true;
              WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _showRatingDialog(doc.id, data),
              );
            }
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final status = data["Status"] ?? "In Progress";
              List items = data["Items"] ?? [];

              return Container(
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         const Text("Order",
                            style:  TextStyle(color: Colors.grey, fontSize: 12)),
                        Text("AED ${data["Amount"]}",
                            style:  const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(),
                    Column(
                      children: items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${item["Name"]} (x${item["Quantity"]})",
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text("AED ${item["Total"] ?? ""}", style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 15),
                    _buildProgressTracker(status),
                    const SizedBox(height: 10),
                    Text("Status: $status",
                        style: TextStyle(
                          color: status == "Delivered" ? Colors.green : Colors.black54,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ================= RATING DIALOG =================

  void _showRatingDialog(String orderId, Map<String, dynamic> orderData) {
    int selectedRating = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Rate your Experience", textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("How was your meal?"),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) => IconButton(
                    icon: Icon(
                      i < selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                      size: 30,
                    ),
                    onPressed: () => setDialogState(() => selectedRating = i + 1),
                  ),
                  ),
                ),
                TextField(
                  controller: reviewCtrl,
                  decoration: const InputDecoration(
                    hintText: "Write a short review...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // SKIP: Processes with 0 rating and empty review
                  TextButton(
                    onPressed: () => _processRatingAction(
                        orderId: orderId,
                        data: orderData,
                        rating: 0,
                        review: ""
                    ),
                    child: const Text("SKIP", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                  // SUBMIT: Processes with user provided input
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    onPressed: () => _processRatingAction(
                        orderId: orderId,
                        data: orderData,
                        rating: selectedRating,
                        review: reviewCtrl.text
                    ),
                    child: const Text("SUBMIT", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }
}