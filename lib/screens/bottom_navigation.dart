import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/lessons.dart';
import '../screens/notes_page.dart';
import '../screens/profile_screen.dart';

class CustomBottomNavigation extends StatefulWidget {
  const CustomBottomNavigation({super.key});

  @override
  _CustomBottomNavigationState createState() => _CustomBottomNavigationState();
}

class _CustomBottomNavigationState extends State<CustomBottomNavigation> {
  int _currentIndex = 0;
  final PageController _pageController =
      PageController(); // ✅ PageView for smooth switching

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index); // ✅ Prevents screen rebuild
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0, // ✅ Allows exit only on Home screen
      onPopInvoked: (didPop) {
        if (!didPop && _currentIndex != 0) {
          _onItemTapped(0); // ✅ Navigate back to Home instead of exiting
        }
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics:
              const NeverScrollableScrollPhysics(), // 🔹 Disable swipe navigation
          children: const [
            HomePage(selectedIndex: 0),
            SubjectsScreen(),
            NotesPage(selectedIndex: 2),
            ProfilePage(selectedIndex: 3),
          ],
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

// 🔹 Bottom Navigation Bar UI
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedItemColor: Colors.blue.shade700,
          unselectedItemColor: Colors.grey.shade500,
          backgroundColor: Colors.white,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          iconSize: 30,
          onTap: onTap,
          items: [
            _buildNavItem(Icons.home, 'Home', 0),
            _buildNavItem(Icons.school_sharp, 'Lessons', 1),
            _buildNavItem(Icons.description, 'Resources', 2),
            _buildNavItem(Icons.person, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      label: label,
      icon: Icon(icon,
          color: index == currentIndex
              ? Colors.blue.shade700
              : Colors.grey.shade500),
    );
  }
}
