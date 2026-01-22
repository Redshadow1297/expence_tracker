import 'package:flutter/material.dart';

class AppAlertdialogBox {
  static void alertBox(
    BuildContext context,
    String alertMessage,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text("Alert"),
          content: Text(alertMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
