import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expence_tracker/CommonWidgets/app_buittons.dart';
import 'package:expence_tracker/CommonWidgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart' as printing;
import 'package:intl/intl.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime selectedMonth = DateTime.now();
  Map<String, String> userNames = {}; // uid -> name

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    final Map<String, String> names = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      names[doc.id] = data['firstName'] ?? "User";
    }
    setState(() {
      userNames = names;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 245, 250),
      appBar: const CustomAppBar(
        title: "Monthly Report",
        subTitle: "Expenses, Settlements & Attendance",
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _monthPickerUI(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('expenses')
                  .orderBy('expenseDate')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No expenses found"));
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final Timestamp? t =
                      (doc.data() as Map<String, dynamic>)['expenseDate'];
                  if (t == null) return false;
                  final date = t.toDate();
                  return date.year == selectedMonth.year &&
                      date.month == selectedMonth.month;
                }).toList();

                if (docs.isEmpty) {
                  return const Center(
                    child: Text("No expenses for this month"),
                  );
                }

                final reportData = _computeReportData(docs);

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _monthlySummary(reportData),
                    const SizedBox(height: 20),
                    _weeklyBreakdown(reportData),
                    const SizedBox(height: 20),
                    _settlementSummary(reportData),
                    const SizedBox(height: 20),
                    AppButton(
                      text: "Export as PDF",
                      onPressed: () => _exportPDF(reportData),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      text: "Export as Excel",
                      onPressed: () => exportExcel(reportData),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _monthPickerUI() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, color: Colors.blue),
          const SizedBox(width: 12),
          TextButton(
            onPressed: _pickMonth,
            child: Text(
              DateFormat.yMMM().format(selectedMonth),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
      selectableDayPredicate: (date) => true,
    );

    if (picked != null) {
      setState(() => selectedMonth = DateTime(picked.year, picked.month));
    }
  }

  /// ---------------- COMPUTE REPORT DATA ----------------
  Map<String, dynamic> _computeReportData(List<QueryDocumentSnapshot> docs) {
    double totalExpense = 0;
    Map<String, double> perPerson = {};
    Map<String, int> presentCount = {};
    Map<String, int> absentCount = {};
    Map<int, double> weeklyTotals = {};
    Map<String, double> balance = {};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final amount = (data['amount'] ?? 0).toDouble();
      totalExpense += amount;

      final splitDetails = Map<String, dynamic>.from(data['splitDetails'] ?? {});
      final present = List<String>.from(data['presentMembers'] ?? []);
      final absent = List<String>.from(data['absentMembers'] ?? []);

      // Person-wise expense & attendance
      for (var uid in present) {
        perPerson[uid] = (perPerson[uid] ?? 0) + (splitDetails[uid]?.toDouble() ?? 0);
        presentCount[uid] = (presentCount[uid] ?? 0) + 1;
      }
      for (var uid in absent) {
        absentCount[uid] = (absentCount[uid] ?? 0) + 1;
        perPerson[uid] = perPerson[uid] ?? 0;
      }

      // Weekly totals
      final Timestamp t = data['expenseDate'];
      final date = t.toDate();
      final week = ((date.day - 1) ~/ 7) + 1;
      weeklyTotals[week] = (weeklyTotals[week] ?? 0) + amount;

      // Settlement
      final paidBy = data['paidBy'];
      if (paidBy != null) balance[paidBy] = (balance[paidBy] ?? 0) + amount;
      splitDetails.forEach((uid, amt) {
        balance[uid] = (balance[uid] ?? 0) - (amt?.toDouble() ?? 0);
      });
    }

    // Compute settlements
    List<Map<String, dynamic>> settlements = [];
    final debtors = balance.entries.where((e) => e.value < 0).toList();
    final creditors = balance.entries.where((e) => e.value > 0).toList();
    for (var d in debtors) {
      double debt = -d.value;
      for (var c in creditors) {
        double credit = balance[c.key] ?? 0;
        if (debt <= 0 || credit <= 0) continue;
        final pay = debt < credit ? debt : credit;
        settlements.add({"from": d.key, "to": c.key, "amount": pay});
        debt -= pay;
        balance[c.key] = credit - pay;
      }
    }

    return {
      "totalExpense": totalExpense,
      "perPerson": perPerson,
      "presentCount": presentCount,
      "absentCount": absentCount,
      "weeklyTotals": weeklyTotals,
      "settlements": settlements,
    };
  }

  Widget _monthlySummary(Map<String, dynamic> data) {
    final totalExpense = data['totalExpense'] as double;
    final perPerson = data['perPerson'] as Map<String, double>;
    final presentCount = data['presentCount'] as Map<String, int>;
    final absentCount = data['absentCount'] as Map<String, int>;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Monthly Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            Text("Total Expense: Rs. ${totalExpense.toStringAsFixed(2)}"),
            const SizedBox(height: 8),
            const Text("Person-wise Expense & Attendance:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ...perPerson.entries.map((e) {
              final name = userNames[e.key] ?? e.key;
              final present = presentCount[e.key] ?? 0;
              final absent = absentCount[e.key] ?? 0;
              return Text("$name: Rs. ${e.value.toStringAsFixed(2)}, Present: $present, Absent: $absent");
            }),
          ],
        ),
      ),
    );
  }

  Widget _weeklyBreakdown(Map<String, dynamic> data) {
    final weeklyTotals = data['weeklyTotals'] as Map<int, double>;
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Weekly Breakdown", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            ...weeklyTotals.entries.map((e) => Text("Week ${e.key}:  Rs. ${e.value.toStringAsFixed(2)}")),
          ],
        ),
      ),
    );
  }

  Widget _settlementSummary(Map<String, dynamic> data) {
    final settlements = data['settlements'] as List<Map<String, dynamic>>;
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Settlements", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            ...settlements.map((s) {
              final from = userNames[s['from']] ?? s['from'];
              final to = userNames[s['to']] ?? s['to'];
              return Text("$from owes $to:  Rs. ${(s['amount'] as double).toStringAsFixed(2)}");
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPDF(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    final perPerson = data['perPerson'] as Map<String, double>;
    final presentCount = data['presentCount'] as Map<String, int>;
    final absentCount = data['absentCount'] as Map<String, int>;
    final settlements = data['settlements'] as List<Map<String, dynamic>>;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Monthly Expense Report", style:  pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Total Expense:  Rs. ${(data['totalExpense'] as double).toStringAsFixed(2)}"),
              pw.SizedBox(height: 10),
              pw.Text("Person-wise Expense & Attendance:", style:  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ...perPerson.entries.map((e) {
                final name = userNames[e.key] ?? e.key;
                final present = presentCount[e.key] ?? 0;
                final absent = absentCount[e.key] ?? 0;
                return pw.Text("$name:  Rs. ${e.value.toStringAsFixed(2)}, Present: $present, Absent: $absent");
              }),
              pw.SizedBox(height: 10),
              pw.Text("Settlements:", style:  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ...settlements.map((s) {
                final from = userNames[s['from']] ?? s['from'];
                final to = userNames[s['to']] ?? s['to'];
                return pw.Text("$from → $to:  Rs. ${(s['amount'] as double).toStringAsFixed(2)}");
              }),
            ],
          );
        },
      ),
    );

    await printing.Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  Future<void> exportExcel(Map<String, dynamic> data) async {
    final perPerson = data['perPerson'] as Map<String, double>;
    final presentCount = data['presentCount'] as Map<String, int>;
    final absentCount = data['absentCount'] as Map<String, int>;
    final settlements = data['settlements'] as List<Map<String, dynamic>>;

    final workbook = xls.Workbook();
    final sheet = workbook.worksheets[0];

    // Header
    sheet.getRangeByName('A1').setText('Name');
    sheet.getRangeByName('B1').setText('Expense');
    sheet.getRangeByName('C1').setText('Present');
    sheet.getRangeByName('D1').setText('Absent');

    int row = 2;
    perPerson.forEach((uid, amt) {
      sheet.getRangeByIndex(row, 1).setText(userNames[uid] ?? uid);
      sheet.getRangeByIndex(row, 2).setNumber(amt);
      sheet.getRangeByIndex(row, 3).setNumber(presentCount[uid]?.toDouble() ?? 0);
      sheet.getRangeByIndex(row, 4).setNumber(absentCount[uid]?.toDouble() ?? 0);
      row++;
    });

    // Settlements sheet
    final sheet2 = workbook.worksheets.addWithName('Settlements');
    sheet2.getRangeByName('A1').setText('From');
    sheet2.getRangeByName('B1').setText('To');
    sheet2.getRangeByName('C1').setText('Amount');

    int sRow = 2;
    for (var s in settlements) {
      sheet2.getRangeByIndex(sRow, 1).setText(userNames[s['from']] ?? s['from']);
      sheet2.getRangeByIndex(sRow, 2).setText(userNames[s['to']] ?? s['to']);
      sheet2.getRangeByIndex(sRow, 3).setNumber(s['amount']);
      sRow++;
    }

    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/monthly_report.xlsx';
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);

    print("Excel saved at $path");
  }
}
