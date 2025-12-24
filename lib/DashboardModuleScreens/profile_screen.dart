import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expence_tracker/CommonWidgets/app_buittons.dart';
import 'package:expence_tracker/CommonWidgets/app_lables.dart';
import 'package:expence_tracker/CommonWidgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  DocumentSnapshot? userData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          setState(() {
            userData = doc;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = "User data not found.";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "No user logged in.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching user data: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 240, 245, 250),
      appBar: CustomAppBar(
        title: "User Profile",
        subTitle: "You can handle your profile here.",
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF097D94)),
              )
            : errorMessage.isNotEmpty
            ? Center(
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Top Gradient Profile Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundImage:
                                // (userData?['profilePic'] != null &&
                                //     userData!['profilePic']
                                //         .toString()
                                //         .isNotEmpty)
                                // ? NetworkImage(userData!['profilePic'])
                                // : const AssetImage('assets/user.png')
                                //       as ImageProvider,
                                const NetworkImage('https://docs.flutter.dev/assets/images/dash/dash-fainting.gif')
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "${userData?['firstName']} ${userData?['lastName']}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userData?['emailId'] ?? '',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Info Card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppLabel.title(
                              "Personal Information",
                              Colors.deepPurpleAccent,
                            ),
                            const SizedBox(height: 15),
                            infoRow("First Name", userData?['firstName']),
                            infoRow("Last Name", userData?['lastName']),
                            infoRow("Email Id", userData?['emailId']),
                            infoRow("Address", userData?['address']),
                            infoRow("Mobile No.", userData?['mobileNumber']),
                            infoRow("Aadhaar No.", userData?['adhaarNumber']),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Logout Button
                    AppButton(
                      text: "LogOut",
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Get.offAllNamed('/LoginPage');
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(flex: 3, child: AppLabel.body("$label :", Colors.black12)),

          Expanded(flex: 5, child: AppLabel.body(value, Colors.black87)),
        ],
      ),
    );
  }
}
