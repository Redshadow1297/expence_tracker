import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expence_tracker/DashboardModuleScreens/expenserelatedscreens/add_expences_UI.dart';
import 'package:expence_tracker/CommonWidgets/app_lables.dart';
import 'package:expence_tracker/CommonWidgets/custom_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String selectedMonth = "${DateTime.now().month}-${DateTime.now().year}";

  // Month dropdown widget
  Widget buildMonthDropdown() {
    return DropdownButton<String>(
      value: selectedMonth,
      items: List.generate(12, (i) {
        final monthYear = "${i + 1}-${DateTime.now().year}";
        return DropdownMenuItem(
          value: monthYear,
          child: Text("Month ${i + 1}"),
        );
      }),
      onChanged: (value) {
        setState(() => selectedMonth = value!);
      },
    );
  }

  // Filter expenses by month
  List<QueryDocumentSnapshot> filterByMonth(
    List<QueryDocumentSnapshot> docs,
    String monthYear,
  ) {
    final parts = monthYear.split('-');
    final month = int.parse(parts[0]);
    final year = int.parse(parts[1]);

    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final date = (data['expenseDate'] as Timestamp).toDate();
      return date.month == month && date.year == year;
    }).toList();
  }

  // Total spent per category (if needed later)
  Map<String, double> calculateCategoryTotals(
    List<QueryDocumentSnapshot> docs,
  ) {
    Map<String, double> categoryTotals = {};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final category = data['category'] ?? 'Other';
      final amount = (data['amount'] as num).toDouble();
      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
    }
    return categoryTotals;
  }

  // Single expense tile
  Widget _buildExpenseTile(
    String title,
    String category,
    String amount,
    String date,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(Icons.circle, size: 12, color: Colors.deepPurple),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category, style: TextStyle(color: Colors.grey)),
            Text(date, style: TextStyle(color: Colors.grey)),
          ],
        ),
        trailing: Text(
          "₹$amount",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 240, 245, 250),
      appBar : CustomAppBar(title: "Expenses", subTitle: "Manage your monthly and daily expenses here"),
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   backgroundColor: const Color(0xFF097D94),
      //   elevation: 4,
      //   title: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: const [
      //       Text(
      //         "Expenses",
      //         style: TextStyle(
      //           color: Colors.white,
      //           fontWeight: FontWeight.bold,
      //         ),
      //       ),
      //       SizedBox(height: 2),
      //       Text(
      //         "Manage your monthly and daily expenses here",
      //         style: TextStyle(fontSize: 12, color: Colors.white70),
      //       ),
      //     ],
      //   ),
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(AddExpenseUI()),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('expenses')
            .where('uId', isEqualTo: userId)
            // .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: AppLabel.body("No expenses added yet", Colors.black54),);
          }

          final allDocs = snapshot.data!.docs;
          final filteredDocs = filterByMonth(allDocs, selectedMonth);

          double totalSpent = filteredDocs.fold(
            0,
            (sum, doc) => sum + (doc['amount'] as num).toDouble(),
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Month Filter Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Month Filter:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      buildMonthDropdown(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Total Spent Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                color: const Color.fromARGB(178, 5, 147, 2),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Total Spent",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "₹${totalSpent.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Category-wise placeholder
              const Text(
                "Category-wise Expenses",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // SizedBox(height: 200, child: buildPieChart(categoryTotals)),
              const SizedBox(height: 20),

              // Recent Expenses
              const Text(
                "Recent Expenses",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...filteredDocs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final date = (data['expenseDate'] as Timestamp).toDate();
                final formattedDate = DateFormat('dd MMM yyyy').format(date);

                return _buildExpenseTile(
                  data['title'] ?? '',
                  data['category'] ?? '',
                  data['amount'].toString(),
                  formattedDate,
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
