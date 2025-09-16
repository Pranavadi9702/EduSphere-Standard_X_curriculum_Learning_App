import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning_app/screens/privacy.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart'; // Import login page

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();
      }

      await FirebaseAuth.instance.signOut();

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      print("Error during logout: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.bold, // Bold text
            fontSize: screenWidth * 0.05,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF1D56CF),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Color(0xFF1D56CF)),
            title: const Text(
              "Privacy & Policy",
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrivacyPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFF1D56CF)),
            title: const Text(
              "Logout",
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout",
                      style: TextStyle(color: Colors.black)),
                  content: const Text("Are you sure you want to log out?",
                      style: TextStyle(color: Colors.black)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => _logout(context),
                      child: const Text("Logout",
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
