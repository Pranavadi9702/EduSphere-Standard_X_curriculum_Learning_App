import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double screenHeight = MediaQuery.sizeOf(context).height;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Favorites")),
        body: const Center(child: Text("You need to be logged in!")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color(0xFF1D56CF), // Matching theme color
        elevation: 0,
        title: Text(
          "Favourite Subjects",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05,
            color: Colors.white, // White text for better contrast
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No favorite subjects found!",style: TextStyle(color: Colors.black,fontSize: 18),));
          }

          final favoriteSubjects = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.builder(
              itemCount: favoriteSubjects.length,
              itemBuilder: (context, index) {
                var subjectData =
                    favoriteSubjects[index].data() as Map<String, dynamic>;

                return FavoriteSubjectCard(
                  subjectId: favoriteSubjects[index].id,
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

class FavoriteSubjectCard extends StatefulWidget {
  final String subjectId;
  final Map<String, dynamic> subject;

  const FavoriteSubjectCard({
    super.key,
    required this.subjectId,
    required this.subject,
  });

  @override
  _FavoriteSubjectCardState createState() => _FavoriteSubjectCardState();
}

class _FavoriteSubjectCardState extends State<FavoriteSubjectCard> {
  void _removeFromFavorites() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.subjectId)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
                      widget.subject["image"],
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
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: _removeFromFavorites,
            ),
          ],
        ),
      ),
    );
  }
}
