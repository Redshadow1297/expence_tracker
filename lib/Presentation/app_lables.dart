import 'package:flutter/material.dart';

class AppLabel extends StatelessWidget {
  final String text;
  final TextStyle style;

  const AppLabel._(this.text, this.style);

  factory AppLabel.body(String text) {
    return AppLabel._(
      text,
      const TextStyle(fontSize: 14),
    );
  }

  factory AppLabel.title(String text) {
    return AppLabel._(
      text,
      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  factory AppLabel.caption(String text) {
    return AppLabel._(
      text,
      const TextStyle(fontSize: 12, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style);
  }
}
