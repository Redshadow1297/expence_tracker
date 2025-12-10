import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();

  User? get currentUser => FirebaseAuth.instance.currentUser;
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Map<String, dynamic>> modules = [
    {"title": "Profile", "icon": Icons.person},
    {"title": "Expenses", "icon": Icons.receipt_long},
    {"title": "Roommates", "icon": Icons.group},
    {"title": "Settlements", "icon": Icons.swap_horiz},
    {"title": "Reports", "icon": Icons.bar_chart},
    {"title": "Settings", "icon": Icons.settings},
  ];

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
  // void _logout(BuildContext context) async {
  //   try {
  //     await FirebaseAuth.instance.signOut();
  //     Get.offAllNamed('/LoginPage');
  //     Get.snackbar(
  //       "Logged Out",
  //       "You have successfully logged out!",
  //       backgroundColor: Colors.amberAccent,
  //     );
  //   } catch (e) {
  //     Get.snackbar("Error", "Error logging out: $e");
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Color.fromARGB(255, 9, 125, 148),
        elevation: 4,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dashboard",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "Manage your modules and explore your data.",
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
            // InkWell(
            //   onTap: () => _logout(context),
            //   borderRadius: BorderRadius.circular(30),
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: Icon(Icons.logout_outlined, size: 30, color: Colors.white),
            //   ),
            // ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Welcome Card
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                child: Container(
                  padding: EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.blue.shade50,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.dashboard, size: 40, color: Color.fromARGB(255, 9, 125, 148)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Welcome to Your Dashboard!",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Modules Grid
              Expanded(
                child: GridView.builder(
                  itemCount: modules.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          try {
                            Get.toNamed(
                                modules[index]['title'].toString().toLowerCase());
                          } catch (e) {
                            print("Navigation error: $e");
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: buildModulesCard(
                          modules[index]["title"], modules[index]["icon"]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildModulesCard(String moduleName, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: getRandomGradient(),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Colors.white),
              SizedBox(height: 8),
              Text(
                moduleName,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
