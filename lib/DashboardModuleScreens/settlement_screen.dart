import 'package:cloud_firestore/cloud_firestore.dart';
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
      backgroundColor: Color.fromARGB(255, 240, 245, 250),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color.fromARGB(255, 9, 125, 148),
        elevation: 8,
        title: const Column(
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
            Text(
              "You can see the settlements here.",
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: SafeArea(
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

        return ListView.builder(
          itemCount: expenseDocs.length,
          itemBuilder: (context, index) {
            final expense =
                expenseDocs[index].data() as Map<String, dynamic>;

            final amount = expense['amount'] ?? 0;
            final category = expense['category'] ?? 'N/A';

            final Timestamp? timestamp = expense['createdAt'];
            final DateTime? date =
                timestamp?.toDate();

            final String? uId = expense['uId'];

            // Safety check
            if (uId == null) {
              return ListTile(
                title: const Text('Unknown User'),
                subtitle: Text(
                  'Category: $category\nDate: ${date ?? 'N/A'}',
                ),
                trailing: Text('₹$amount'),
              );
            }

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uId)
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const ListTile(
                    title: Text('Loading user...'),
                  );
                }

                if (!userSnapshot.data!.exists) {
                  return const ListTile(
                    title: Text('User not found'),
                  );
                }

                final user =
                    userSnapshot.data!.data() as Map<String, dynamic>;

                final fullName =
                    '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}';

                return Card(
                  elevation: 3,
                  child: ListTile(
                    horizontalTitleGap: 10,
                    title: Text(fullName,style: TextStyle(fontWeight: FontWeight.bold),),
                    subtitle: Text(
                      'Category: $category\nDate: ${date != null ? date.toString().split(' ')[0] : 'N/A'}',
                    ),
                    trailing: Text(
                      '₹$amount',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
