import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key,this.userID, this.emailID});

  final String? userID;
  final String? emailID;
  
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();

  User? get currentUser => FirebaseAuth.instance.currentUser;
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Map<String, dynamic>> modules = [
    ///Temp. Added manually will get it from firebase directly
    {"title": "Profile", "icon": Icons.person},
    {"title": "Expenses", "icon": Icons.receipt_long},
    {"title": "Roommates", "icon": Icons.group},
    {"title": "Settlements", "icon": Icons.swap_horiz},
    {"title": "Reports", "icon": Icons.bar_chart},
    {"title": "Settings", "icon": Icons.settings},
  ];
  //  bool _isNavigating = false;

  LinearGradient getRandomGradient() {
    final gradients = [
      LinearGradient(colors: [Color(0xFF6a85b6), Color(0xFFbac8e0)]),
      LinearGradient(colors: [Color(0xFF26C6DA), Color(0xFF00ACC1)]),
      LinearGradient(colors: [Color(0xFFABDCFF), Color(0xFF0396FF)]),
      LinearGradient(colors: [Color(0xFFFF9A8B), Color(0xFFFF6A88)]),
      LinearGradient(colors: [Color(0xFFB5FFFC), Color(0xFF00FFCC)]),
      LinearGradient(colors: [Color(0xFFFAFFD1), Color(0xFFA1FFCE)]),
    ];
    gradients.shuffle();
    return gradients.first;
  }

  // Function to log the user out
  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.snackbar(
        "LogOut",
        "You haved logged out !",
        backgroundColor: Colors.yellowAccent,
      );
      Get.offAllNamed('/LoginPage');
    } catch (e) {
      Get.snackbar("error", "Error logging out: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Dashboard", style: TextStyle(color: Colors.white)),
                Text(
                  "Manage your modules and explore your data.",
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                _logout(context);
                // Get.offAllNamed('/LoginPage');
              },
              child: Icon(Icons.logout_outlined, size: 33),
            ),
          ],
        ),
        backgroundColor: const Color.from(
          alpha: 1,
          red: 0.035,
          green: 0.49,
          blue: 0.58,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                "Welcome to Your Dashboard!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          buildGridsForModules(),
        ],
      ),
    );
  }

  Widget buildGridsForModules() {
    return Expanded(
      child: GridView.builder(
        itemCount: modules.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Future.delayed(Duration(milliseconds: 100), () {
                try {
                  Get.toNamed(
                    modules[index]['title'].toString().toLowerCase(),
                    arguments: widget.userID,
                  );
                  print("user Id for profile selected is:  ${widget.userID}"); 
                } catch (e) {
                  // Handle any errors that may occur during navigation
                  print("Navigation error: $e");
                }
              });
            },

            child: buildModulesCard(
              modules[index]["title"],
              modules[index]["icon"],
            ),
          );
        },
      ),
    );
  }

  Widget buildModulesCard(String moduleName, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          // gradient: SweepGradient(
          //   colors: [Color(0xFF117972), Color(0xFF26DC9F), Color(0xFF43E8A3)],
          // ),
          gradient: getRandomGradient(),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                moduleName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Icon(icon, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}
