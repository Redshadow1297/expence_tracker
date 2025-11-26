import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
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
                  "Here you can manage your expenses and data",
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                // Get.off(() => LoginScreen());
                Get.offAllNamed('/LoginPage');
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
      body: SafeArea(
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
                Get.toNamed(
                  modules[index]['title'].toString().toLowerCase(),
                ); //Navigation to modules screen
              },
              child: buildModulesCard(
                modules[index]["title"],
                modules[index]["icon"],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildGridsForModules() {
    return GridView.builder(
      itemCount: modules.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Get.toNamed(
              modules[index]['title'].toString().toLowerCase(),
            ); //Navigation to modules screen
          },
          child: buildModulesCard(
            modules[index]["title"],
            modules[index]["icon"],
          ),
        );
      },
    );
  }

  Widget buildModulesCard(String moduleName, IconData icon) {
    return Card(
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
