import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning_app/screens/admin_login.dart';
import 'package:e_learning_app/screens/favourites_screen.dart';
import 'package:e_learning_app/screens/privacy.dart';
import 'package:e_learning_app/screens/settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'terms_conditions.dart';
import 'help_support.dart';
import 'package:e_learning_app/screens/preferences.dart'; // Import your login screen

class ProfilePage extends StatefulWidget {
  final int selectedIndex;

  const ProfilePage({super.key, required this.selectedIndex});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3; // Profile Page selected
  String username = "Cannot find username"; // Default value
  String? profilePhotoUrl; // URL for profile photo

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _fetchUsername(user); // Fetch and update username
      }
    });
  }

  // Fetch updated username and profile image from Firestore
  // Fetch updated username and profile image from Firestore
  Future<void> _fetchUsername(User user) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;

      setState(() {
        String firstName = data?['firstName'] ?? '';
        String lastName = data?['lastName'] ?? '';

        username = "${firstName.trim()} ${lastName.trim()}".trim();
        if (username.isEmpty) {
          username = user.displayName ?? 'User';
        }

        profilePhotoUrl = data?['profileImageUrl'] ?? user.photoURL;
      });
    } else {
      setState(() {
        username = user.displayName ?? 'User';
        profilePhotoUrl = user.photoURL;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (FirebaseAuth.instance.currentUser != null) {
      _fetchUsername(FirebaseAuth.instance.currentUser!);
    }
  }

  // Future<void> _logout() async {
  //   try {
  //     User? user = FirebaseAuth.instance.currentUser;
  //     if (user != null) {
  //       await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
  //     }

  //     await FirebaseAuth.instance.signOut();

  //     if (mounted) {
  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(builder: (context) => LoginPage()),
  //         (route) => false, // Remove all previous routes
  //       );
  //     }
  //   } catch (e) {
  //     print("Error during logout: $e");
  //   }
  // }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    // switch (index) {
    //   case 0:
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => HomePage(selectedIndex: 0),
    //       ),
    //     );
    //     break;
    //   case 1:
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => BoardSelectionScreen(selectedIndex: 1),
    //       ),
    //     );
    //     break;
    //   case 2:
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => NotesPage(selectedIndex: 3),
    //       ),
    //     );
    //     break;
    //   case 3:
    //     break;
    // }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white, // ✅ Set background color to white
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back button
        backgroundColor: Color(0xFF1D56CF), // Theme color
        elevation: 4,
        toolbarHeight:
            screenHeight * 0.09, // Increased height for better spacing
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize:
                  MainAxisSize.min, // Prevents excessive vertical space
              children: [
                Text(
                  'Hi $username!', // Dynamic username
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Adjusted to match the theme
                  ),
                ),
                // ✅ Update Edit Profile Navigation to Refresh Data on Return
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(),
                      ),
                    ).then((_) {
                      if (FirebaseAuth.instance.currentUser != null) {
                        _fetchUsername(FirebaseAuth.instance.currentUser!);
                      }
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withOpacity(0.9),
                        size: screenWidth * 0.03,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: profilePhotoUrl != null
                  ? Image.network(
                      profilePhotoUrl!,
                      width: screenWidth * 0.12,
                      height: screenWidth * 0.12,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/icons/user.png', // Default user icon
                      width: screenWidth * 0.12,
                      height: screenWidth * 0.12,
                    ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0), // Space below AppBar

              // ✅ List Items Section
              _buildListTile('assets/icons/admin.png', 'Admin Panel', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminLoginPage(),
                  ),
                );
              }),
              _buildDivider(),
              _buildListTile('assets/icons/preference.png', 'Preferences', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreferencesScreen(),
                  ),
                );
              }),
              _buildDivider(),
              _buildListTile('assets/icons/favs.png', 'Favourites', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesScreen()),
                );
              }),
              _buildDivider(),
              _buildListTile('assets/icons/help.png', 'Help & Support', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpSupportPage(),
                  ),
                );
              }),
              _buildDivider(),
              _buildListTile('assets/icons/terms.png', 'Terms & Conditions',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsConditionsPage(),
                  ),
                );
              }),
              _buildDivider(),

              // ✅ Account & Settings with Logout
              _buildListTile(
                'assets/icons/settings.png',
                'Account & Settings',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage()),
                  );
                },
              ),

              _buildDivider(),
              SizedBox(height: screenHeight * 0.1),

              // ✅ Terms & Conditions Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TermsConditionsPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Terms & Conditions",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1D56CF),
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF1D56CF),
                              ),
                            ),
                          ),
                          const Text(
                            "     |     ",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PrivacyPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Privacy Policy",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1D56CF),
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF1D56CF),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "App Version: V.0.0.1",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(String imagePath, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      leading: Image.asset(
        imagePath,
        color: Color(0xFF1D56CF),
        width: MediaQuery.of(context).size.width * 0.07,
        height: MediaQuery.of(context).size.width * 0.07,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.045,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios,
          size: MediaQuery.of(context).size.width * 0.05),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey,
      thickness: 1,
      height: 2,
    );
  }
}
