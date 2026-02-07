import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nostalgic_foodie/admin/home_admin.dart';
import 'package:nostalgic_foodie/service/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nostalgic_foodie/pages/bottom_nav.dart';
import 'package:nostalgic_foodie/pages/forgotpassword.dart';
import 'package:nostalgic_foodie/pages/signup.dart';
import 'package:nostalgic_foodie/widgets/widgets_support.dart';


class LogIn extends StatefulWidget {
  final int? total; // 1. Add this line
  const LogIn({super.key, this.total});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  bool _obscureText = true;
  bool isLoading = false;
  final _formkey = GlobalKey<FormState>();

  TextEditingController useremailcontroller = TextEditingController();
  TextEditingController userpasswordcontroller = TextEditingController();

  userLogin() async {
    if (_formkey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        // 1. Auth Check (This is the only thing we MUST wait for)
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
            email: useremailcontroller.text.trim(),
            password: userpasswordcontroller.text.trim());

        String uid = userCredential.user!.uid;

        // Admin Check
        if (useremailcontroller.text.trim().toLowerCase() == "besanrabaia@outlook.com") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeAdmin()));
          return;
        }

        // 2. RUN IN BACKGROUND: Fetch Firestore and Save SharedPref
        // We DON'T 'await' this. We let it happen while the user sees the Home screen.
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get()
            .then((userDoc) async {
          if (userDoc.exists) {
            await SharedPreferenceHelper().saveUserName(userDoc['Name']);
            await SharedPreferenceHelper().saveUserEmail(userDoc['Email']);
            await SharedPreferenceHelper().saveUserId(uid);
          }
        });

        // 3. MOVE IMMEDIATELY
        if (!mounted) return;
        setState(() => isLoading = false);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BottomNav()));

      } on FirebaseAuthException catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Login Failed")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height /2.5,
                decoration: const BoxDecoration(color: Color(0xFFFBB25A)),
              ),

              Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height /5),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40))
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        // Change top margin from 60.0 or 40.0 down to 10.0 or 20.0
                        margin: const EdgeInsets.only(top: 10.0),
                        height: 230, // Keeping it large so you can read the text
                        width: 230,
                        child: Image.asset(
                          "images/logo.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 30.0),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: Form(
                          key: _formkey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 20.0),
                              Text("Login", style: AppWidget.headlineTextFieldStyle()),
                              const SizedBox(height: 20.0),
                              TextFormField(
                                controller: useremailcontroller,
                                validator: (v) => v!.isEmpty ? 'Enter Email' : null,
                                decoration: const InputDecoration(hintText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                              ),
                              const SizedBox(height: 20.0),
                              TextFormField(
                                controller: userpasswordcontroller,
                                obscureText: _obscureText,
                                validator: (v) => v!.isEmpty ? 'Enter Password' : null,
                                decoration: InputDecoration(
                                    hintText: 'Password',
                                    prefixIcon: const Icon(Icons.password_outlined),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: const Color(0xFFFBB25A)),
                                      onPressed: () => setState(() => _obscureText = !_obscureText),
                                    )),
                              ),
                              const SizedBox(height: 20.0),
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => const ForgotPassword())),
                                child: Container(alignment: Alignment.topRight,
                                    child: Text("Forgot Password?", style: AppWidget.semiBoldTextFieldStyle())),
                              ),
                              const SizedBox(height: 30.0),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: isLoading ? null : () => userLogin(),
                                child: Material(
                                  elevation: 5.0,
                                  borderRadius: BorderRadius.circular(20.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                                    width: 200,
                                    decoration: BoxDecoration(color: const Color(0xFFFBB25A), borderRadius: BorderRadius.circular(20.0)),
                                    child: Center(
                                      child: isLoading
                                          ? const SizedBox(
                                          height: 22, width: 22,
                                          child: CircularProgressIndicator(color: Colors.white,
                                              strokeWidth: 3))
                                          : const Text("LOGIN", style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp(total: widget.total))),
                        child: Text("Don't have an account? Sign up", style: AppWidget.semiBoldTextFieldStyle())
                    ),
                    const SizedBox(height: 50.0),
                  ],
                ),
              )
            ],
          ),
        ),
    );
  }
}
