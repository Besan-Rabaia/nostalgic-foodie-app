import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nostalgic_foodie/pages/bottom_nav.dart';
import 'package:nostalgic_foodie/pages/cart.dart';
import 'package:nostalgic_foodie/pages/login.dart';
import 'package:nostalgic_foodie/service/database.dart';
import 'package:nostalgic_foodie/service/shared_pref.dart';
import 'package:nostalgic_foodie/widgets/widgets_support.dart';

class SignUp extends StatefulWidget {
  final int? total; // 1. Add this line
  const SignUp({super.key, this.total});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool isLoading = false;
  bool _obscureText = true;

  TextEditingController namecontroller = TextEditingController();
  TextEditingController mailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  // --- New Registration Logic ---
  registration() async {
    if (passwordcontroller.text != "" &&
        namecontroller.text != "" &&
        mailcontroller.text != "") {
      setState(() {
        isLoading = true;
      });
      try {
        // 1. Get the current Anonymous/Guest User
        User? guestUser = FirebaseAuth.instance.currentUser;

        // 2. Prepare the Email/Password Credentials
        AuthCredential credential = EmailAuthProvider.credential(
            email: mailcontroller.text.trim(),
            password: passwordcontroller.text.trim());

        String userId;

        if (guestUser != null && guestUser.isAnonymous) {
          // 🔥 MAGIC STEP: Link guest data to permanent account
          // This keeps the SAME ID so the items stay in the cart!
          UserCredential userCredential = await guestUser.linkWithCredential(
              credential);
          userId = userCredential.user!.uid;
        } else {
          // Fallback: Just create a new user if no guest exists
          UserCredential userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
              email: mailcontroller.text.trim(),
              password: passwordcontroller.text.trim());
          userId = userCredential.user!.uid;
          await SharedPreferenceHelper().saveUserName(
              namecontroller.text.trim());
        }

        // 3. Send Verification Email
        await FirebaseAuth.instance.currentUser?.sendEmailVerification();

        // 4. Save to Firestore (using the same ID)
        Map<String, dynamic> addUserInfo = {
          "Name": namecontroller.text.trim(),
          "Email": mailcontroller.text.trim(),
          "Id": userId,
          "isAdmin": false,
        };
        await DatabaseMethods().addUserDetail(addUserInfo, userId);
        await SharedPreferenceHelper().saveUserId(userId);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Account Created! Items Saved.")));

        // 5. Navigate to Cart
        if (widget.total != null && widget.total! > 0) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Cart())
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomNav()),
          );
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.code)));
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
            // 1. Header Background
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: MediaQuery
                  .of(context)
                  .size
                  .height / 2.5,
              decoration: const BoxDecoration(color: Color(0xFFFBB25A)),
            ),

            Container(
              // 2. Push everything to the very top to match Login screen
              margin: EdgeInsets.only(top: MediaQuery
                  .of(context)
                  .size
                  .height / 15),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      // 3. Significantly larger logo
                      height: 230,
                      width: 230,
                      child: Image.asset(
                        "images/logo.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // 4. Transform.translate pulls the box UP over the orange header
                  Transform.translate(
                    offset: const Offset(0, 2),
                    // Adjust this value to bring it higher/lower
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0,
                              vertical: 30.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: Form(
                            key: _formkey,
                            child: Column(
                              children: [
                                Text("Sign up",
                                    style: AppWidget.headlineTextFieldStyle()),
                                const SizedBox(height: 30),
                                TextFormField(
                                  controller: namecontroller,
                                  validator: (value) =>
                                  value!.isEmpty
                                      ? "Enter Name"
                                      : null,
                                  decoration: const InputDecoration(
                                      hintText: 'Name',
                                      prefixIcon: Icon(Icons.person_outline)),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: mailcontroller,
                                  validator: (value) =>
                                  value!.isEmpty
                                      ? "Enter Email"
                                      : null,
                                  decoration: const InputDecoration(
                                      hintText: 'Email',
                                      prefixIcon: Icon(Icons.email_outlined)),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: passwordcontroller,
                                  validator: (value) =>
                                  value!.length < 6
                                      ? "Password must be 6+ chars"
                                      : null,
                                  obscureText: _obscureText,
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    prefixIcon: const Icon(
                                        Icons.password_outlined),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscureText
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                      onPressed: () =>
                                          setState(() =>
                                      _obscureText = !_obscureText),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),
                                GestureDetector(
                                  onTap: () {
                                    if (_formkey.currentState!.validate()) {
                                      registration();
                                    }
                                  },
                                  child: Material(
                                    elevation: 5.0,
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      width: 200,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      decoration: BoxDecoration(
                                          color: const Color(0xFFFBB25A),
                                          borderRadius: BorderRadius.circular(
                                              20)),
                                      child: Center(
                                        child: isLoading
                                            ? const SizedBox(height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2))
                                            : const Text("SIGN UP",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 5. Navigation text moved outside the transform for better spacing
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: () =>
                        Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const LogIn())),
                    child: Text("Already have an account? Login",
                        style: AppWidget.semiBoldTextFieldStyle()),
                  ),
                  const SizedBox(height: 40),
                  // Bottom padding for scrolling
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}