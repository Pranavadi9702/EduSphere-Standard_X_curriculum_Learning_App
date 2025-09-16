import 'package:e_learning_app/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  int index = 0; // Track the current screen index

  final List<Map<String, String>> screens = [
    {
      'title': 'Grow your\nEducation &\nlevel up with App',
      'image': 'assets/start_screen_img1.png',
    },
    {
      'title': 'Explore and Learn New\nInterpersonal\nSkills',
      'image': 'assets/start_screen_img2.png',
    },
    {
      'title': 'Deep Dive \ninto the\nWorld of Learning',
      'image': 'assets/start_screen_img3.png',
    },
    {
      'title': 'Are you ready to go to the World of Knowledge?',
      'image': 'assets/start_screen_img4.png',
    },
  ];

  Future<void> navigateToHome() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenStartScreen', true); // Mark as seen

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1D56CF), // Primary deep blue
                  const Color.fromARGB(
                      255, 122, 155, 193), // Softer sky blue for contrast
                ], // Gradient colors
                begin: Alignment.topLeft, // Start position
                end: Alignment.bottomRight, // End position
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(top: 100.0, left: 30.0, right: 30.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Image.asset(
                    screens[index]['image']!,
                    key: ValueKey<int>(index),
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 70.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Text(
                    screens[index]['title']!,
                    key: ValueKey<int>(index),
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 110.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 70.0),
                    child: Row(
                      children: List.generate(4, (dotIndex) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 8,
                            width: index == dotIndex ? 30 : 8,
                            decoration: BoxDecoration(
                              color: index == dotIndex
                                  ? Colors.white
                                  : Colors.white54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 30.0),
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: index == screens.length - 1
                        ? TextButton(
                            style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            onPressed: navigateToHome,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Let's Begin!",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, color: Colors.black),
                              ],
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.arrow_forward,
                                color: Colors.black),
                            onPressed: () {
                              setState(() {
                                index++;
                              });
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
