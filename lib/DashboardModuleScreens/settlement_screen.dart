import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expence_tracker/CommonWidgets/app_lables.dart';
import 'package:expence_tracker/CommonWidgets/custom_appbar.dart';
import 'package:expence_tracker/model/settlement_model.dart';
import 'package:flutter/material.dart';

enum Period { weekly, monthly, yearly }

class SettlementsScreen extends StatefulWidget {
  const SettlementsScreen({super.key});

  @override
  State<SettlementsScreen> createState() => _SettlementsScreenState();
}

class _SettlementsScreenState extends State<SettlementsScreen> {
  Period selectedPeriod = Period.weekly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 245, 250),
      appBar: const CustomAppBar(
        title: "Settlements",
        subTitle: "Clear who owes whom",
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _periodSelector(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('expenses')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No expenses found"));
                }

                final filteredDocs =
                    _filterByPeriod(snapshot.data!.docs, selectedPeriod);

                if (filteredDocs.isEmpty) {
                  return const Center(
                      child: Text("No expenses in this period"));
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _summaryCard(filteredDocs),
                    const SizedBox(height: 20),
                    AppLabel.title("All Expenses", Colors.purpleAccent),
                    const SizedBox(height: 10),
                    ..._expenseCards(filteredDocs),
                    const SizedBox(height: 30),
                    AppLabel.title("Settlements", Colors.purpleAccent),
                    const SizedBox(height: 10),
                    ..._settlementCards(filteredDocs),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- PERIOD SELECTION ----------------
  Widget _periodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: Period.values.map((p) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: ChoiceChip(
            label: Text(p.name.toUpperCase()),
            selected: selectedPeriod == p,
            onSelected: (_) {
              setState(() {
                selectedPeriod = p;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  /// ---------------- FILTER BY PERIOD ----------------
  List<QueryDocumentSnapshot> _filterByPeriod(
      List<QueryDocumentSnapshot> docs, Period period) {
    final now = DateTime.now();

    return docs.where((doc) {
      final Timestamp? t = (doc.data() as Map<String, dynamic>)['createdAt'];
      if (t == null) return false;
      final date = t.toDate();

      switch (period) {
        case Period.weekly:
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          return date.isAfter(weekStart);
        case Period.monthly:
          return date.year == now.year && date.month == now.month;
        case Period.yearly:
          return date.year == now.year;
      }
    }).toList();
  }

  /// ---------------- SUMMARY CARD ----------------
  Widget _summaryCard(List<QueryDocumentSnapshot> docs) {
    double total = 0;
    Set<String> members = {};

    for (var d in docs) {
      final data = d.data() as Map<String, dynamic>;
      total += (data['amount'] ?? 0).toDouble();
      final present = List<String>.from(data['presentMembers'] ?? []);
      final absent = List<String>.from(data['absentMembers'] ?? []);
      members.addAll(present);
      members.addAll(absent); // include absent members
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.deepPurple,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Total Expenses", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text("₹${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 6),
            Text("Members: ${members.length}",
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  /// ---------------- EXPENSE LIST ----------------
  List<Widget> _expenseCards(List<QueryDocumentSnapshot> docs) {
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final amount = data['amount'];
      final category = data['category'] ?? 'N/A';
      final Timestamp? t = data['createdAt'];
      final date = t?.toDate();

      final presentMembers = List<String>.from(data['presentMembers'] ?? []);
      final absentMembers = List<String>.from(data['absentMembers'] ?? []);
      final splitDetails =
          Map<String, dynamic>.from(data['splitDetails'] ?? {});

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ExpansionTile(
          leading: const Icon(Icons.receipt_long, color: Colors.deepPurple),
          title: AppLabel.body(category, Colors.black),
          subtitle: AppLabel.caption(
              date != null ? date.toString().split(' ')[0] : 'N/A',
              Colors.grey),
          trailing: AppLabel.body("₹$amount", Colors.green),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Present Members", style: TextStyle(fontWeight: FontWeight.bold)),
                  ...presentMembers.map((uid) {
                    final amt = splitDetails[uid]?.toDouble() ?? 0;
                    return Text("$uid : ₹$amt");
                  }),
                  const SizedBox(height: 8),
                  const Text("Absent Members", style: TextStyle(fontWeight: FontWeight.bold)),
                  ...absentMembers.map((uid) => Text("$uid : ₹0")),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  /// ---------------- CALCULATE BALANCE USING splitDetails ----------------
  Map<String, double> _calculateBalance(List<QueryDocumentSnapshot> docs) {
    Map<String, double> balance = {};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final paidBy = data['paidBy'] as String?;
      final splitDetails =
          Map<String, dynamic>.from(data['splitDetails'] ?? {});

      if (paidBy == null) continue;

      // Credit the payer
      balance[paidBy] = (balance[paidBy] ?? 0) + (data['amount']?.toDouble() ?? 0);

      // Debit each member (absent will have 0 automatically)
      splitDetails.forEach((uid, amt) {
        balance[uid] = (balance[uid] ?? 0) - (amt?.toDouble() ?? 0);
      });
    }

    return balance;
  }

  /// ---------------- COMPUTE SETTLEMENTS ----------------
  List<Settlement> _computeSettlements(Map<String, double> balance) {
    List<Settlement> settlements = [];
    final debtors = balance.entries.where((e) => e.value < 0).toList();
    final creditors = balance.entries.where((e) => e.value > 0).toList();

    for (var d in debtors) {
      double debt = -d.value;
      for (var c in creditors) {
        double credit = balance[c.key] ?? 0;
        if (debt <= 0 || credit <= 0) continue;

        final pay = debt < credit ? debt : credit;
        settlements.add(Settlement(d.key, c.key, pay));

        debt -= pay;
        balance[c.key] = credit - pay;
      }
    }

    return settlements;
  }

  /// ---------------- SETTLEMENT CARDS ----------------
  List<Widget> _settlementCards(List<QueryDocumentSnapshot> docs) {
    final balance = _calculateBalance(docs);
    final settlements = _computeSettlements(balance);

    if (settlements.isEmpty) return [const Center(child: Text("No settlements needed"))];

    return settlements.map((s) {
      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(s.from).get(),
        builder: (context, fromSnap) {
          if (!fromSnap.hasData) return const SizedBox();
          final fromUser = fromSnap.data!.data() as Map<String, dynamic>;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(s.to).get(),
            builder: (context, toSnap) {
              if (!toSnap.hasData) return const SizedBox();
              final toUser = toSnap.data!.data() as Map<String, dynamic>;

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.swap_horiz, color: Colors.orange),
                  title: AppLabel.body(
                    "${fromUser['firstName']} → ${toUser['firstName']}",
                    Colors.black,
                  ),
                  subtitle: AppLabel.caption("Settlement", Colors.grey),
                  trailing: AppLabel.body(
                    "₹${s.amount.toStringAsFixed(2)}",
                    Colors.redAccent,
                  ),
                ),
              );
            },
          );
        },
      );
    }).toList();
  }
}
