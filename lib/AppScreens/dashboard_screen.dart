import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expence_tracker/CommonWidgets/app_lables.dart';
import 'package:expence_tracker/CommonWidgets/custom_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_ai_chatbot/flutter_ai_chatbot.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final List<Map<String, dynamic>> modules = [
    {"title": "Profile", "icon": Icons.person, "route": "/profile"},
    {"title": "Roommates", "icon": Icons.group, "route": "/roommates"},
    {"title": "Expenses", "icon": Icons.receipt_long, "route": "/showexpenses"},
    {
      "title": "Settlements",
      "icon": Icons.account_balance_wallet,
      "route": "/settlements",
    },
    {"title": "Reports", "icon": Icons.bar_chart, "route": "/reports"},
    {"title": "Settings", "icon": Icons.settings, "route": "/forgetPassword"},
  ];

  @override
  void initState() {
    super.initState();
    initFCM();
    getPresentDays();
    getTotalExpense();
  }

  //---------------------------------- FCM Initialization ------------------

  Future<void> initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(alert: true, badge: true, sound: true);

    final token = await messaging.getToken();
    if (token == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'fcmToken': token,
    }, SetOptions(merge: true));

    debugPrint("FCM Token saved");
  }

  // -------------------------------------- User Details To show On Dashboard -------------------------------------
  Future<int> getPresentDays() async {
    final user = FirebaseAuth.instance.currentUser!;
    final snapshot = await FirebaseFirestore.instance
        .collection('expenses')
        .where('presentMembers', arrayContains: user.uid)
        .get();

    final uniqueDays = snapshot.docs.map((doc) {
      final ts = doc['expenseDate'] as Timestamp;
      final d = ts.toDate();
      return "${d.year}-${d.month}-${d.day}";
    }).toSet();

    return uniqueDays.length;
  }

  Future<double> getTotalExpense() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    final snapshot = await FirebaseFirestore.instance
        .collection('expenses')
        .where('presentMembers', arrayContains: user.uid)
        .get();

    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc['amount'] as num).toDouble();
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 245, 250),
      appBar: const CustomAppBar(
        title: "Dashboard",
        subTitle: "Manage your expenses",
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _welcomeCard(),
          const SizedBox(height: 20),
          AppLabel.title("Quick View", Colors.indigoAccent),
           const SizedBox(height: 12),
          _userDetails(),
          const SizedBox(height: 24),
          AppLabel.title("Things You Can Do", Colors.indigoAccent),
          const SizedBox(height: 12),
          _quickActions(),
          const SizedBox(height: 24),
          AppLabel.title("Explore More", Colors.indigoAccent),
          const SizedBox(height: 12),
          ...modules.map(_moduleTile).toList(),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF097D94),
        onPressed: _openChatBot,
        child: const Icon(Icons.chat),
      ),
    );
  }

  //  Welcome Card
  Widget _welcomeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.dashboard, size: 40, color: Color(0xFF097D94)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Welcome \nManage your room expenses smartly",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //User Details On Dashboard
  Widget _userDetails() {
    return FutureBuilder(
      future: Future.wait([getPresentDays(), getTotalExpense()]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text(
            snapshot.error.toString(),
            style: const TextStyle(color: Colors.red),
          );
        }

        final presentDays = snapshot.data![0];
        final totalExpense = snapshot.data![1];
        return Row(
          children: [
            Expanded(
              child: _dashboardCard(
                title: "$presentDays",
                subtitle: "Present Days",
                icon: Icons.calendar_today,
                colors:[Color(0xFFB993D6), Color(0xFF8CA6DB)],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _dashboardCard(
                title: "$totalExpense",
                subtitle: "Individual Expense",
                icon: Icons.currency_rupee,
                colors: [Color(0xFFB993D6), Color(0xFF8CA6DB)],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _dashboardCard({
    required String title,
    required String subtitle,
    required List<Color> colors,
    IconData? icon,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  Quick Actions
  Widget _quickActions() {
    return Row(
      children: [
        Expanded(
          child: _quickActionCard(
            title: "Add Expense",
            icon: Icons.add,
            color: Colors.green,
            route: "/addexpenses",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickActionCard(
            title: "Settlements",
            icon: Icons.swap_horiz,
            color: Colors.orange,
            route: "/settlements",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickActionCard(
            title: "Reports",
            icon: Icons.swap_horiz,
            color: Colors.blueGrey,
            route: "/reports",
          ),
        ),
      ],
    );
  }

  Widget _quickActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (Get.isBottomSheetOpen == true) {
          Get.back(); // close bottom sheet
          Future.microtask(() => Get.toNamed(route));
        } else {
          Get.toNamed(route);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  Module List Tile
  Widget _moduleTile(Map<String, dynamic> module) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(module['icon'], color: const Color(0xFF097D94)),
        title: Text(
          module['title'],
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (Get.isBottomSheetOpen == true) {
            Get.back();
            Future.microtask(() => Get.toNamed(module['route']));
          } else {
            Get.toNamed(module['route']);
          }
        },
      ),
    );
  }

  //  ChatBot Bottom Sheet
  void _openChatBot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          child: ChatBotWidget(
            apiKey: 'YOUR_GEMINI_API_KEY',
            aiService: AIService.gemini,
            initialMessage:
                "Hi! I can help you with expenses, settlements, and reports.",
            primaryColor: const Color(0xFF097D94),
            headerTitle: 'Expense Assistant',
            headerIcon: Icons.smart_toy,
            chatIcon: Icons.chat_bubble_rounded,
          ),
        );
      },
    );
  }
}
