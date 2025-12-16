import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
   return  Scaffold(
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