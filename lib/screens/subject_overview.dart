import 'package:e_learning_app/screens/flashcards.dart';
import 'package:e_learning_app/screens/quiz_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';

class SubjectOverviewPage extends StatefulWidget {
  final String board; // Selected board
  final String subject; // Selected subject

  const SubjectOverviewPage(
      {super.key, required this.board, required this.subject});

  @override
  _SubjectOverviewPageState createState() => _SubjectOverviewPageState();
}

class _SubjectOverviewPageState extends State<SubjectOverviewPage> {
  String subjectImagePath = "assets/default.png"; // Default image path
  QuerySnapshot? querySnapshot; // Define the variable
  String subjectDescription =
      "No description available"; // Initialize with default value
  List<Map<String, dynamic>> _lessons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSubjectDetails();
  }

  final Map<String, String> subjectImages = {
    "Economics": "assets/economics.png",
    "Mathematics": "assets/mathematics.png",
    "Science": "assets/science.png",
    "History": "assets/history.png",
    "Geography": "assets/geography.png",
  };

  // Fetch lessons from Firestore dynamically
  Future<void> _fetchSubjectDetails() async {
    try {
      DocumentSnapshot subjectDoc = await FirebaseFirestore.instance
          .collection('boards')
          .doc(widget.board)
          .collection('subjects')
          .doc(widget.subject)
          .get();

      querySnapshot = await FirebaseFirestore.instance
          .collection('boards')
          .doc(widget.board)
          .collection('subjects')
          .doc(widget.subject)
          .collection('chapters')
          .get();

      List<Map<String, dynamic>> chapters = querySnapshot!.docs.map((doc) {
        return {
          "title": doc["title"] ?? "No Title",
          "duration": doc["duration"] ?? "Unknown",
          "videoURL": doc["videoURL"] ?? "",
          "chapterId": doc.id, // Store chapter ID
        };
      }).toList();

      setState(() {
        _lessons = chapters;
        subjectDescription = subjectDoc.exists
            ? subjectDoc["description"] ?? "No description available"
            : "No description available";

        // Fetch image URL from Firestore
        subjectImagePath = subjectDoc.exists
            ? subjectDoc["image"] ?? "assets/default.png"
            : "assets/default.png";

        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 246, 246, 255),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1D56CF),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.subject,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      subjectImagePath,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/default.png', // Fallback image if asset not found
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
            const TabBar(
              indicatorColor: Colors.blue,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorWeight: 4.0,
              tabs: [
                Tab(text: "Lessons"),
                Tab(text: "Description"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _lessons.isEmpty
                          ? const Center(child: Text("No chapters available"))
                          : ListView.builder(
                              itemCount: _lessons.length,
                              itemBuilder: (context, index) {
                                final chapter = _lessons[index];
                                return ChapterTile(
                                  index: index,
                                  title: chapter["title"],
                                  duration: chapter["duration"],
                                  videoURL: chapter["videoURL"],
                                  chapterId: chapter["chapterId"],
                                  subjectDescription: subjectDescription,
                                  subjectName: widget.subject,
                                  board: widget.board, // Pass board
                                );
                              },
                            ),
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Text(
                                subjectDescription,
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.black),
                              ),
                      ],
                    ),
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

class ChapterTile extends StatefulWidget {
  final int index;
  final String title;
  final String duration;
  final String videoURL;
  final String chapterId;
  final String subjectDescription;
  final String subjectName;
  final String board;

  const ChapterTile({
    super.key,
    required this.index,
    required this.title,
    required this.duration,
    required this.videoURL,
    required this.chapterId,
    required this.subjectDescription,
    required this.subjectName,
    required this.board,
  });

  @override
  _ChapterTileState createState() => _ChapterTileState();
}

class _ChapterTileState extends State<ChapterTile>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  double videoProgress = 0.0; // Progress for the video
  double quizProgress = 0.0; // Progress for the quiz
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _progressAnimation =
        Tween<double>(begin: 0.0, end: 0.0).animate(_progressController);
    _fetchChapterProgress();
  }

  void _fetchChapterProgress() async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    DocumentSnapshot progressDoc = await FirebaseFirestore.instance
        .collection('user_progress')
        .doc(uid)
        .collection(widget.board)
        .doc(widget.subjectName)
        .collection('chapters')
        .doc(widget.chapterId)
        .get();

    if (progressDoc.exists) {
      setState(() {
        videoProgress = progressDoc.get('videoProgress') ?? 0.0;
        quizProgress = progressDoc.get('quizProgress') ?? 0.0;
      });
    } else {
      // Create the document if it doesn't exist
      await FirebaseFirestore.instance
          .collection('user_progress')
          .doc(uid)
          .collection(widget.board)
          .doc(widget.subjectName)
          .collection('chapters')
          .doc(widget.chapterId)
          .set({
        'videoProgress': 0.0,
        'quizProgress': 0.0,
      });
    }

    _updateProgressAnimation();
  }

  void _updateChapterProgress(
      double newVideoProgress, double newQuizProgress) async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('user_progress')
        .doc(uid)
        .collection(widget.board)
        .doc(widget.subjectName)
        .collection('chapters')
        .doc(widget.chapterId)
        .set({
      'videoProgress': newVideoProgress,
      'quizProgress': newQuizProgress,
    }, SetOptions(merge: true));

    setState(() {
      videoProgress = newVideoProgress;
      quizProgress = newQuizProgress;
    });

    _updateProgressAnimation();
  }

  void _updateProgressAnimation() {
    double overallProgress = (videoProgress + quizProgress) / 2;
    _progressAnimation =
        Tween<double>(begin: _progressAnimation.value, end: overallProgress)
            .animate(_progressController);
    _progressController.reset();
    _progressController.forward();
  }

  void _navigateToFlashcards() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardScreen(
          board: widget.board,
          subject: widget.subjectName,
          chapter: widget.chapterId, // Update if dynamic
        ),
      ),
    );
  }

  void _navigateToQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPage(
          board: widget.board,
          subject: widget.subjectName,
          chapter: widget.chapterId, // Update if dynamic
        ),
      ),
    );
  }

  void _playVideo(BuildContext context, String subjectDescription, int index) {
    final videoId = _extractVideoId(widget.videoURL);
    if (videoId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => YoutubePlayerPage(
            videoId: videoId,
            title: "Chapter ${widget.index + 1}: ${widget.title}",
            description: subjectDescription,
            subjectName: widget.subjectName,
            chapterId: widget.chapterId,
            board: widget.board,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid YouTube URL.')),
      );
    }
  }

  String? _extractVideoId(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.queryParameters.containsKey('v')) {
      return uri.queryParameters['v'];
    } else if (uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.last;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: GestureDetector(
            onTap: () {
              _playVideo(context, widget.subjectDescription, widget.index);
            },
            child: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.play_arrow, color: Colors.blue),
                  CircularProgressIndicator(
                    value: _progressAnimation.value,
                    strokeWidth: 2,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ],
              ),
            ),
          ),
          title: Text(
            "Chapter ${widget.index + 1}: ${widget.title}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(widget.duration),
          trailing: GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  size: 28,
                  color: Colors.grey,
                ),
                Container(
                  width: 32,
                  height: 1,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.only(top: 4),
                ),
              ],
            ),
          ),
        ),

        // Smooth Expand/Collapse Animation
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isExpanded
              ? ClipRRect(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _navigateToFlashcards,
                          icon: const Icon(Icons.style),
                          label: const Text("Flashcards"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _navigateToQuiz,
                          icon: const Icon(Icons.quiz),
                          label: const Text("Quiz"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(), // Empty container to animate smoothly
        ),

        Divider(
          color: Colors.grey.shade300,
          thickness: 1,
          height: 0,
        ),
      ],
    );
  }
}

