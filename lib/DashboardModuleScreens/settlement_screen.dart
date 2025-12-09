import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class SettlementsScreen extends StatefulWidget {
  const SettlementsScreen({super.key});

  @override
  State<SettlementsScreen> createState() => _SettlementsScreenState();
}

class _SettlementsScreenState extends State<SettlementsScreen> {
  Future<Map<String, dynamic>> fetchAllExpenseData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('expenses').get();

    Map<String, dynamic> allExpenses = {};

    for (var doc in snapshot.docs) {
      allExpenses[doc.id] = doc.data();
    }

    return allExpenses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  "Settlements",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                SafeArea(
                  child: Text(
                    "You can see the settlements here.",
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [_allExpencesList()]),
        ),
      ),
    );
  }

  Widget _allExpencesList() {
    return Expanded(
      child: FutureBuilder<Map<String, dynamic>>(
        future: fetchAllExpenseData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No expenses found.'));
          } else {
            final expenses = snapshot.data!;
            return ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                // final expenseId = expenses.keys.elementAt(index);
                // final expenseData = expenses[expenseId];
                return ListTile(
                  title: Text('Expense Item ${index + 1}'),
                  subtitle: Text('Date: ${expenses['date']}'),
                  trailing: Text('Amount: \$${expenses['amount']}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
