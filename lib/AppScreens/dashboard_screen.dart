import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_ai_chatbot/flutter_ai_chatbot.dart';

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
  
  set welcomeText(String welcomeText) {
    // This is a placeholder setter for welcomeText.
    // The actual implementation would depend on the ChatBotWidget's API. 
    welcomeText = welcomeText;
    
  }

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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Manage your modules and explore your data.",
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
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
                          Icon(
                            Icons.dashboard,
                            size: 40,
                            color: Color.fromARGB(255, 9, 125, 148),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Welcome to Your Dashboard!",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
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
                            Get.toNamed(
                              modules[index]['title'].toString().toLowerCase(),
                            );
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: buildModulesCard(
                            modules[index]["title"],
                            modules[index]["icon"],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 20,
              right: 20,
              child: SizedBox(
                height: 200,
                width: 150,
                child: ChatBotWidget(
                  apiKey: 'AIzaSyBOFiwEG4iveydThdNCtM_-MPC93ZVXVNY', 
                  aiService:
                      AIService.gemini,
                  initialMessage: welcomeText = "👋 Hi! I’m here to help you with expenses, reports, and settings.",
                  primaryColor: Color(0xFF097D94),
                  chatIcon: Icons.chat, 
                  clearHistoryOnClose: true,
                  headerTitle: 'My Chattee',
                  headerIcon: Icons.smart_toy,
                ),
              ),
            ),
          ],
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
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
