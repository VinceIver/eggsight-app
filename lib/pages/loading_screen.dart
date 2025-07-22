import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart'; // <-- import BottomNavApp

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const BottomNavApp()), // ✅ not EggDashboard
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Image(
              image: AssetImage('assets/icons/images/no-bg-icon.png'),
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 8),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Egg',
                    style: TextStyle(
                      fontFamily: 'GreatVibes',
                      fontSize: 34,
                      color: Colors.brown,
                    ),
                  ),
                  TextSpan(
                    text: 'Sight',
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: 'GreatVibes',
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 180,
              height: 6,
              child: LinearProgressIndicator(
                color: Colors.amber,
                backgroundColor: Color(0x33FFC107),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
