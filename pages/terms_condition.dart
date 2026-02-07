import 'package:nostalgic_foodie/widgets/widgets_support.dart';
import 'package:flutter/material.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea( // Added SafeArea to prevent status bar overlap
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20.0),
              // --- Header with Back Arrow ---
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black),
                  ),
                  const SizedBox(width: 20.0),
                  Text("Terms & Conditions", style: AppWidget.headlineTextFieldStyle()),
                ],
              ),
              const SizedBox(height: 20.0),

              // --- Scrollable Content ---
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("1. Account Responsibility"),
                      _buildSectionBody(
                          "Users are responsible for maintaining the confidentiality of their account credentials. Each email is restricted to one unique account."),

                      _buildSectionTitle("2. Admin & Content"),
                      _buildSectionBody(
                          "Admins reserve the right to modify food categories (Burger, Pizza, etc.) and prices at any time. Food images are for illustrative purposes."),

                      _buildSectionTitle("3. Wallet & Payments"),
                      _buildSectionBody(
                          "The app uses a virtual wallet system. All new accounts begin with a balance of 0 AED. Clicking 'CheckOut' in the Food Cart will deduct the total amount from this balance."),

                      _buildSectionTitle("4. Privacy"),
                      _buildSectionBody(
                          "Your data (Name and Email) is securely stored in our cloud database to provide a personalized ordering experience."),

                      const SizedBox(height: 20.0),
                      const Center(
                        child: Text(
                          "Last Updated: January 2026",
                          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      ),

                      const SizedBox(height: 30.0),

                      // --- Accept Button Moved Inside Scroll View ---
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Material(
                          elevation: 5.0,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: const Color(0Xffff5722),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                "I AGREE",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40.0), // Padding at the very bottom
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(title, style: AppWidget.semiBoldTextFieldStyle()),
    );
  }

  Widget _buildSectionBody(String body) {
    return Text(
      body,
      style: const TextStyle(
        color: Colors.black54,
        fontSize: 15.0,
        height: 1.5,
      ),
    );
  }
}