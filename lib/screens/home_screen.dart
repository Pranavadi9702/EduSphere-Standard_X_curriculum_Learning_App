import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learning_app/main.dart';
import 'package:e_learning_app/providers/font_size_provider.dart';
import 'package:e_learning_app/providers/theme_provider.dart';
import 'package:e_learning_app/screens/achiever_detail_page.dart';
import 'package:e_learning_app/screens/breathing_icon_container.dart';
import 'package:e_learning_app/screens/community_first.dart';
import 'package:e_learning_app/screens/data_upload.dart';
import 'package:e_learning_app/screens/leaderboards.dart';
import 'package:e_learning_app/screens/lessons.dart';
import 'package:e_learning_app/screens/map.dart';
import 'package:e_learning_app/screens/subject_overview.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_learning_app/screens/chatbot.dart';
import 'package:e_learning_app/screens/pythogoras_visualizer.dart';
import 'package:e_learning_app/screens/perodictable.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final int selectedIndex;

  const HomePage({super.key, required this.selectedIndex});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String? userBoard;
  int _currentIndex = 0;
  List<String> _dailyFacts = [];
  int _factIndex = 0;
  late Timer _timer;
  List<Map<String, dynamic>> _allCourses = []; // All courses
  List<Map<String, dynamic>> _filteredCourses = [];
  List<String> _recommendedSubjects = [];
  bool _isDrawerOpen = false; // State to track drawer visibility
  bool _isSearching = false;
  bool _showRecommended = true;

  List<String> _subjects = []; // List to store subjects
  int _currentSubjectIndex = 0; // Index to track current subject
  late Timer _searchHintTimer; // Timer for updating search hint text

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _isSearching = value.isNotEmpty; // Track search state

      if (value.isEmpty) {
        _filteredCourses = List.from(_allCourses);
      } else {
        _filteredCourses = _allCourses.where((course) {
          final title = course['title']!.toLowerCase();
          final searchLower = value.toLowerCase();
          return title.contains(searchLower);
        }).toList();
      }
    });
  }

  void _navigateToSearchPage(String query) {
    List<Map<String, dynamic>> filteredChapters = _allCourses.where((course) {
      return course['title']!.toLowerCase().contains(query.toLowerCase());
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChapterListPage(chapters: filteredChapters),
      ),
    );
  }

  Future<void> _fetchUserPreferences() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists && userDoc.data() != null) {
      setState(() {
        userBoard = userDoc['board'];
      });

      // Fetch courses after retrieving the board
      await _fetchCourses();
    }
  }

  Future<void> _fetchDailyFacts() async {
    List<String> facts = await FirestoreService().fetchDailyFacts();

    setState(() {
      _dailyFacts = facts.isNotEmpty
          ? facts
          : ['No fact available. Please check your internet.']; // Default Fact
      _factIndex = 0; // Reset index after fetching
    });
  }

  Future<void> _fetchCourses() async {
    if (userBoard == null || userBoard!.isEmpty) return; // Safe check
    // Ensure the board is selected

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('boards')
        .doc(userBoard)
        .collection('subjects') // Assuming courses are stored under each board
        .get();

    List<Map<String, dynamic>> courses = querySnapshot.docs.map((doc) {
      return {
        "title": doc["title"],
        "topics": doc["topics"],
        "duration": doc["duration"],
        "level": doc["level"],
        "isFavorite": doc["isFavorite"] ?? false,
        "image": doc["image"],
      };
    }).toList();

    setState(() {
      _allCourses = courses;
      _filteredCourses = List.from(_allCourses);
    });
  }

  Future<void> _fetchSubjects() async {
    List<String>? subjects = [];
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('boards')
          .doc('ICSE') // Specify the board you want to fetch subjects from
          .collection('subjects')
          .get();

      // Fetch subjects
      subjects = querySnapshot.docs
          .map((doc) => doc.get('name') ?? '')
          .cast<
              String>() // Safely retrieve 'name' field, default to empty string if null
          .toList();
    } catch (e) {
      print('Error fetching subjects: $e');
      // Handle the error or provide a default list of subjects if needed
      subjects = [
        'Science',
        'Mathematics',
        'Geography',
        'History',
        'English',
        'Economics',
      ]; // Example default subjects
    }

    setState(() {
      _subjects = subjects!;
      _currentSubjectIndex = 0; // Reset index
    });
  }

  Future<void> _fetchRecommendedSubjects() async {
    List<String> recommendedSubjects =
        await _fetchRecommendedSubjectsFromFirestore();
    setState(() {
      _recommendedSubjects = recommendedSubjects;
    });
  }

  Future<List<String>> _fetchRecommendedSubjectsFromFirestore() async {
    List<String> recommendedSubjects = [];

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('quiz_results')
        .where('percentage', isLessThan: 40)
        .get();

    if (snapshot.docs.isNotEmpty) {
      for (var doc in snapshot.docs) {
        // Assuming each document has a 'subject' field
        String? subject = doc.get('subject');
        if (subject != null) {
          recommendedSubjects.add(subject);
        } else {
          // If 'subject' field is missing, you can either ignore it or handle it as needed
        }
      }
    }

    return recommendedSubjects
        .toSet()
        .toList(); // Convert to a set and back to list to remove duplicates
  }

  List<Map<String, dynamic>> getRecommendedCourses() {
    return _allCourses.where((course) {
      return _recommendedSubjects.contains(course['title']);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchUserPreferences();
    _fetchDailyFacts();
    _fetchCourses();
    _fetchSubjects();
    _fetchRecommendedSubjects(); // Fetch recommended subjects

    _currentIndex = widget.selectedIndex;

    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_dailyFacts.isNotEmpty) {
        setState(() {
          _factIndex = Random().nextInt(_dailyFacts.length);
        });
      }
    });

    // Timer for updating search hint text
    _searchHintTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (_subjects.isNotEmpty) {
        setState(() {
          _currentSubjectIndex = (_currentSubjectIndex + 1) % _subjects.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel daily fact timer
    _searchHintTimer.cancel(); // Cancel search hint timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    User? user = FirebaseAuth.instance.currentUser;
    String userName = user?.displayName ?? 'Guest';

    return Scaffold(
      backgroundColor: Colors.white,

      drawer: AppDrawer(), // Ensure AppDrawer is correctly implemented
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70), // Adjust the height of the AppBar
        child: AppBar(
          backgroundColor: Colors.white, // Adjust based on your theme
          elevation: 0, // Remove shadow if needed
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Open drawer
              },
            ),
          ),

          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hi, $userName", // Dynamic greeting
                style: TextStyle(
                  fontSize: fontSizeProvider.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Find your lessons Today!", // Subtitle
                style: TextStyle(
                  color: Colors.black,
                  fontSize: fontSizeProvider.fontSize,
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 20),
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.chat, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(
                  color: Colors.black), // Change text color to black
              onSubmitted: _navigateToSearchPage,
              decoration: InputDecoration(
                hintText: _subjects.isNotEmpty
                    ? "Search for ${_subjects[_currentSubjectIndex]}"
                    : "Search now...",
                hintStyle: const TextStyle(
                    color: Colors.grey), // Make hint text visible
                prefixIcon:
                    const Icon(Icons.search, color: Colors.black), // Icon color
                filled: true,
                fillColor: Colors.grey.shade100, // Background color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Daily Fact Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1D56CF), // Primary deep blue
                    const Color(0xFF4A90E2), // Softer sky blue for contrast
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1D56CF)
                        .withOpacity(0.4), // Soft shadow from the theme
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BreathingIconContainer(),
                  SizedBox(width: 12),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    height: 120,
                    width: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🌟 ${"Today's Fact"}',
                          style: TextStyle(
                            fontSize: fontSizeProvider.fontSize,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _dailyFacts.isNotEmpty
                              ? _dailyFacts[_factIndex]
                              : "Fetching fact...",
                          style: TextStyle(
                            fontSize: fontSizeProvider.fontSize,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            height: 1.4,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Popular Lessons", // Translated Popular Lessons
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    // ignore: await_only_futures
                    await AuthCheck(); // Call authCheck before navigation

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubjectsScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "See All",
                    style: TextStyle(fontSize: fontSizeProvider.fontSize),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 300,
              child: userBoard == null
                  ? const Center(
                      child: CircularProgressIndicator()) // Show loader
                  : _filteredCourses.isEmpty
                      ? Center(
                          child: Text("No courses available for $userBoard"))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _filteredCourses.length,
                          itemBuilder: (context, index) {
                            final course = _filteredCourses[index];

                            return Padding(
                              padding: const EdgeInsets.only(right: 18.0),
                              child: LessonCard(
                                userId: FirebaseAuth.instance.currentUser!.uid,
                                userBoard: userBoard!, // Pass `userBoard`
                                title: course["title"],
                                lessons: "${course["topics"]} chapters",
                                time: course["duration"],
                                rating: "4.5",
                                level: course[
                                    "level"], // Adjust if ratings exist in Firestore
                                imageUrl: course["image"],
                              ),
                            );
                          },
                        ),
            ),
            const SizedBox(
              height: 20,
            ),
            const AnnouncementsContainer(),
            AchieversContainer(),
          ],
        ),
      ),
    );
  }

