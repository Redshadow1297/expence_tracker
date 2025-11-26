import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
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
    );
  }
}
