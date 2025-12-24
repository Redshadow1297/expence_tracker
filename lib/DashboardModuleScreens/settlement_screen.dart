import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expence_tracker/CommonWidgets/app_lables.dart';
import 'package:expence_tracker/CommonWidgets/custom_appbar.dart';
import 'package:expence_tracker/model/settlement_model.dart';
import 'package:flutter/material.dart';

class SettlementsScreen extends StatefulWidget {
  const SettlementsScreen({super.key});

  @override
  State<SettlementsScreen> createState() => _SettlementsScreenState();
}

class _SettlementsScreenState extends State<SettlementsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 245, 250),
      appBar: CustomAppBar(
        title: "Settlements",
        subTitle: "You can see the settlements here.",
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _allExpensesList(),
        ),
      ),
    );
  }

  Widget _allExpensesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('expenses')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No expenses found'));
        }

        final expenseDocs = snapshot.data!.docs;

        return Column(
          children: [
            /// 🔧 FIX: Removed Expanded (illegal inside SingleChildScrollView)
            SizedBox(
              height: 400, // minimal fixed height
              child: expensesList(expenseDocs),
            ),
            const SizedBox(height: 8),
            _settlementCard(expenseDocs),
          ],
        );
      },
    );
  }

  Widget expensesList(List<QueryDocumentSnapshot> expenseDocs) {
    return ListView.builder(
      itemCount: expenseDocs.length,
      itemBuilder: (context, index) {
        final raw = expenseDocs[index].data();
        if (raw == null) return const SizedBox();

        final expense = raw as Map<String, dynamic>;

        final amount = expense['amount'] ?? 0;
        final category = expense['category'] ?? 'N/A';
        final Timestamp? timestamp = expense['createdAt'];
        final DateTime? date = timestamp?.toDate();
        final String? uId = expense['uId'];

        if (uId == null) return const SizedBox();

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(uId).get(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData || userSnapshot.data!.data() == null) {
              return ListTile(
                title: AppLabel.caption('Loading...', Colors.grey),
              );
            }

            final user = userSnapshot.data!.data() as Map<String, dynamic>;

            final fullName =
                '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}';

            return Card(
              elevation: 3,
              child: ListTile(
                title: AppLabel.body(fullName, Colors.black87),
                subtitle: AppLabel.caption(
                  'Category: $category\nDate: ${date != null ? date.toString().split(' ')[0] : 'N/A'}',
                  Colors.grey,
                ),
                trailing: AppLabel.caption('₹$amount', Colors.blue),
              ),
            );
          },
        );
      },
    );
  }

  Widget _settlementCard(List<QueryDocumentSnapshot> docs) {
    Map<String, double> paidByUser = {};
    Set<String> userIds = {};
    double total = 0;

    for (var doc in docs) {
      final raw = doc.data();
      if (raw == null) continue;

      final data = raw as Map<String, dynamic>;
      final uId = data['uId'];
      final amount = (data['amount'] ?? 0).toDouble();

      if (uId == null) continue;

      paidByUser[uId] = (paidByUser[uId] ?? 0) + amount;
      userIds.add(uId);
      total += amount;
    }

    if (userIds.isEmpty) return const SizedBox();

    final double share = total / userIds.length;

    Map<String, double> balance = {};
    for (var uId in userIds) {
      balance[uId] = (paidByUser[uId] ?? 0) - share;
    }

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

    // for (var d in debtors) {
    //   double debt = -d.value;
    //   for (var c in creditors) {
    //     if (debt <= 0 || c.value <= 0) continue;
    //     final pay = debt < c.value ? debt : c.value;
    //     settlements.add(Settlement(d.key, c.key, pay));
    //     debt -= pay;
    //     balance[c.key] = c.value - pay;
    //   }
    // }

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppLabel.title("Settlements", Colors.deepPurpleAccent),
            const Divider(),
            ...settlements.map((s) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(s.from)
                    .get(),
                builder: (context, fromSnap) {
                  if (!fromSnap.hasData || fromSnap.data!.data() == null) {
                    return const SizedBox();
                  }

                  final fromUser =
                      fromSnap.data!.data() as Map<String, dynamic>;

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(s.to)
                        .get(),
                    builder: (context, toSnap) {
                      if (!toSnap.hasData || toSnap.data!.data() == null) {
                        return const SizedBox();
                      }

                      final toUser =
                          toSnap.data!.data() as Map<String, dynamic>;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: AppLabel.body(
                          "${fromUser['firstName']} pays ₹${s.amount.toStringAsFixed(2)} to ${toUser['firstName']}",
                          Colors.black,
                        ),
                      );
                    },
                  );
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
