import 'dart:async';
import 'package:flutter/material.dart';
import 'data_upload.dart';

class BreathingIconContainer extends StatefulWidget {
  const BreathingIconContainer({super.key});

  @override
  _BreathingIconContainerState createState() => _BreathingIconContainerState();
}

class _BreathingIconContainerState extends State<BreathingIconContainer> {
  double _scale = 1;
  late Timer _timer;
  List<String> _facts = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchFacts();
    _startBreathingAnimation();
  }

  // 🔹 Fetch facts from Firestore
  void _fetchFacts() async {
    List<String> facts = await FirestoreService().fetchDailyFacts();
    if (facts.isNotEmpty) {
      setState(() {
        _facts = facts;
      });

      // 🔹 Start cycling through facts every 5 seconds
      Timer.periodic(const Duration(seconds: 5), (timer) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _facts.length;
        });
      });
    }
  }

  // 🔹 Start the breathing animation effect
  void _startBreathingAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _scale = _scale == 0.9 ? 1.1 : 0.9;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedScale(
            scale: _scale,
            duration: const Duration(seconds: 2), // Smooth breathing animation
            curve: Curves.easeInOut,
            child: const Icon(
              Icons.lightbulb,
              size: 55,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }
}
