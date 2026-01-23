import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expence_tracker/CommonWidgets/app_buittons.dart';
import 'package:expence_tracker/CommonWidgets/app_lables.dart';
import 'package:expence_tracker/CommonWidgets/app_snackbars.dart';
import 'package:expence_tracker/CommonWidgets/custom_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddExpenseUI extends StatefulWidget {
  const AddExpenseUI({super.key});

  @override
  State<AddExpenseUI> createState() => _AddExpenseUIState();
}

class _AddExpenseUIState extends State<AddExpenseUI> {
  String selectedCategory = "Food";
  DateTime selectedDate = DateTime.now();

  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final notesController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  

  /// Members
  List<Map<String, dynamic>> members = [];
  Set<String> presentMembers = {};
  Set<String> absentMembers = {};

  @override
  void initState() {
    super.initState();
    fetchMembers();
    //  saveFcmToken(); //FCM TOKEN SAVE FUNCTION CALL
  }


// //----------------------------------------FCM NOTIFICATION USING CLOUD FIRESTORE------------------------------------------
// Future<void> saveFcmToken() async {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user == null) return;
//   final messaging = FirebaseMessaging.instance;
//   //Request permission
//   await messaging.requestPermission(
//     alert: true,
//     badge: true,
//     sound: true,
//   );
//   final token = await messaging.getToken();
//   if (token == null) return;
//   await FirebaseFirestore.instance
//       .collection('users')
//       .doc(user.uid)
//       .set(
//     {'fcmToken': token},
//     SetOptions(merge: true), // SAFE UPDATE
//   );
//   debugPrint("FCM Token saved: $token");
// }

  /// Fetch users from Firestore
  Future<void> fetchMembers() async {
    final snapshot = await _firestore.collection('users').get();

    members = snapshot.docs.map((doc) {
      return {
        'uid': doc['uId'], // Use uId field, not doc.id
        'name': doc['firstName'] + ' ' + doc['lastName'],
      };
    }).toList();

    setState(() {
      presentMembers = members.map((e) => e['uid'] as String).toSet();
      absentMembers.clear();
    });
  }

  /// Add Expense to Firestore
  Future<void> addExpenses() async {
    try {
      Get.showOverlay(
        asyncFunction: () async {},
        loadingWidget: const Center(child: CircularProgressIndicator()),
      );

      final user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      if (presentMembers.isEmpty) {
        throw Exception("At least one member must be present");
      }

      final totalAmount = double.parse(amountController.text);
      final perPerson = totalAmount / presentMembers.length;

      // Split details for each member
      Map<String, double> splitDetails = {};

      for (var uid in presentMembers) {
        splitDetails[uid] = double.parse(perPerson.toStringAsFixed(2));
      }

      for (var uid in absentMembers) {
        splitDetails[uid] = 0;
      }

      await _firestore.collection('expenses').add({
        'title': titleController.text.trim(),
        'amount': totalAmount,
        'category': selectedCategory,
        'notes': notesController.text.trim(),
        'expenseDate': selectedDate,
        'createdAt': FieldValue.serverTimestamp(),
        'paidBy': user.uid,
        'presentMembers': presentMembers.toList(),
        'absentMembers': absentMembers.toList(),
        'splitDetails': splitDetails,
      });


      AppSnackbar.success("Success", "Expense added successfully");

      titleController.clear();
      amountController.clear();
      notesController.clear();

      setState(() {
        selectedCategory = "Food";
        selectedDate = DateTime.now();
        presentMembers = members.map((e) => e['uid'] as String).toSet();
        absentMembers.clear();
      });
    } catch (e) {
      AppSnackbar.error("Error", e.toString());
    } finally {
      if (Get.isDialogOpen == true) Get.back();
    }
  }

  void _onSavePressed() {
    final amount = double.tryParse(amountController.text);

    if (titleController.text.trim().isEmpty) {
      AppSnackbar.error("Error", "Title is required");
      return;
    }

    if (amount == null || amount <= 0) {
      AppSnackbar.error("Error", "Enter a valid amount");
      return;
    }

    addExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 245, 250),
      appBar: const CustomAppBar(
        title: "Add Expense",
        subTitle: "Record your daily spending",
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _headerCard(),
          const SizedBox(height: 20),
          _formSection(),
          const SizedBox(height: 30),
          AppButton(
            text: "Save Expense",
            onPressed: _onSavePressed,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _headerCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: const [
            Icon(Icons.receipt_long, size: 36, color: Color(0xFF097D94)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Add a new expense\nKeep track of your money",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppLabel.title("Expense Details", Colors.indigoAccent),
        const SizedBox(height: 12),

        _inputCard(child: _textField(titleController, "Title")),
        const SizedBox(height: 12),

        _inputCard(
          child: _textField(
            amountController,
            "Amount",
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(height: 12),

        _inputCard(
          child: DropdownButtonFormField<String>(
            value: selectedCategory,
            decoration: const InputDecoration(border: InputBorder.none),
            items: const [
              "Food",
              "Travel",
              "Shopping",
              "Bills",
              "Entertainment",
              "Groceries",
              "Other",
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => selectedCategory = val!),
          ),
        ),
        const SizedBox(height: 12),

        _inputCard(
          onTap: _pickDate,
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.blue),
              const SizedBox(width: 12),
              Text(
                "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        _inputCard(
          child: _textField(notesController, "Notes", maxLines: 3),
        ),

        const SizedBox(height: 16),
        AppLabel.title("Members", Colors.purpleAccent),
        const SizedBox(height: 8),
        _memberSelectionUI(),
      ],
    );
  }

  Widget _memberSelectionUI() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: members.map((member) {
          final uid = member['uid'];
          final isPresent = presentMembers.contains(uid);

          return SwitchListTile(
            title: Text(member['name']),
            subtitle: Text(isPresent ? "Present" : "Absent"),
            value: isPresent,
            onChanged: (val) {
              setState(() {
                if (val) {
                  presentMembers.add(uid);
                  absentMembers.remove(uid);
                } else {
                  presentMembers.remove(uid);
                  absentMembers.add(uid);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _inputCard({required Widget child, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: child,
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, border: InputBorder.none),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
      initialDate: selectedDate,
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
