import 'package:expence_tracker/CommonWidgets/app_lables.dart';
import 'package:expence_tracker/CommonWidgets/custom_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    {"title": "Settlements", "icon": Icons.account_balance_wallet, "route": "/settlements"},
    {"title": "Reports", "icon": Icons.bar_chart, "route": "/reports"},
    {"title": "Settings", "icon": Icons.settings, "route": "/forgetPassword"},
  ];

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
          _quickActions(),
          const SizedBox(height: 24),
          AppLabel.title("More Options", Colors.indigoAccent),
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

  // 🔹 Welcome Card
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

  // 🔹 Quick Actions
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
      onTap: () => Get.toNamed(route),
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

  // 🔹 Module List Tile
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
        onTap: () => Get.toNamed(module['route']),
      ),
    );
  }

  // 🔹 ChatBot Bottom Sheet
  void _openChatBot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: ChatBotWidget(
            apiKey: 'YOUR_GEMINI_API_KEY',
            aiService: AIService.gemini,
            initialMessage:
                " Hi! I can help you with expenses, settlements, and reports.",
            primaryColor: const Color(0xFF097D94),
            headerTitle: 'Expense Assistant',
            headerIcon: Icons.smart_toy,
          ),
        );
      },
    );
  }
}
