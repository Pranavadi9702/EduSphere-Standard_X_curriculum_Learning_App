import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserPreferencesScreen extends StatefulWidget {
  const UserPreferencesScreen({super.key});

  @override
  _UserPreferencesScreenState createState() => _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends State<UserPreferencesScreen> {
  String? selectedBoard;
  String? selectedGender;
  TextEditingController ageController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  bool isLoading = false; // 🔹 Loading state for button

  final List<String> boards = ["CBSE", "SSC", "ICSE", "IGCSE"];
  final List<String> genders = ["Male", "Female"];

  Future<void> saveUserPreferences() async {
    if (selectedBoard == null ||
        selectedGender == null ||
        ageController.text.isEmpty ||
        cityController.text.isEmpty) {
      // 🔹 Validate city input) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Please select your board, gender,city and enter your age"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => isLoading = true); // 🔹 Show loading indicator

    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'board': selectedBoard,
        'gender': selectedGender,
        'age': ageController.text,
        'city': cityController.text, // 🔹 Store city in Firestore
      }, SetOptions(merge: true)); // 🔹 Prevents overwriting existing data

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preferences saved successfully!"),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AuthCheck(),
          ),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving preferences: $e")),
      );
    } finally {
      setState(() => isLoading = false); // 🔹 Hide loading indicator
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D56CF), // Matching theme color
        elevation: 0, // Flat design without shadow
        title: Text(
          "User Preferences",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05, // Dynamic font size
          ),
        ),
        centerTitle: true, // Centering the title
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Select Your Board"),
              _buildDropdown(boards, selectedBoard,
                  (value) => setState(() => selectedBoard = value)),
              const SizedBox(height: 24),
              _buildSectionTitle("Select Your Gender"),
              _buildDropdown(genders, selectedGender,
                  (value) => setState(() => selectedGender = value)),
              const SizedBox(height: 24),
              _buildSectionTitle("Enter Your Age"),
              _buildTextField(ageController, true),
              const SizedBox(height: 24),
              _buildSectionTitle("Enter Your City"),
              _buildTextField(cityController, false), // City input
              const SizedBox(height: 24),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : saveUserPreferences, // 🔹 Disable button while loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.9),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ) // 🔹 Show loading indicator
                      : const Text(
                          "Continue",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
    );
  }

  Widget _buildDropdown(List<String> items, String? selectedValue,
      ValueChanged<String?> onChanged) {
    return Container(
      decoration: _boxDecoration(),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        items: items
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ))
            .toList(),
        onChanged: onChanged,
        decoration: _inputDecoration(),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, bool isNumeric) {
    return Container(
      decoration: _boxDecoration(),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric
            ? TextInputType.number
            : TextInputType.text, // Dynamic keyboard type
        style: const TextStyle(color: Colors.black, fontSize: 16),
        decoration: _inputDecoration(),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2))
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
