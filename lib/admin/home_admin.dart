import 'package:nostalgic_foodie/admin/add_food.dart';
import 'package:nostalgic_foodie/pages/login.dart';
import 'package:flutter/material.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {

  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout Confirmation'),
          content: const Text('Are you sure you want to leave the Admin Panel?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Navigate back to Login and clear the navigation stack
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LogIn()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // REMOVE the appBar: property entirely to delete the top space
      body: Container(
        // margin top: 50 is usually enough to clear the phone's status bar (clock/battery)
        margin: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Column(
          children: [
            // CUSTOM TOP ROW: Replaces the bulky AppBar
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _showLogoutDialog(); // Your confirmation dialog
                  },
                  child: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      "Home Admin",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins'),
                    ),
                  ),
                ),
                // Empty SizedBox to balance the Row so the text stays centered
                const SizedBox(width: 30),
              ],
            ),
            const SizedBox(height: 50.0), // Space between title and the button

            // ADD FOOD ITEMS BUTTON
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddFood()));
              },
              child: Material(
                elevation: 10.0,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset("images/food.jpg", height: 80, width: 80, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Text(
                        "Add Food Items",
                        style: TextStyle(
                            color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
