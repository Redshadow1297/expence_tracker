import 'package:flutter/material.dart';

class AppLabel extends StatelessWidget {
  final String text;
  final TextStyle style;
  const AppLabel._(this.text, this.style);
  factory AppLabel.body(String text, Color txt_color) {
    return AppLabel._(
      text,
      TextStyle(fontSize: 16, fontFamily: 'Poppins-Regular',fontWeight: FontWeight.bold,color: txt_color),
    );
  }
  factory AppLabel.title(String text,Color txt_color) {
    return AppLabel._(
      text,
      TextStyle(fontSize: 18,color: txt_color, fontFamily: 'Poppins-Bold',fontWeight: FontWeight.bold),
    );
  }
  factory AppLabel.caption(String text, Color txt_color) {
    return AppLabel._(
      text,
      TextStyle(fontSize: 14, color: txt_color,fontFamily: 'Poppins-SemiBold',fontWeight: FontWeight.bold),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Text(text, style: style);
  }
}