class YoutubePlayerPage extends StatefulWidget {
  final String videoId;
  final String title; // Chapter title
  final String description;
  final String subjectName; // Subject name
  final String chapterId;
  final String board;

  const YoutubePlayerPage({
    super.key,
    required this.videoId,
    required this.title,
    required this.description,
    required this.subjectName,
    required this.chapterId,
    required this.board,
  });

  @override
  _YoutubePlayerPageState createState() => _YoutubePlayerPageState();
}

class _YoutubePlayerPageState extends State<YoutubePlayerPage> {
  late YoutubePlayerController _controller;
  bool isFullScreen = false;
  String? userBoard;
  double videoProgress = 0.0;
  double quizProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchUserBoard();
    _fetchChapterProgress();

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
      ),
    );

    _controller.addListener(() {
      setState(() {
        isFullScreen = _controller.value.isFullScreen;
      });

      if (isFullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }

      // Update video progress in real-time
      if (_controller.value.position.inSeconds > 0 &&
          _controller.metadata.duration.inSeconds > 0) {
        videoProgress = _controller.value.position.inSeconds /
            _controller.metadata.duration.inSeconds;
        _updateChapterProgress(videoProgress, quizProgress);
      }
    });
  }

  Future<void> _fetchUserBoard() async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists && userDoc.data() != null) {
      setState(() {
        userBoard = userDoc.get('board');
      });
    }
  }

  Future<void> _fetchChapterProgress() async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    DocumentSnapshot progressDoc = await FirebaseFirestore.instance
        .collection('user_progress')
        .doc(uid)
        .collection(widget.board)
        .doc(widget.subjectName)
        .collection('chapters')
        .doc(widget.chapterId)
        .get();

    if (progressDoc.exists) {
      setState(() {
        videoProgress = progressDoc.get('videoProgress') ?? 0.0;
        quizProgress = progressDoc.get('quizProgress') ?? 0.0;
      });
    } else {
      // Create the document if it doesn't exist
      await FirebaseFirestore.instance
          .collection('user_progress')
          .doc(uid)
          .collection(widget.board)
          .doc(widget.subjectName)
          .collection('chapters')
          .doc(widget.chapterId)
          .set({
        'videoProgress': 0.0,
        'quizProgress': 0.0,
      });
    }
  }

  void _updateChapterProgress(
      double newVideoProgress, double newQuizProgress) async {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('user_progress')
        .doc(uid)
        .collection(widget.board)
        .doc(widget.subjectName)
        .collection('chapters')
        .doc(widget.chapterId)
        .set({
      'videoProgress': newVideoProgress,
      'quizProgress': newQuizProgress,
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    double overallProgress = (videoProgress + quizProgress) / 2;

    return Scaffold(
      appBar: isFullScreen
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF1D56CF),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(
                widget.title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          onReady: () {
            debugPrint('Player is ready.');
          },
          onEnded: (data) {
            _updateChapterProgress(
                1.0, quizProgress); // Mark video as completed
          },
        ),
        builder: (context, player) {
          return Column(
            children: [
              player,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.description,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller.dispose();
    super.dispose();
  }
}
