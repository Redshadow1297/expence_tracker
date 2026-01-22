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

  // Month Dropdown
  Widget _monthDropdown() {
    return DropdownButton<String>(
      value: selectedMonth,
      underline: const SizedBox(),
      items: List.generate(12, (i) {
        final value = "${i + 1}-${DateTime.now().year}";
        return DropdownMenuItem(
          value: value,
          child: Text(DateFormat.MMMM().format(DateTime(0, i + 1))),
        );
      }),
      onChanged: (val) => setState(() => selectedMonth = val!),
    );
  }

  List<QueryDocumentSnapshot> _filterByMonth(List<QueryDocumentSnapshot> docs) {
    final parts = selectedMonth.split('-');
    final month = int.parse(parts[0]);
    final year = int.parse(parts[1]);

    return docs.where((doc) {
      if (!doc.data().toString().contains('expenseDate')) return false;

      final rawDate = doc['expenseDate'];

      if (rawDate == null || rawDate is! Timestamp) return false;

      final date = rawDate.toDate();

      return date.month == month && date.year == year;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 245, 250),
      appBar: const CustomAppBar(
        title: "Expenses",
        subTitle: "Track and manage your spending",
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const AddExpenseUI()),
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Expense", style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('expenses')
            .where('paidBy', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: AppLabel.body("No expenses added yet", Colors.black54),
            );
          }

          // final filteredDocs = _filterByMonth(snapshot.data!.docs);
          final filteredDocs = _filterByMonth(snapshot.data!.docs);
          if (filteredDocs.isEmpty) {
            return const Center(
              child: Text(
                "No expenses for selected month",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final totalSpent = filteredDocs.fold<double>(
            0,
            (sum, doc) => sum + (doc['amount'] as num).toDouble(),
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.bar_chart,
                        size: 36,
                        color: Color(0xFF097D94),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: 
                        AppLabel.body("Overview of your monthly expenses", Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Month Filter
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppLabel.caption("Select Month", Colors.black),
                      _monthDropdown(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              //  Total Spent
              Card(
                elevation: 4,
                color: Colors.green.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppLabel.caption("Total Spent", Colors.white),
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
              const SizedBox(height: 24),

              //  Recent Expenses
              AppLabel.title("Recent Expenses", Colors.black),
              const SizedBox(height: 12),
              ...filteredDocs.map(
                (doc) => _expenseTile(doc.data() as Map<String, dynamic>),
              ),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Widget _expenseTile(Map<String, dynamic> data) {
    final date = DateFormat(
      'dd MMM yyyy',
    ).format((data['expenseDate'] as Timestamp).toDate());

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.deepPurple.shade100,
          child: const Icon(Icons.receipt, color: Colors.blueGrey),
        ),
        title: 
        AppLabel.body(data['title'] ??'', Colors.black),
        
        subtitle: Text("${data['category']} • $date"),
        trailing: Text(
          "₹${data['amount']}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
