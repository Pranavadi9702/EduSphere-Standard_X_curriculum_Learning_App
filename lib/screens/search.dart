import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatefulWidget {
  final String? query;
  const SearchPage({super.key, this.query});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allLessons = [];
  List<Map<String, dynamic>> _filteredLessons = [];
  bool _isSearching = false; // Track search state

  @override
  void initState() {
    super.initState();
    _initializeLessons();
    if (widget.query != null && widget.query!.isNotEmpty) {
      _searchController.text = widget.query!;
      _filterLessons(widget.query!);
      _isSearching = true; // Ensure state reflects active search
    }
    _searchController.addListener(() {
      _filterLessons(_searchController.text);
    });
  }

  Widget _buildDailyFacts() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        "🌍 Daily Fact: Did you know...?",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAnnouncements() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        "📢 Announcements: New courses added!",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Fetches lessons from Firestore and updates state
  void _initializeLessons() async {
    String board = "CBSE"; // Make dynamic if needed
    String subject = "Economics";

    DocumentSnapshot subjectSnapshot = await FirebaseFirestore.instance
        .collection('boards')
        .doc(board)
        .collection('subjects')
        .doc(subject)
        .get();

    if (!subjectSnapshot.exists) return;

    Map<String, dynamic>? subjectData =
        subjectSnapshot.data() as Map<String, dynamic>?;

    QuerySnapshot lessonSnapshot = await FirebaseFirestore.instance
        .collection('boards')
        .doc(board)
        .collection('subjects')
        .doc(subject)
        .collection('lessons')
        .get();

    List<Map<String, dynamic>> lessons = lessonSnapshot.docs.map((doc) {
      return {
        "title": (doc["title"] ?? "").trim(), // Trim the title
        "topics": doc["topics"] ?? "No Topics",
        "duration": doc["duration"] ?? "Unknown Duration",
        "isFavorite": doc["isFavorite"] ?? false,
        "image": doc["image"] ?? "assets/default.png",
        "description": subjectData?["description"] ?? "No Description",
        "level": subjectData?["level"] ?? "Unknown Level",
      };
    }).toList();

    setState(() {
      _allLessons = lessons;
      _filteredLessons = List.from(_allLessons);
    });
  }

  void _filterLessons(String query) {
    String trimmedQuery = query.trim().toLowerCase();
    setState(() {
      if (trimmedQuery.isEmpty) {
        _isSearching = false;
        _filteredLessons = List.from(_allLessons); // Reset filtered list
      } else {
        _isSearching = true;
        _filteredLessons = _allLessons
            .where((lesson) =>
                lesson["title"].toLowerCase().contains(trimmedQuery))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FF),
      appBar: AppBar(
        title: const Text("Search",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFFF6F6FF),
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () {
            setState(() {
              _isSearching = false;
            });
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterLessons,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Search now...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (!_isSearching) ...[
            _buildDailyFacts(), // Show daily facts when not searching
            _buildAnnouncements(), // Show announcements when not searching
          ],
          Expanded(
            child: _filteredLessons.isEmpty
                ? (_isSearching
                    ? const Center(child: Text("No results found"))
                    : const SizedBox.shrink()) // Hide UI when search is active
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _filteredLessons.length,
                    itemBuilder: (context, index) {
                      var lesson = _filteredLessons[index];
                      return _buildLessonCard(lesson);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Builds a lesson card with the new fields
  Widget _buildLessonCard(Map<String, dynamic> lesson) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            lesson["image"],
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(lesson["title"],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lesson["topics"] ?? "No Topics", // Handle null or empty topics
                style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            Text(
                lesson["duration"] ??
                    "Unknown Duration", // Handle null or empty duration
                style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            Text(
                "Level: ${lesson["level"] ?? "Unknown Level"}", // Handle null or empty level
                style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            Text(
                "Description: ${lesson["description"] ?? "No Description"}", // Handle null or empty description
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        trailing: Icon(
          lesson["isFavorite"] ? Icons.favorite : Icons.favorite_border,
          color: lesson["isFavorite"] ? Colors.red : Colors.grey,
        ),
        onTap: () {
          // Navigate to lesson details if required
        },
      ),
    );
  }
}