//     Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           "Recommended Courses",
  //           style: TextStyle(
  //             fontSize: 20,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.black,
  //           ),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => SubjectsScreen(),
  //               ),
  //             );
  //           },
  //           child: Text(
  //             "See All",
  //             style: TextStyle(fontSize: fontSizeProvider.fontSize),
  //           ),
  //         ),
  //       ],
  //     ),
  //     SizedBox(
  //       height: 300,
  //       child: userBoard == null
  //           ? const Center(child: CircularProgressIndicator())
  //           : _buildRecommendedCourses(),
  //     ),

  //     const SizedBox(height: 20),
  //     // Announcements
  //     const AnnouncementsContainer(),
  //     AchieversContainer(),
  Widget _buildRecommendedCourses() {
    List<Map<String, dynamic>> recommendedCourses = getRecommendedCourses();

    if (recommendedCourses.isEmpty) {
      return Center(child: Text("No recommended courses available."));
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: recommendedCourses.length,
      itemBuilder: (context, index) {
        final course = recommendedCourses[index];
        return Padding(
          padding: const EdgeInsets.only(right: 18.0),
          child: LessonCard(
            userId: FirebaseAuth.instance.currentUser!.uid,
            userBoard: userBoard!,
            title: course["title"],
            lessons: "${course["topics"]} chapters",
            time: course["duration"],
            rating: "4.5",
            level: course["level"],
            imageUrl: course["image"],
          ),
        );
      },
    );
  }

  Widget _buildAllCourses() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _filteredCourses.length,
      itemBuilder: (context, index) {
        final course = _filteredCourses[index];
        return Padding(
          padding: const EdgeInsets.only(right: 18.0),
          child: LessonCard(
            userId: FirebaseAuth.instance.currentUser!.uid,
            userBoard: userBoard!,
            title: course["title"],
            lessons: "${course["topics"]} chapters",
            time: course["duration"],
            rating: "4.5",
            level: course["level"],
            imageUrl: course["image"],
          ),
        );
      },
    );
  }
}

