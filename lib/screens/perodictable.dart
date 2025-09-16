import 'package:flutter/material.dart';
import 'package:e_learning_app/screens/elements.dart';

class PeriodicTableScreen extends StatelessWidget {
  const PeriodicTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Periodic Table",
          style: TextStyle(
            color: Colors.white, // Ensuring readability
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1D56CF), // Themed deep blue
        elevation: 4, // Slight shadow for depth
        shadowColor: Colors.black.withOpacity(0.2), // Soft shadow effect
        centerTitle: true, // Aligning title to center
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.white), // White back icon
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical, // Enable vertical scrolling
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Enable horizontal scrolling
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const LegendSection(),
                const SizedBox(height: 10),
                _buildPeriodicTable(
                    context), // Remove Expanded to avoid layout issues
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodicTable(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildRow(context, [
          "H",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "He"
        ]),
        _buildRow(context, [
          "Li",
          "Be",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "B",
          "C",
          "N",
          "O",
          "F",
          "Ne"
        ]),
        _buildRow(context, [
          "Na",
          "Mg",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "Al",
          "Si",
          "P",
          "S",
          "Cl",
          "Ar"
        ]),
        _buildRow(context, [
          "K",
          "Ca",
          "Sc",
          "Ti",
          "V",
          "Cr",
          "Mn",
          "Fe",
          "Co",
          "Ni",
          "Cu",
          "Zn",
          "Ga",
          "Ge",
          "As",
          "Se",
          "Br",
          "Kr"
        ]),
        _buildRow(context, [
          "Rb",
          "Sr",
          "Y",
          "Zr",
          "Nb",
          "Mo",
          "Tc",
          "Ru",
          "Rh",
          "Pd",
          "Ag",
          "Cd",
          "In",
          "Sn",
          "Sb",
          "Te",
          "I",
          "Xe"
        ]),
        _buildRow(context, [
          "Cs",
          "Ba",
          "La*",
          "Hf",
          "Ta",
          "W",
          "Re",
          "Os",
          "Ir",
          "Pt",
          "Au",
          "Hg",
          "Tl",
          "Pb",
          "Bi",
          "Po",
          "At",
          "Rn"
        ]),
        _buildRow(context, [
          "Fr",
          "Ra",
          "Ac*",
          "Rf",
          "Db",
          "Sg",
          "Bh",
          "Hs",
          "Mt",
          "Ds",
          "Rg",
          "Cn",
          "Nh",
          "Fl",
          "Mc",
          "Lv",
          "Ts",
          "Og"
        ]),
        const SizedBox(height: 10),
        _buildRow(context, [
          "",
          "",
          "Ce",
          "Pr",
          "Nd",
          "Pm",
          "Sm",
          "Eu",
          "Gd",
          "Tb",
          "Dy",
          "Ho",
          "Er",
          "Tm",
          "Yb",
          "Lu"
        ]),
        _buildRow(context, [
          "",
          "",
          "Th",
          "Pa",
          "U",
          "Np",
          "Pu",
          "Am",
          "Cm",
          "Bk",
          "Cf",
          "Es",
          "Fm",
          "Md",
          "No",
          "Lr"
        ]),
      ],
    );
  }

  Widget _buildRow(BuildContext context, List<String> elements) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: elements.map((e) => _buildTile(context, e)).toList(),
    );
  }

  Widget _buildTile(BuildContext context, String symbol) {
    if (symbol.isEmpty) {
      return const SizedBox(width: 35, height: 35);
    }
    return GestureDetector(
      onTap: () => _showElementDetails(context, symbol),
      child: Container(
        width: 35,
        height: 35,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: _getElementColor(symbol),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black),
        ),
        child: Center(
          child: Text(
            symbol,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  void _showElementDetails(BuildContext context, String symbol) {
    Color elementColor =
        _getElementColor(symbol); // Fetching the color dynamically

    showDialog(
      context: context,
      builder: (context) {
        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.8, end: 1.0),
          duration: Duration(milliseconds: 300),
          builder: (context, double scale, child) {
            return Transform.scale(
              scale: scale,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: elementColor
                    .withOpacity(0.95), // Dynamically setting the color
                elevation: 10,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.science,
                      size: 50,
                      color: Colors.white, // Icon remains readable on any color
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Element: $symbol",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Ensuring contrast
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getElementDetails(symbol),
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                      label: Text("Close"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor:
                            elementColor, // Button matches element color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getElementDetails(String symbol) {
    for (var row in periodicTable) {
      for (var element in row) {
        if (element != null && element.symbol == symbol) {
          return "${element.name}\n"
              "Atomic Number: ${element.atomicNumber}\n"
              "Atomic Mass: ${element.atomicMass}\n"
              "Melting Point: ${element.meltingPoint ?? 'N/A'} K\n"
              "Boiling Point: ${element.boilingPoint ?? 'N/A'} K\n"
              "Electronegativity: ${element.electronegativity ?? 'N/A'}";
        }
      }
    }
    return "Information not available";
  }

  Color _getElementColor(String symbol) {
    for (var row in periodicTable) {
      for (var element in row) {
        if (element != null && element.symbol == symbol) {
          return element.color;
        }
      }
    }
    return Colors.grey; // Default color if the element is not found
  }
}

class LegendSection extends StatelessWidget {
  const LegendSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 320, // Slightly wider for better spacing
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white, // Clean white background
          borderRadius: BorderRadius.circular(15), // Smooth rounded edges
          border: Border.all(color: Colors.black87, width: 2), // Bold border
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3), // More visible shadow
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Element Groups",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            legendItem(Colors.lime.shade700, "Alkali metals"),
            legendItem(Colors.orange.shade700, "Alkaline earth metals"),
            legendItem(Colors.yellow.shade700, "Transition Metal"),
            legendItem(Colors.purple.shade700, "Lanthanides"),
            legendItem(Colors.red.shade700, "Actinides"),
            legendItem(Colors.green.shade700, "Reactive non-metals"),
            legendItem(Colors.blue.shade700, "Halogens"),
            legendItem(Colors.cyan.shade700, "Noble gases"),
          ],
        ),
      ),
    );
  }

  Widget legendItem(Color color, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 25, // Bigger for better visibility
            height: 25,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6), // Smooth corner
              border: Border.all(color: Colors.black87, width: 1),
            ),
          ),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(fontSize: 16, color: Colors.black)),
        ],
      ),
    );
  }
}
