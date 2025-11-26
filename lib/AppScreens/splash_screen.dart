import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpenseSplash extends StatefulWidget {
  @override
  _ExpenseSplashState createState() => _ExpenseSplashState();
}

class _ExpenseSplashState extends State<ExpenseSplash> {
  final random = Random();
  List<double> topPositions = [];
  List<double> leftPositions = [];
  final icons = ["🍽", "💡", "💧", "🏠", "💸"];

  bool _isDisposed = false; // <--- added flag

  @override
  void initState() {
    super.initState();
    _initPositions();

    Future.delayed(Duration(milliseconds: 700), () {
      if (!_isDisposed) _animateBubbles();
    });

    Future.delayed(Duration(seconds: 4), () {
      if (!_isDisposed) Get.offAllNamed('/LoginPage');
    });
  }

  void _initPositions() {
    for (int i = 0; i < icons.length; i++) {
      topPositions.add(600 + random.nextDouble() * 200);
      leftPositions.add(20 + random.nextDouble() * 300);
    }
  }

  void _animateBubbles() {
    if (!mounted || _isDisposed) return; // <--- important

    setState(() {
      for (int i = 0; i < icons.length; i++) {
        topPositions[i] = random.nextDouble() * 300;
        leftPositions[i] = 5 + random.nextDouble() * 200;
      }
    });

    // Schedule next animation
    Future.delayed(Duration(seconds: 2), () {
      if (!_isDisposed) _animateBubbles();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: icons
                    .map(
                      (icon) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildBubble(icon, size: 55),
                      ),
                    )
                    .toList(),
              ),
            ),
            SizedBox(height: 40),
            Icon(Icons.account_balance_wallet, size: 90, color: Colors.white),
            SizedBox(height: 15),
            Text(
              "Room Expense Tracker",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(String icon, {double size = 50}) {
    return Container(
      padding: EdgeInsets.all(14),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
      ),
      child: Center(child: Text(icon, style: TextStyle(fontSize: 22))),
    );
  }
}
