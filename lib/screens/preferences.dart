import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_learning_app/providers/theme_provider.dart';
import 'package:e_learning_app/providers/font_size_provider.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final double screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Preferences",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1D56CF),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // // 🔹 Dark Mode Toggle
            // ListTile(
            //   title: const Text(
            //     "Dark Mode",
            //     style: TextStyle(
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            //   trailing: Switch(
            //     value: themeProvider.isDarkMode,
            //     onChanged: (value) {
            //       themeProvider.toggleTheme(value);
            //     },
            //   ),
            // ),
            // const Divider(),

            // 🔹 Font Size Selection
            ListTile(
              title: const Text(
                "Font Size",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text("Current: ${fontSizeProvider.fontSize.toInt()}"),
              trailing: Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Colors.white, // Background color of dropdown
                ),
                child: DropdownButton<double>(
                  value: fontSizeProvider.fontSize,
                  dropdownColor:
                      Colors.white, // Background color of dropdown items
                  onChanged: (double? newSize) {
                    if (newSize != null) {
                      fontSizeProvider.setFontSize(newSize);
                    }
                  },
                  items: [12.0, 14.0, 16.0].map((size) {
                    return DropdownMenuItem<double>(
                      value: size,
                      child: Text(
                        size.toInt().toString(),
                        style: TextStyle(
                            fontSize: size,
                            color: const Color.fromARGB(
                                255, 0, 0, 0)), // Change text color
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
