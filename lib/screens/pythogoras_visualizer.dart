import 'package:flutter/material.dart';
import 'dart:math';

class PythagorasScreen extends StatefulWidget {
  const PythagorasScreen({super.key});

  @override
  _PythagorasScreenState createState() => _PythagorasScreenState();
}

class _PythagorasScreenState extends State<PythagorasScreen> {
  final TextEditingController _sideAController = TextEditingController();
  final TextEditingController _sideBController = TextEditingController();

  String result = "";
  double a = 0, b = 0, c = 0;
  bool showVisualization = false;

  void calculateHypotenuse() {
    int? x = int.tryParse(_sideAController.text);
    int? y = int.tryParse(_sideBController.text);

    if (x == null || y == null || x <= 0 || y <= 0) {
      showErrorDialog("⚠️ Please enter valid positive whole numbers.");
      return;
    }

    double hypotenuse = sqrt(pow(x, 2) + pow(y, 2));

    if (hypotenuse % 1 == 0) {
      setState(() {
        a = x.toDouble();
        b = y.toDouble();
        c = hypotenuse.toInt().toDouble();

        result = "✅ The calculated Hypotenuse (C) is ${c.toInt()}\n\n"
            "📌 Step 1: Square the sides\n"
            "  ${a.toInt()}² = ${a.toInt() * a.toInt()},  ${b.toInt()}² = ${b.toInt() * b.toInt()}\n\n"
            "📌 Step 2: Apply Pythagoras' Theorem\n"
            "  C² = ${a.toInt() * a.toInt()} + ${b.toInt() * b.toInt()} = ${(c.toInt() * c.toInt())}\n\n"
            "📌 Step 3: Take the Square Root\n"
            "  C = √(${(c.toInt() * c.toInt())}) = ${c.toInt()}";

        showVisualization = true;
      });
    } else {
      showErrorDialog(
        "❌ The given values do not form a right-angled triangle with a whole-number hypotenuse.",
      );
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          content: Text(
            message,
            style: const TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D56CF), // Matching theme color
        elevation: 0, // Flat design without shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.white), // Updated back icon
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          "Pythagoras Theorem Visualizer",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05, // Dynamic font size
          ),
        ),
        centerTitle: true, // Centering the title
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 8, // Slightly increased for better depth
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(20), // Softer rounded corners
              ),
              shadowColor:
                  Colors.black.withOpacity(0.3), // Subtle shadow effect
              child: Padding(
                padding: const EdgeInsets.all(20.0), // More spacious padding
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Centered content
                  children: [
                    const Text(
                      "Enter Triangle Sides (A & B)",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D56CF), // Theme color for heading
                      ),
                    ),
                    const SizedBox(height: 15),
                    buildInputField("Enter Side A", _sideAController),
                    const SizedBox(height: 10),
                    buildInputField("Enter Side B", _sideBController),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: calculateHypotenuse,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: const Color(0xFF1D56CF), // Theme color
                        foregroundColor: Colors.white, // White text color
                        elevation: 4, // Slight elevation for button effect
                      ),
                      child: const Text(
                        "Calculate Hypotenuse",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Triangle Visualization
            // Triangle Visualization
            showVisualization && a > 0 && b > 0 && c > 0
                ? Column(
                    children: [
                      SizedBox(
                        height: 200,
                        width: 220,
                        child: CustomPaint(
                          painter: TrianglePainter(a, b, c),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "🔺 Right-Angled Triangle",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 20),
                    ],
                  )
                : Container(),

            // Result Card
            Card(
              elevation: showVisualization ? 5 : 0,
              color: showVisualization ? Colors.green.shade100 : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  result,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.black), // ✅ Ensures text is black
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        ),
      ),
    );
  }
}

// 🎨 Triangle Painter (Updated)
class TrianglePainter extends CustomPainter {
  final double a, b, c;
  TrianglePainter(this.a, this.b, this.c);

  @override
  void paint(Canvas canvas, Size size) {
    if (a <= 0 || b <= 0 || c <= 0) {
      return; // Prevent drawing if values are invalid
    }

    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    double offsetX = (size.width - (b * 20)) / 2;
    double offsetY = (size.height - (a * 20)) / 2 + (a * 20);

    Path path = Path()
      ..moveTo(offsetX, offsetY) // Bottom-left corner
      ..lineTo(offsetX + (b * 20), offsetY) // Bottom-right
      ..lineTo(offsetX, offsetY - (a * 20)) // Top-left
      ..close();

    canvas.drawPath(path, paint);

    // Draw Side Labels near the triangle
    drawText(canvas, "A", Offset(offsetX - 20, offsetY - (a * 10))); // Side A
    drawText(canvas, "B", Offset(offsetX + (b * 10), offsetY + 5)); // Side B
    drawText(canvas, "C",
        Offset(offsetX + (b * 10) - 10, offsetY - (a * 10) - 35)); // Hypotenuse
  }

  void drawText(Canvas canvas, String text, Offset position) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
            color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
