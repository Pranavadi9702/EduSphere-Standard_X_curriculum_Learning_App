import 'package:e_learning_app/main.dart';
import 'package:e_learning_app/screens/curriculum.dart';
import 'package:e_learning_app/screens/formula_screen.dart';
import 'package:e_learning_app/screens/sets21.dart';
import 'package:flutter/material.dart';
import 'package:e_learning_app/screens/sample_paper_screen.dart';

class NotesPage extends StatefulWidget {
  final int selectedIndex;

  const NotesPage({super.key, required this.selectedIndex});

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  int _selectedIndex = 2; // ✅ Initialize selected index for NotesPage

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // ✅ Prevent unnecessary rebuilds

    setState(() {
      _selectedIndex = index;
    });

    // switch (index) {
    //   case 0:
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => HomePage(
    //           selectedIndex: 0,
    //         ),
    //       ),
    //     );
    //     break;
    //   case 1:
    //     // ✅ Stay on NotesPage (No navigation needed)
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => BoardSelectionScreen(
    //           selectedIndex: 1,
    //         ),
    //       ),
    //     );
    //     break;
    //   case 2:
    //     break;
    //   case 3:
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => ProfilePage(
    //           selectedIndex: 3,
    //         ),
    //       ),
    //     );
    //     break;
    // }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AuthCheck()),
            );
          },
        ),
        backgroundColor: Color(0xFF1D56CF), // Updated theme color
        elevation: 0,
        title: Text(
          'Resources',
          style: TextStyle(
            color: Colors.white, // White text for contrast
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildResourceItem(
              context,
              'Curriculum',
              Icons.book,
              const CurriculumScreen(),
            ),
            // _buildResourceItem(
            //   context,
            //   'Flashcards',
            //   Icons.quiz,
            //   const FlashcardScreen(),
            // ),
            _buildResourceItem(
              context,
              'Sample Paper',
              Icons.description,
              const SamplePaperScreen(),
            ),
            _buildResourceItem(
              context,
              '21 Sets',
              Icons.library_books,
              const Sets21Screen(),
            ),
            _buildResourceItem(
              context,
              'Formula Sheets',
              Icons.calculate,
              const FormulaSheetScreen(),
            ),
            _buildResourceItem(
              context,
              'E-Books & Reference',
              Icons.menu_book,
              const AuthCheck(),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: CustomBottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      // ),
    );
  }

  Widget _buildResourceItem(
      BuildContext context, String title, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              radius: 20,
              child: Icon(icon, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 18, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
