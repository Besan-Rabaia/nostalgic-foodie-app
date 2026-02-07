import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nostalgic_foodie/pages/signup.dart';
import 'package:nostalgic_foodie/pages/terms_condition.dart';
import 'package:nostalgic_foodie/service/database.dart';
import 'package:nostalgic_foodie/service/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';


class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? profile, name, email;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  @override
  void initState() {
    getthesharedpref();
    super.initState();
  }
  void _showEditNameDialog() {
    TextEditingController nameController = TextEditingController(text: name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Name"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: "Enter your name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                updateName(nameController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  getthesharedpref() async {
    // 1. Get current data from local storage
    profile = await SharedPreferenceHelper().getUserProfile();
    name = await SharedPreferenceHelper().getUserName();
    email = await SharedPreferenceHelper().getUserEmail();

    // 2. If email is empty, fetch it directly from the signed-in Firebase user
    if (email == null || email!.isEmpty) {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.email != null) {
        email = currentUser.email;
        // Save it locally so it shows up faster next time
        await SharedPreferenceHelper().saveUserEmail(email!);
      }
    }

    setState(() {});
  }

  // --- IMAGE PICKER & CLOUDINARY LOGIC ---
  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = File(image.path);
      setState(() {
        uploadItem();
      });
    }
  }
  updateName(String newName) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // 1. Update Firebase Auth (for the "Fast" welcome message)
        await user.updateDisplayName(newName);

        // 2. Update Firestore Database (for permanent storage)
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .update({"Name": newName});

        // 3. Update Local Storage (for the Home page header)
        await SharedPreferenceHelper().saveUserName(newName);

        setState(() {
          name = newName;
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Name updated successfully!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  uploadItem() async {
    if (selectedImage != null) {
      try {
        String cloudName = dotenv.env['CLOUDINARY_NAME'] ?? "fooddeliver";
        String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? "food_app";
        var request = http.MultipartRequest(
            'POST',
            Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload'));
        request.fields['upload_preset'] = uploadPreset;
        request.files.add(await http.MultipartFile.fromPath('file', selectedImage!.path));

        var response = await request.send();
        var responseData = await response.stream.bytesToString();
        var jsonData = jsonDecode(responseData);

        if (response.statusCode == 200) {
          String downloadUrl = jsonData['secure_url'];
          await SharedPreferenceHelper().saveUserProfile(downloadUrl);
          setState(() {
            profile = downloadUrl;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Profile Picture Updated Successfully!")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  // --- LOGOUT LOGIC ---
  logoutUser() async {
    await FirebaseAuth.instance.signOut();
    // Clear all local data
    await SharedPreferenceHelper().saveUserName("");
    await SharedPreferenceHelper().saveUserEmail("");
    await SharedPreferenceHelper().saveUserId("");
    await SharedPreferenceHelper().saveUserProfile("");

    if (!mounted) return;
    // Remove all previous screens and go to SignUp
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignUp()),
            (route) => false
    );
  }

  // --- DELETE ACCOUNT LOGIC ---
  deleteUserAccount() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        String uid = user.uid; // Save the ID before we delete the user

        // STEP 1: Delete the document from Firestore Database
        await DatabaseMethods().deleteUser(uid);

        // STEP 2: Delete the user from Firebase Authentication
        await user.delete();

        // STEP 3: Clear all Shared Preferences (Local data)
        await SharedPreferenceHelper().saveUserName("");
        await SharedPreferenceHelper().saveUserEmail("");
        await SharedPreferenceHelper().saveUserId("");
        await SharedPreferenceHelper().saveUserProfile("");

        if (!mounted) return;

        // STEP 4: Navigate to SignUp
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SignUp()),
                (route) => false
        );

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text("Account and data deleted successfully.")));

      } on FirebaseAuthException catch (e) {
        // Firebase security check: if the login is old, it will block the delete
        if (e.code == 'requires-recent-login') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orange,
              content: Text("Security Check: Please Log Out and Log In again to delete your account.")));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error deleting data: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      // Use the name == null check to prevent errors while loading data
      body: name == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        // Adding bottom padding allows you to scroll past the last item comfortably
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            // --- HEADER SECTION ---
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 45, left: 20, right: 20),
                  height: MediaQuery.of(context).size.height / 4.3,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.elliptical(MediaQuery.of(context).size.width, 105),
                      )),
                ),
                Center(
                  child: Stack(children: [
                    Container(
                      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 6.5),
                      child: Material(
                        elevation: 10,
                        borderRadius: BorderRadius.circular(60),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: selectedImage != null
                              ? Image.file(selectedImage!, height: 120, width: 120, fit: BoxFit.cover)
                              : (profile == null || profile!.isEmpty)
                              ? GestureDetector(
                            onTap: () => getImage(),
                            child: Container(
                              height: 120,
                              width: 120,
                              color: Colors.orangeAccent,
                              alignment: Alignment.center,
                              child: Text(
                                name != null && name!.isNotEmpty ? name![0].toUpperCase() : "U",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 50,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                              : Image.network(
                            profile!,
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return GestureDetector(
                                onTap: () => getImage(),
                                child: Container(
                                  height: 120,
                                  width: 120,
                                  color: Colors.orangeAccent,
                                  alignment: Alignment.center,
                                  child: Text(
                                    name != null ? name![0].toUpperCase() : "U",
                                    style: const TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: GestureDetector(
                        onTap: () => getImage(),
                        child: Material(
                          elevation: 3.0, shape: const CircleBorder(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt_outlined, color: Colors.black, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
                // Matches the header from your photo
                Padding(
                  padding: const EdgeInsets.only(top: 70),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(name!, style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),

            // --- INFO & ACTION CARDS ---
            // These cards are spaced out, causing the list to grow long
            _buildInfoCard(Icons.person, "Name", name!, isEditable: true, onEdit: _showEditNameDialog),
            const SizedBox(height: 20), // Reduced spacing slightly for better fit
            _buildInfoCard(Icons.email, "Email", email!),
            const SizedBox(height: 20),
            _buildClickableCard(Icons.description, "Terms and Condition", () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsAndConditions()));
            }),
            const SizedBox(height: 20),
            _buildClickableCard(Icons.delete, "Delete Account", () {
              _showConfirmationDialog("Delete Account", "Are you sure you want to delete your account permanently?", deleteUserAccount);
            }),
            const SizedBox(height: 20),
            _buildClickableCard(Icons.logout, "LogOut", () {
              _showConfirmationDialog("LogOut", "Are you sure you want to log out?", logoutUser);
            }),
            // Final spacing to ensure LogOut is easy to tap
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- HELPERS ---
  Widget _buildInfoCard(IconData icon, String title, String value, {bool isEditable = false, VoidCallback? onEdit}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Icon(icon, color: Colors.black),
              const SizedBox(width: 20),
              Expanded( // Expanded allows the text to take up space without pushing the icon off screen
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                    Text(value, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                  ],
                ),
              ),
              if (isEditable)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black54, size: 20),
                  onPressed: onEdit,
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClickableCard(IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Material(
          borderRadius: BorderRadius.circular(10),
          elevation: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Icon(icon, color: Colors.black),
                const SizedBox(width: 20),
                Text(text, style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () { Navigator.pop(context); onConfirm(); }, child: const Text("Yes", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}