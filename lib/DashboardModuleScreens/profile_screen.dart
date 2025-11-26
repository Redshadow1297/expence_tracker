import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key, required this.userID});
  final String userID;
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  DocumentSnapshot? userData;
  bool isLoading = true;
  String errorMessage = '';

  Future<void> getUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = 'No user is currently logged in.';
          isLoading = false;
        });
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userID)
          .get();

      if (userDoc.exists) {
        setState(() {
          userData = userDoc;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'User data not found.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load user data: $e';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("User Profile", style: TextStyle(color: Colors.white)),
            Text(
              "Manage your profile information",
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 2, 125, 148),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : buildProfileInfo(),
        ),
      ),
    );
  }

  Widget buildProfileInfo() {
    if (userData == null) {
      return Center(child: Text('No profile data available.'));
    } else {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          elevation: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              rowForDataFields(
                "First Name : ",
                userData!['first_name'] ?? 'N/A',
              ),
              rowForDataFields("Last Name : ", userData!['last_name'] ?? 'N/A'),
              rowForDataFields("Email : ", userData!['email'] ?? 'N/A'),
              rowForDataFields("Phone : ", userData!['mobileNumber'] ?? 'N/A'),
              rowForDataFields("Address : ", userData!['address'] ?? 'N/A'),
              rowForDataFields(
                "ID Number : ",
                userData!['adhaarNumber'] ?? 'N/A',
              ),
            ],
          ),
        ),
      );
    }
  }

  // Utility method for displaying rows of profile data
  Widget rowForDataFields(String fieldName, String fieldValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            fieldName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(fieldValue, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
