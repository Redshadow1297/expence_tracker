import 'package:expence_tracker/Presentation/custom_appbar.dart';
import 'package:flutter/material.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  Widget build(BuildContext context) {
   return  Scaffold(
    appBar: CustomAppBar(title: "Reports", subTitle: "You can get the expense reports."),
    backgroundColor: Color.fromARGB(255, 240, 245, 250),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings_accessibility, size: 100),
            Text("Under Development !"),
          ],
        ),
      ),
    );
  }
}