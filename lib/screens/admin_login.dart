import 'package:e_learning_app/screens/admin_panel.dart';
import 'package:flutter/material.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedBoard;

  // 🔹 List of Boards
  final List<String> _boards = ["CBSE", "ICSE", "SSC", "IGCSE"];

  // 🔹 Hardcoded Admin Credentials (Modify as needed)
  final String _adminUsername = "admin";
  final String _adminPassword = "admin123";

  void _handleLogin() {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty || _selectedBoard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please fill all fields")),
      );
      return;
    }

    // 🔹 Check Admin Credentials
    if (username == _adminUsername && password == _adminPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Login Successful")),
      );

      // 🔹 Redirect to Admin Panel
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Invalid Username or Password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D56CF), // New blue color for AppBar
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Admin Login",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔹 Username Field
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: "Username",
                  labelStyle: const TextStyle(color: Colors.blueGrey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white, // Soft blue fill for input
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 Password Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: const TextStyle(color: Colors.blueGrey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 Dropdown for Board Selection
              DropdownButtonFormField<String>(
                value: _selectedBoard,
                decoration: InputDecoration(
                  labelText: "Select Board",
                  labelStyle: const TextStyle(color: Colors.blueGrey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _boards.map((board) {
                  return DropdownMenuItem(
                    value: board,
                    child: Text(board,
                        style: const TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBoard = value;
                  });
                },
              ),
              const SizedBox(height: 30),

              // 🔹 Login Button
              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor:
                      const Color(0xFF1D56CF), // Blue color for the button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
