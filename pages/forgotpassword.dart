import 'package:nostalgic_foodie/pages/signup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nostalgic_foodie/widgets/widgets_support.dart'; // Ensure this import is here

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController mailcontroller = TextEditingController();
  String email = "";
  final _formkey = GlobalKey<FormState>();

  resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: mailcontroller.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Password Reset Email has been sent!", style: TextStyle(fontSize: 18.0))));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message ?? "An error occurred", style: const TextStyle(fontSize: 18.0))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              // Top Orange Background
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.5,
                decoration: const BoxDecoration(color: Color(0xFFFBB25A)),
              ),
              // White Rounded Bottom Section
              Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
              ),
              // Main Content
              Container(
                margin: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                child: Column(
                  children: [
                    // LOGO: Consistent with Login/SignUp
                    Center(
                      child: Image.asset(
                        "images/logo.png",
                        height: 200,
                        width: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Form(
                          key: _formkey,
                          child: Column(
                            children: [
                              Text("Password Recovery",
                                  style: AppWidget.headlineTextFieldStyle()),
                              const SizedBox(height: 10.0),
                              const Text("Enter your registered email",
                                  style: TextStyle(color: Colors.black54, fontSize: 16.0)),
                              const SizedBox(height: 30.0),
                              TextFormField(
                                controller: mailcontroller,
                                validator: (value) => (value == null || value.isEmpty)
                                    ? 'Please Enter Email' : null,
                                decoration: const InputDecoration(
                                  hintText: "Email",
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                              ),
                              const SizedBox(height: 40.0),
                              GestureDetector(
                                onTap: () {
                                  if (_formkey.currentState!.validate()) {
                                    resetPassword();
                                  }
                                },
                                child: Container(
                                  width: 200,
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFBB25A),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "SEND EMAIL",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    // Bottom Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?",
                            style: TextStyle(fontSize: 16.0, color: Colors.black)),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (context) => const SignUp())),
                          child: const Text(
                            "Create",
                            style: TextStyle(
                                color: Color(0xFFFBB25A),
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}