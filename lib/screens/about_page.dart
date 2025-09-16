import 'package:e_learning_app/screens/help_support.dart';
import 'package:e_learning_app/screens/terms_conditions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "About",
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildOptionTile("Terms & Condition", Icons.arrow_forward_ios, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TermsConditionsPage()),
              );
            }),
            const SizedBox(height: 15),
            _buildOptionTile("Help & Support", Icons.arrow_forward_ios, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpSupportPage()),
              );
            }),
            const SizedBox(height: 15),
            _buildAppVersionTile(),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(String title, IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Colors.deepPurpleAccent, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        title: Text(
          title,
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        trailing: Icon(icon, color: Colors.white, size: 18),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAppVersionTile() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[900],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        title: Text(
          "App Version",
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        trailing: Text("V.0.0.0.1",
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
      ),
    );
  }
}