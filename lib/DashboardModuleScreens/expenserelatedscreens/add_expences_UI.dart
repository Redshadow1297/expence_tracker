import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expence_tracker/AppScreens/scanner_ui_screen.dart';
import 'package:expence_tracker/Utils/app_snackbars.dart';
import 'package:expence_tracker/Utils/razor_pay_payments.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddExpenseUI extends StatefulWidget {
  const AddExpenseUI({super.key});

  @override
  _AddExpenseUIState createState() => _AddExpenseUIState();
}

class _AddExpenseUIState extends State<AddExpenseUI> {
  String selectedCategory = "Food";
  DateTime selectedDate = DateTime.now();
  TextEditingController titleController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isPaid = false;
  late PaymentController _paymentController = PaymentController();



  Future<void> addExpenses() async {
    try {
      Get.showOverlay(
        asyncFunction: () async {
        },
        loadingWidget: const Center(child: CircularProgressIndicator()),
      );

      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      await _firestore.collection('expenses').add({
        'title': titleController.text.trim(),
        'amount': double.parse(amountController.text),
        'category': selectedCategory,
        'notes': notesController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'expenseDate': selectedDate,
        'uId': user.uid,
      });

      AppSnackbar.success(
        "Success",
        "Expense added successfully",
      );

      setState(() {
        titleController.clear();
        amountController.clear();
        notesController.clear();
        selectedCategory = "Food";
        selectedDate = DateTime.now();
        _isPaid = false;
      });
    } catch (e) {
      AppSnackbar.error(
        "Error",
        e.toString(),
      );
    } finally {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    }
  }

  @override
void initState() {
  super.initState();

  _paymentController = PaymentController(
    onSuccess: () {
      setState(() {
        _isPaid = true;
      });

      AppSnackbar.success(
        "Payment Successful",
        "You can now save the expense",
      );
    },
  );

  amountController.addListener(() {
    setState(() {});
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 240, 245, 250),
      appBar: AppBar(
        backgroundColor: const Color(0xFF097D94),
        elevation: 4,
        title: const Text(
          "Add Expense",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Expense Details",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade700,
                  ),
                ),
              ),
            ),

            _buildTextField(titleController, "Title"),
            const SizedBox(height: 16),
            _buildTextField(amountController, "Amount", isNumber: true),
            const SizedBox(height: 16),

            // Category Dropdown
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(border: InputBorder.none),
                  items:
                      [
                            "Food",
                            "Travel",
                            "Shopping",
                            "Bills",
                            "Entertainment",
                            "Groceries",
                            "Other",
                          ]
                          .map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() => selectedCategory = value!);
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Date Picker
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2050),
                  initialDate: selectedDate,
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            _buildTextField(notesController, "Notes", maxLines: 3),
            const SizedBox(height: 30),

            // Pay Button
            // ElevatedButton(
            //   onPressed: () {
            //     double amount = double.tryParse(amountController.text) ?? 0;
            //     if (amount <= 0) {
            //       Get.snackbar(
            //         "Error",
            //         "Please enter a valid amount",
            //         backgroundColor: Colors.red,
            //         colorText: Colors.white,
            //       );
            //       return;
            //     }
            //     PaymentController().openCheckout(
            //       amountInINR: amount.toInt(),
            //       orderId: '',
            //       onSuccess: () {
            //         setState(() {
            //           _isPaid = true;
            //         });
            //       },
            //     );
            //   },
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.greenAccent.shade700,
            //     padding: const EdgeInsets.symmetric(vertical: 16),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //   ),
            //   child: Text(
            //     "Pay ₹${amountController.text.isEmpty ? '0' : amountController.text}",
            //     style: const TextStyle(fontSize: 18, color: Colors.white),
            //   ),
            // ),
            
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("Scan & Pay"),
              onPressed: () {
                double amount = double.tryParse(amountController.text) ?? 0;
                if (amount <= 0) {
                  AppSnackbar.error(
                    "Error",
                    "Enter valid amount",
                  );
                  return;
                }

                Get.to(
                  () => ScanUpiQrScreen(
                    onUpiDetected: (upiId) {
                      _paymentController.openUpiCheckout(
                        amountInINR: amount.toInt(),
                        upiId: upiId,
                        onSuccess: () {
                          setState(() {
                            _isPaid = true;
                          });
                        },
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // Save Button
            ElevatedButton(
              onPressed: _isPaid ? addExpenses : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPaid ? Colors.deepPurple : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Save Expense",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            const SizedBox(height: 30),

          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  @override
void dispose() {
  _paymentController.dispose();
  titleController.dispose();
  amountController.dispose();
  notesController.dispose();
  super.dispose();
}

}
