import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AutoEggLogger extends StatefulWidget {
  const AutoEggLogger({super.key});

  @override
  State<AutoEggLogger> createState() => _AutoEggLoggerState();
}

class _AutoEggLoggerState extends State<AutoEggLogger> {
  Timer? _timer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startLogging();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startLogging() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      final now = DateTime.now();

      final morningStart = DateTime(now.year, now.month, now.day, 8, 30);
      final morningEnd = DateTime(now.year, now.month, now.day, 12, 0);
      final afternoonStart = DateTime(now.year, now.month, now.day, 13, 0);
      final afternoonEnd = DateTime(now.year, now.month, now.day, 17, 0);

      bool inAllowedTime = (now.isAfter(morningStart) && now.isBefore(morningEnd)) ||
          (now.isAfter(afternoonStart) && now.isBefore(afternoonEnd));

      if (inAllowedTime) {
        _logRandomEgg(now);
      }
    });
  }

  Future<void> _logRandomEgg(DateTime timestamp) async {
    try {
      int rng = _random.nextInt(100);
      String status = (rng < 75) ? 'fresh' : 'rotten';

      double confidence = status == 'fresh'
          ? 85 + _random.nextDouble() * 15
          : 40 + _random.nextDouble() * 35;

      await FirebaseFirestore.instance.collection('eggs').add({
        'status': status,
        'confidence': confidence,
        'timestamp': timestamp,
        'batch': 'Auto-${timestamp.microsecondsSinceEpoch}',
      });

      print('Logged $status egg with confidence ${confidence.toStringAsFixed(1)} at $timestamp');
    } catch (e) {
      print('Error logging egg: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); 
  }
}
