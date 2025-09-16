import 'package:flutter/material.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Get screen size
    final double padding = size.width * 0.05; // Dynamic padding

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF1D56CF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Terms & Conditions",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size.width * 0.05, // Dynamic font size
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero, // Removed extra padding
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: padding,
              vertical: size.height * 0), // Dynamic spacing
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Introduction:", size),
              _buildSectionContent(
                  "App is committed to protecting your privacy. This policy explains how we collect, use, and safeguard your information when you use our app.",
                  size),
              _buildSectionTitle("Data We Collect:", size),
              _buildBulletPoint(
                  "Account Information: Name, email, age, and password.", size),
              _buildBulletPoint(
                  "Usage Data: Courses accessed, progress, quiz scores, and device type (iOS/Android).",
                  size),
              _buildBulletPoint(
                  "Technical Data: IP address, browser type, and app crash logs.",
                  size),
              _buildSectionTitle("How We Use Data:", size),
              _buildBulletPoint("Personalize course recommendations.", size),
              _buildBulletPoint("Improve app performance and fix bugs.", size),
              _buildBulletPoint(
                  "Send promotional emails (opt-out available).", size),
              _buildSectionTitle("Data Sharing:", size),
              _buildBulletPoint(
                  "Third Parties: AWS (hosting), Google Analytics (usage trends).",
                  size),
              _buildBulletPoint(
                  "Legal Compliance: Disclose data if required by law.", size),
              _buildSectionTitle("Security:", size),
              _buildSectionContent(
                  "We use SSL encryption and restrict employee access to your data.",
                  size),
              _buildSectionTitle("Your Rights:", size),
              _buildBulletPoint(
                  "Request data deletion via privacy@app.com.", size),
              _buildBulletPoint(
                  "Opt out of marketing emails in account settings.", size),
              _buildSectionTitle("Policy Updates:", size),
              _buildSectionContent(
                  "Last updated: Jan 1, 2024. Changes will be notified via email.",
                  size),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Size size) {
    return Padding(
      padding:
          EdgeInsets.only(top: size.height * 0.02, bottom: size.height * 0.01),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: size.width * 0.05, // Dynamic font size
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content, Size size) {
    return Text(
      content,
      style: TextStyle(
        color: Colors.black,
        fontSize: size.width * 0.04, // Dynamic font size
      ),
    );
  }

  Widget _buildBulletPoint(String text, Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: size.height * 0.005), // Dynamic spacing
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: size.width * 0.04)), // Dynamic bullet point size
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: size.width * 0.04), // Dynamic font size
            ),
          ),
        ],
      ),
    );
  }
}
