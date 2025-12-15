import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SettlementsScreen extends StatefulWidget {
  const SettlementsScreen({super.key});

  @override
  State<SettlementsScreen> createState() => _SettlementsScreenState();
}

class _SettlementsScreenState extends State<SettlementsScreen> {
  Future<Map<String, Map<String, dynamic>>> fetchAllExpenseData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('expenses').get();

    Map<String, Map<String, dynamic>> allExpenses = {};

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Convert Timestamp to DateTime if necessary
      if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
        data['createdAt'] = (data['createdAt'] as Timestamp).toDate();
      }

      allExpenses[doc.id] = data;
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
      child: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('expenses').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No expenses found.'));
          } else {
            final expenseDocs = snapshot.data!.docs;

            return ListView.builder(
              itemCount: expenseDocs.length,
              itemBuilder: (context, index) {
                final expense =
                    expenseDocs[index].data() as Map<String, dynamic>;
                final amount = expense['amount'] ?? 'N/A';
                final category = expense['category'] ?? 'N/A';
                final date = expense['createdAt'] != null
                    ? (expense['createdAt'] is Timestamp
                          ? (expense['createdAt'] as Timestamp).toDate()
                          : expense['createdAt'])
                    : '';

                final uId = expense['uId'];

                // Use FutureBuilder to get user details for each expense
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(uId)
                      .get(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return ListTile(
                        title: Text('Loading user...'),
                        subtitle: Text('Category: $category\nDate: $date'),
                        trailing: Text('Amount: $amount'),
                      );
                    }
                    final user =
                        userSnapshot.data!.data() as Map<String, dynamic>;
                    final fullName = '${user['firstName']} ${user['lastName']}';

                    return ListTile(
                      title: Text(fullName),
                      subtitle: Text('Category: $category\nDate: $date'),
                      trailing: Text('Amount: $amount'),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
