import 'package:e_learning_app/main.dart';
import 'package:e_learning_app/screens/subject_overview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  _SubjectsScreenState createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  String? userBoard; // 🔹 Store selected board

  @override
  void initState() {
    super.initState();
    _fetchUserBoard();
  }

  /// 🔹 Fetch User's Selected Board from Firestore
  Future<void> _fetchUserBoard() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        userBoard = userDoc["board"] ?? "CBSE"; // Default to CBSE if null
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    if (userBoard == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()), // 🔹 Show loading
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
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
          '$userBoard Subjects',
          style: TextStyle(
            color: Colors.white, // White text for contrast
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('boards')
            .doc(userBoard)
            .collection('subjects')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text("No subjects available for $userBoard",
                    style: const TextStyle(fontSize: 16)));
          }

          final subjects = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.builder(
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                var subjectData =
                    subjects[index].data() as Map<String, dynamic>? ?? {};
                return SubjectCard(
                  subjectId: subjects[index].id,
                  boardId: userBoard!,
                  subject: subjectData,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class SubjectCard extends StatefulWidget {
  final String boardId;
  final String subjectId;
  final Map<String, dynamic> subject;

  const SubjectCard({
    super.key,
    required this.boardId,
    required this.subjectId,
    required this.subject,
  });

  @override
  _SubjectCardState createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.subject["isFavorite"] ?? false;
    _checkIfFavorite();
  }

  void _checkIfFavorite() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot favoriteDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(widget.subjectId)
        .get();

    if (mounted) {
      setState(() {
        isFavorite = favoriteDoc.exists;
      });
    }
  }

  void toggleFavorite() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      isFavorite = !isFavorite;
    });

    DocumentReference favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(widget.subjectId);

    if (isFavorite) {
      await favRef.set({
        "title": widget.subject["title"],
        "boardId": widget.boardId,
        "subjectId": widget.subjectId,
        "image": widget.subject["image"] ?? "",
        "level": widget.subject["level"] ?? "N/A",
        "topics": widget.subject["topics"] ?? 0,
        "duration": widget.subject["duration"] ?? "Unknown",
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${widget.subject["title"]} added to favorites"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      await favRef.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${widget.subject["title"]} removed from favorites"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
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
            builder: (context) => SubjectOverviewPage(
              board: widget.boardId,
              subject: widget.subjectId,
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: widget.subject["image"] != null &&
                        widget.subject["image"].startsWith("assets/")
                    ? Image.asset(
                        "${widget.subject["image"]}",
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.image_not_supported,
                        size: 70, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.subject["title"] ?? "No Title",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${widget.subject["level"] ?? "N/A"} / ${widget.subject["topics"] ?? 0} Topics",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subject["duration"] ?? "Unknown Duration",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: toggleFavorite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