class LessonCard extends StatelessWidget {
  final String userBoard; // ✅ Used only for navigation, not displayed
  final String title;
  final String lessons;
  final String time;
  final String rating;
  final String level;
  final String imageUrl;
  final String userId;

  const LessonCard({
    super.key,
    required this.userBoard,
    required this.userId,
    required this.title,
    required this.lessons,
    required this.time,
    required this.rating,
    required this.level,
    required this.imageUrl,
  });

  Widget _loadImage(String imageUrl) {
    if (imageUrl.startsWith("http") || imageUrl.startsWith("https")) {
      return Image.network(
        imageUrl,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.broken_image,
          size: 48,
          color: Colors.grey,
        ),
      );
    } else if (imageUrl.startsWith("assets/")) {
      return Image.asset(
        imageUrl,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.error,
          size: 48,
          color: Colors.grey,
        ),
      );
    } else {
      return const Icon(
        Icons.broken_image,
        size: 48,
        color: Colors.grey,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SubjectOverviewPage(board: userBoard, subject: title),
          ),
        );
      },
      child: Container(
        width: 180,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Lesson Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: _loadImage(imageUrl),
            ),

            // 🔹 Lesson Details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lesson Title
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // 🔹 Lessons Count
                  Row(
                    children: [
                      const Icon(Icons.menu_book, size: 18, color: Colors.blue),
                      const SizedBox(width: 6),
                      Text(
                        lessons,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // 🔹 Duration
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 18, color: Colors.orange),
                      const SizedBox(width: 6),
                      Text(
                        time,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // 🔹 Rating
                  Row(
                    children: [
                      const Icon(Icons.star, size: 18, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text(
                        rating,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // 🔹 Level
                  Row(
                    children: [
                      const Icon(Icons.trending_up,
                          size: 18, color: Colors.green),
                      const SizedBox(width: 6),
                      Text(
                        "Level: $level",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnnouncementsContainer extends StatelessWidget {
  const AnnouncementsContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📢 Announcements',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        SizedBox(
          height: 16,
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: 5, // Adjust as needed
                  itemBuilder: (context, index) {
                    return _buildAnnouncement(
                      context,
                      'Announcement ${index + 1}',
                      'This is an important update. Stay tuned for more details!',
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncement(
      BuildContext context, String title, String description) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.notifications, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: fontSizeProvider.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: fontSizeProvider.fontSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF1D56CF),
            ),
            child: Center(
              child: Text(
                'EduSphere',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ), // ❌ Removed extra closing bracket here

          ListTile(
            leading: Icon(Icons.leaderboard),
            title: Text('Leaderboards'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LeaderboardsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.group),
            title: Text('Community Chat'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommunityChatPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.calculate),
            title: Text('Pythogoras Theorem Visualizer'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PythagorasScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.table_chart),
            title: Text('Periodic Table'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PeriodicTableScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.map),
            title: Text('Geography Map visualization'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapSelectionScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ChapterListPage extends StatelessWidget {
  final List<Map<String, dynamic>> chapters;

  const ChapterListPage({super.key, required this.chapters});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FF),
      appBar: AppBar(
        title: const Text("Chapters",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFFF6F6FF),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          var chapter = chapters[index];
          return _buildChapterCard(chapter);
        },
      ),
    );
  }

  Widget _buildChapterCard(Map<String, dynamic> chapter) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            chapter["image"],
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(chapter["title"],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${chapter["level"]} / ${chapter["topics"]} Topics",
                style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            Text(chapter["duration"],
                style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          ],
        ),
        trailing: Icon(
          chapter["isFavorite"] ? Icons.favorite : Icons.favorite_border,
          color: chapter["isFavorite"] ? Colors.red : Colors.grey,
        ),
      ),
    );
  }
}

class AchieversContainer extends StatelessWidget {
  final List<Map<String, dynamic>> _achievers = [
    {
      "name": "Aarav Sharma",
      "score": "98%",
      "imageUrl": "assets/aarav.png",
      "description":
          "Aarav is a math prodigy excelling in problem-solving and logical thinking. "
              "He has won state-level Olympiads and enjoys coding in Python. "
              "His dream is to become a data scientist and work on AI-driven projects."
    },
    {
      "name": "Sanya Verma",
      "score": "96%",
      "imageUrl": "assets/sanya.png",
      "description": "Sanya is a passionate reader and a top English scholar. "
          "She has won awards for literature and represented her school in debates. "
          "Her dream is to publish her first novel soon."
    },
    {
      "name": "Rahul Mehta",
      "score": "94%",
      "imageUrl": "assets/rahul.png",
      "description":
          "Rahul is a science enthusiast with a deep interest in physics. "
              "He has won robotics competitions and believes technology can change the world. "
              "His goal is to pursue aerospace engineering."
    },
    {
      "name": "Pooja Nair",
      "score": "93%",
      "imageUrl": "assets/pooja.png",
      "description": "Pooja is a history buff with expertise in social sciences. "
          "She has led research on ancient civilizations and enjoys writing articles. "
          "Her goal is to become a historian and author."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          '🏆 Top Achievers',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "Meet our top achievers who have excelled in academics! "
            "Their hard work and dedication are truly inspiring. "
            "Strive for excellence and you could be featured here too!",
            style:
                TextStyle(fontSize: 16, color: Color.fromARGB(255, 97, 97, 97)),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Show 2 profiles per row
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85, // Controls height proportion
          ),
          itemCount: _achievers.length,
          itemBuilder: (context, index) {
            final achiever = _achievers[index];
            return _buildAchieverCard(context, achiever); // Pass the context
          },
        ),
      ],
    );
  }

  Widget _buildAchieverCard(
      BuildContext context, Map<String, dynamic> achiever) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AchieverDetailPage(achiever: achiever),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(achiever["imageUrl"]),
              radius: 40,
            ),
            const SizedBox(height: 8),
            Text(
              achiever["name"],
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            Text(
              "Score: ${achiever["score"]}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                achiever["description"],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black),
                softWrap: true,
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
