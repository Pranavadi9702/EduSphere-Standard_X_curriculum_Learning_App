import 'package:e_learning_app/providers/font_size_provider.dart';
import 'package:e_learning_app/providers/theme_provider.dart';
import 'package:e_learning_app/screens/data_upload.dart';
import 'package:e_learning_app/screens/login_page.dart';
import 'package:e_learning_app/screens/start_screen1.dart';
import 'package:e_learning_app/screens/bottom_navigation.dart'; // Import navigation bar
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp();
  FirestoreService().addDescriptionsForAllBoards();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasSeenStartScreen = prefs.getBool('hasSeenStartScreen') ?? false;

  // 🔹 Upload necessary Firestore data once
  await Future.wait([
    FirestoreService().uploadCBSEMathQuiz(),
    // FirestoreService().addDailyFactsToFirestore(),
    // FirestoreService().addFlashcardsToFirestore(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FontSizeProvider()),
        ChangeNotifierProvider(
            create: (context) => ThemeProvider()), // ✅ Add FontSizeProvider
      ],
      child: MyApp(hasSeenStartScreen: hasSeenStartScreen),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool hasSeenStartScreen;

  const MyApp({super.key, required this.hasSeenStartScreen});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  void _loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool("isDarkMode") ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "EduSphere", // ✅ Add your app name
      home: widget.hasSeenStartScreen ? const AuthCheck() : const StartScreen(),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light().copyWith(
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: fontSizeProvider.fontSize),
          bodyMedium: TextStyle(fontSize: fontSizeProvider.fontSize),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: fontSizeProvider.fontSize),
          bodyMedium: TextStyle(fontSize: fontSizeProvider.fontSize),
        ),
      ),
    );
  }
}

// 🔹 Handle Authentication and Show Navigation with `PopScope`
class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  // int _currentIndex = 0; // Track selected index

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _currentIndex = index;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return CustomBottomNavigation(); // ✅ Bottom Navigation handles navigation
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
