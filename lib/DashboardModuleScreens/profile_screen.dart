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
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
      }
    } catch (e) {
      errorMessage = "Unable to load profile";
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: const CustomAppBar(
        title: "Profile",
        subTitle: "Your account information",
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _compactHeader(),
                      const SizedBox(height: 20),
                      _sectionCard(
                        title: "Personal Details",
                        children: [
                          infoTile(Icons.person, "First Name",
                              userData?['firstName']),
                          infoTile(Icons.person_outline, "Last Name",
                              userData?['lastName']),
                          infoTile(Icons.email_outlined, "Email",
                              userData?['emailId']),
                          infoTile(Icons.phone_android, "Mobile",
                              userData?['mobileNumber']),
                          infoTile(Icons.badge, "Aadhar Number",
                              userData?['adhaarNumber']),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _sectionCard(
                        title: "Address",
                        children: [
                          infoTile(Icons.location_on_outlined, "Address",
                              userData?['address']),
                        ],
                      ),
                      const SizedBox(height: 32),
                      AppButton(
                        text: "Logout",
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Get.offAllNamed('/LoginPage');
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  /// ---------- COMPACT HEADER ----------
  Widget _compactHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFEEF2FF),
            child: Icon(Icons.person, size: 30, color: Colors.indigo),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${userData?['firstName']} ${userData?['lastName']}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userData?['emailId'] ?? '',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ---------- SECTION CARD ----------
  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppLabel.body(title, Colors.indigo),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  /// ---------- INFO TILE ----------
  Widget infoTile(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.indigo),
          const SizedBox(width: 12),
          Expanded(
            child: 
            AppLabel.caption(label, Colors.grey),
          ),
          AppLabel.caption(value?.toString() ?? "-", Colors.black),
        ],
      ),
    );
  }
}
