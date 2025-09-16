import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardsScreen extends StatefulWidget {
  const LeaderboardsScreen({super.key});

  @override
  _LeaderboardsScreenState createState() => _LeaderboardsScreenState();
}

class _LeaderboardsScreenState extends State<LeaderboardsScreen>
    with SingleTickerProviderStateMixin {
  String selectedCity = "All"; // Default to all cities
  List<String> cityOptions = ["All"]; // Dropdown options
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    fetchCities();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchCities() async {
    setState(() => _isLoading = true);
    try {
      var usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      Set<String> cities = usersSnapshot.docs
          .map((doc) {
            // Properly cast the data to Map<String, dynamic>
            Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
            return data != null && data.containsKey('city')
                ? data['city'].toString()
                : "Unknown";
          })
          .where((city) => city.isNotEmpty)
          .toSet();

      setState(() {
        cityOptions = [
          "All",
          ...cities.toList()..sort()
        ]; // Add "All" option and sort cities
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        cityOptions = ["All"]; // Fallback to just "All" if there's an error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading cities: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D56CF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Leaderboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // Header with trophy icon
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.amber[700],
                  size: 32,
                ),
                const SizedBox(width: 8),
                Text(
                  "Top Performers",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D56CF),
                  ),
                ),
              ],
            ),
          ),

          // City filter dropdown
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF1D56CF)),
                        ),
                      ),
                    ),
                  )
                : DropdownButtonFormField<String>(
                    value: selectedCity,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                            color: Color(0xFF1D56CF), width: 1),
                      ),
                      prefixIcon: const Icon(
                        Icons.location_city,
                        color: Color(0xFF1D56CF),
                      ),
                      hintText: "Select City",
                      labelText: "Filter by City",
                      labelStyle: const TextStyle(color: Color(0xFF1D56CF)),
                    ),
                    items: cityOptions.map((city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(
                          city,
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedCity = value;
                        });
                      }
                    },
                  ),
          ),
          // Leaderboard list
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('quiz_results')
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF1D56CF)),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState("No leaderboard data available");
              }

              var allResults = snapshot.data!.docs;
              Map<String, dynamic> bestScores = {}; // Highest score per user
              List<String> filteredUserIds = [];

              return FutureBuilder(
                future: FirebaseFirestore.instance.collection('users').get(),
                builder: (context, AsyncSnapshot<QuerySnapshot> usersSnapshot) {
                  if (usersSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF1D56CF)),
                      ),
                    );
                  }

                  if (!usersSnapshot.hasData ||
                      usersSnapshot.data!.docs.isEmpty) {
                    return _buildEmptyState("No user data found");
                  }

                  var usersData = {
                    for (var doc in usersSnapshot.data!.docs)
                      doc.id: (doc.data() as Map<String, dynamic>)
                              .containsKey('city')
                          ? (doc.data() as Map<String, dynamic>)['city']
                          : "Unknown"
                  };

                  if (selectedCity != "All") {
                    filteredUserIds = usersData.entries
                        .where((entry) => entry.value == selectedCity)
                        .map((entry) => entry.key)
                        .toList();
                  }

                  for (var doc in allResults) {
                    var data = doc.data() as Map<String, dynamic>;
                    String userId = data['user_id'] ?? '';

                    if (userId.isEmpty) continue;

                    if (selectedCity != "All" &&
                        !filteredUserIds.contains(userId)) {
                      continue;
                    }

                    if (!bestScores.containsKey(userId) ||
                        (data['score'] > bestScores[userId]['score'])) {
                      bestScores[userId] = data;
                    }
                  }

                  if (bestScores.isEmpty) {
                    return _buildEmptyState(selectedCity == "All"
                        ? "No scores recorded yet!"
                        : "No scores for $selectedCity yet!");
                  }

                  var sortedResults = bestScores.values.toList();
                  sortedResults.sort((a, b) =>
                      (b['score'] as int).compareTo(a['score'] as int));

                  return FadeTransition(
                    opacity: _animation,
                    child: Column(
                      children: [
                        if (sortedResults.length >= 3)
                          _buildTopThreeHeader(sortedResults, screenWidth),
                        for (var data in sortedResults)
                          _buildRankCard(data, sortedResults.indexOf(data) + 1,
                              isSmallScreen),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (selectedCity != "All")
            TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Show All Cities"),
              onPressed: () {
                setState(() {
                  selectedCity = "All";
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTopThreeHeader(List<dynamic> results, double screenWidth) {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Second place
          if (results.length > 1)
            _buildPodiumItem(
              results[1],
              2,
              screenWidth * 0.25,
              const Color(0xFFADB5BD),
              120.0,
            ),

          // First place
          _buildPodiumItem(
            results[0],
            1,
            screenWidth * 0.3,
            const Color(0xFFFFD700),
            150.0,
          ),
          // Third place
          if (results.length > 2)
            _buildPodiumItem(
              results[2],
              3,
              screenWidth * 0.25,
              const Color(0xFFCD7F32),
              100.0,
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(Map<String, dynamic> data, int rank, double width,
      Color color, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar and crown for first place
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: rank == 1 ? 30 : 25,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: rank == 1 ? 28 : 23,
                backgroundColor: color.withOpacity(0.2),
                child: Text(
                  (data['username'] ?? 'U')
                      .toString()
                      .substring(0, 1)
                      .toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: rank == 1 ? 24 : 20,
                  ),
                ),
              ),
            ),
            if (rank == 1)
              Positioned(
                top: -15,
                left: 0,
                right: 0,
                child: Icon(
                  Icons.emoji_events,
                  color: color,
                  size: 24,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Username
        SizedBox(
          width: width,
          child: Text(
            data['username'] ?? 'User',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: rank == 1 ? 14 : 12,
            ),
          ),
        ),

        // Score
        Text(
          "${data['score']}",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: rank == 1 ? 16 : 14,
            color: color,
          ),
        ),

        // Podium
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              "#$rank",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankCard(
      Map<String, dynamic> data, int rank, bool isSmallScreen) {
    // Rank-based styling
    Color rankColor;
    if (rank == 1) {
      rankColor = const Color(0xFFFFD700); // Gold
    } else if (rank == 2) {
      rankColor = const Color(0xFFADB5BD); // Silver
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32); // Bronze
    } else {
      rankColor = const Color(0xFF1D56CF); // Blue
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.4 + (rank * 0.05).clamp(0.0, 0.5),
          1.0,
          curve: Curves.easeOutQuart,
        ),
      )),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: 8,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: rankColor, width: 2),
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: TextStyle(
                  color: rankColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          title: Text(
            data['username'] ?? 'User',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Row(
            children: [
              Icon(
                Icons.star,
                size: 14,
                color: Colors.amber[700],
              ),
              const SizedBox(width: 4),
              Text(
                "Score: ${data['score']}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getPercentageColor(data['percentage'] ?? 0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "${(data['percentage'] ?? 0).toStringAsFixed(1)}%",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getPercentageColor(dynamic percentage) {
    double score = percentage is double
        ? percentage
        : (percentage is int ? percentage.toDouble() : 0.0);

    if (score >= 90) return Colors.green[700]!;
    if (score >= 75) return Colors.green[500]!;
    if (score >= 60) return Colors.amber[700]!;
    if (score >= 40) return Colors.orange[700]!;
    return Colors.red[700]!;
  }
}

// // import 'package:fl_chart/fl_chart.dart';
// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter_charts/flutter_charts.dart'; // Import flutter_charts

// // class LeaderboardsScreen extends StatefulWidget {
// //   const LeaderboardsScreen({super.key});

// //   @override
// //   _LeaderboardsScreenState createState() => _LeaderboardsScreenState();
// // }

// // class _LeaderboardsScreenState extends State<LeaderboardsScreen>
// //     with SingleTickerProviderStateMixin {
// //   String selectedCity = "All"; // Default to all cities
// //   List<String> cityOptions = ["All"]; // Dropdown options
// //   late AnimationController _animationController;
// //   late Animation<double> _animation;
// //   bool _isLoading = true;
// //   List<Map<String, dynamic>> top3Users = []; // List to store top 3 users

// //   @override
// //   void initState() {
// //     super.initState();
// //     _animationController = AnimationController(
// //       duration: const Duration(milliseconds: 800),
// //       vsync: this,
// //     );
// //     _animation = CurvedAnimation(
// //       parent: _animationController,
// //       curve: Curves.easeInOut,
// //     );
// //     _animationController.forward();
// //     fetchCities();
// //   }

// //   @override
// //   void dispose() {
// //     _animationController.dispose();
// //     super.dispose();
// //   }

// //   Future<void> fetchCities() async {
// //     setState(() => _isLoading = true);
// //     try {
// //       var usersSnapshot =
// //           await FirebaseFirestore.instance.collection('users').get();
// //       Set<String> cities = usersSnapshot.docs
// //           .map((doc) {
// //             Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
// //             return data != null && data.containsKey('city')
// //                 ? data['city'].toString()
// //                 : "Unknown";
// //           })
// //           .where((city) => city.isNotEmpty)
// //           .toSet();

// //       setState(() {
// //         cityOptions = [
// //           "All",
// //           ...cities.toList()..sort()
// //         ]; // Add "All" option and sort cities
// //         _isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() {
// //         _isLoading = false;
// //         cityOptions = ["All"]; // Fallback to just "All" if there's an error
// //       });
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Error loading cities: ${e.toString()}')),
// //       );
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final double screenWidth = MediaQuery.of(context).size.width;
// //     final double screenHeight = MediaQuery.of(context).size.height;
// //     final bool isSmallScreen = screenWidth < 360;

// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF5F7FA),
// //       appBar: AppBar(
// //         backgroundColor: const Color(0xFF1D56CF),
// //         elevation: 0,
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
// //           onPressed: () => Navigator.pop(context),
// //         ),
// //         title: Text(
// //           "Leaderboard",
// //           style: TextStyle(
// //             color: Colors.white,
// //             fontWeight: FontWeight.bold,
// //             fontSize: screenWidth * 0.05,
// //             letterSpacing: 0.5,
// //           ),
// //         ),
// //         centerTitle: true,
// //       ),
// //       body: ListView(
// //         physics: const BouncingScrollPhysics(),
// //         children: [
// //           // Header with trophy icon
// //           Container(
// //             padding: const EdgeInsets.symmetric(vertical: 16),
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Icon(
// //                   Icons.emoji_events,
// //                   color: Colors.amber[700],
// //                   size: 32,
// //                 ),
// //                 const SizedBox(width: 8),
// //                 Text(
// //                   "Top Performers",
// //                   style: TextStyle(
// //                     fontSize: screenWidth * 0.05,
// //                     fontWeight: FontWeight.bold,
// //                     color: const Color(0xFF1D56CF),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),

// //           // City filter dropdown
// //           AnimatedContainer(
// //             duration: const Duration(milliseconds: 300),
// //             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(15),
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: Colors.black.withOpacity(0.05),
// //                   blurRadius: 10,
// //                   offset: const Offset(0, 4),
// //                 ),
// //               ],
// //             ),
// //             child: _isLoading
// //                 ? const Padding(
// //                     padding: EdgeInsets.symmetric(vertical: 12),
// //                     child: Center(
// //                       child: SizedBox(
// //                         height: 24,
// //                         width: 24,
// //                         child: CircularProgressIndicator(
// //                           strokeWidth: 2,
// //                           valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1D56CF)),
// //                         ),
// //                       ),
// //                     ),
// //                   )
// //                 : DropdownButtonFormField<String>(
// //                     value: selectedCity,
// //                     decoration: InputDecoration(
// //                       filled: true,
// //                       fillColor: Colors.white,
// //                       contentPadding: const EdgeInsets.symmetric(
// //                           horizontal: 16, vertical: 8),
// //                       border: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(15),
// //                         borderSide: BorderSide.none,
// //                       ),
// //                       enabledBorder: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(15),
// //                         borderSide: BorderSide.none,
// //                       ),
// //                       focusedBorder: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(15),
// //                         borderSide: const BorderSide(
// //                             color: Color(0xFF1D56CF), width: 1),
// //                       ),
// //                       prefixIcon: const Icon(
// //                         Icons.location_city,
// //                         color: Color(0xFF1D56CF),
// //                       ),
// //                       hintText: "Select City",
// //                       labelText: "Filter by City",
// //                       labelStyle: const TextStyle(color: Color(0xFF1D56CF)),
// //                     ),
// //                     items: cityOptions.map((city) {
// //                       return DropdownMenuItem<String>(
// //                         value: city,
// //                         child: Text(
// //                           city,
// //                           style: const TextStyle(color: Colors.black),
// //                         ),
// //                       );
// //                     }).toList(),
// //                     onChanged: (value) {
// //                       if (value != null) {
// //                         setState(() {
// //                           selectedCity = value;
// //                         });
// //                       }
// //                     },
// //                   ),
// //           ),
// //           // Bar chart for top 3 users
// //           Container(
// //             height: 200,
// //             child: BarChart(
// //               BarChartData(
// //                 barTouchData(
// //                   touchTooltipData: BarTouchTooltipData(
// //                     tooltipBgColor: Colors.blueGrey,
// //                   ),
// //                   touchCallback: (BarTouchResponse? response) {},
// //                 ),
// //                 titlesData: FlTitlesData(
// //                   show: true,
// //                   rightTitles: SideTitles(
// //                     show: false,
// //                   ),
// //                   topTitles: SideTitles(show: false),
// //                   bottomTitles: SideTitles(
// //                     show: true,
// //                     getTitles: (double value) {
// //                       return value.toInt().toString();
// //                     },
// //                   ),
// //                   leftTitles: SideTitles(
// //                     show: true,
// //                     getTitles: (value, titleMeta) {
// //                       return titleMeta.title;
// //                     },
// //                   ),
// //                 ),
// //                 data: BarChartData(
// //                   barGroups: [
// //                     for (var data in top3Users)
// //                       BarChartGroupData(
// //                         x: data['rank'] as double,
// //                         barRods: [
// //                           BarChartRodData(
// //                             y: data['score'] as double,
// //                             colors: [Colors.red],
// //                             width: 10,
// //                           ),
// //                         ],
// //                       ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //           // Leaderboard list
// //           StreamBuilder(
// //             stream: FirebaseFirestore.instance
// //                 .collection('quiz_results')
// //                 .snapshots(),
// //             builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
// //               if (snapshot.connectionState == ConnectionState.waiting) {
// //                 return const Center(
// //                   child: CircularProgressIndicator(
// //                     valueColor:
// //                         AlwaysStoppedAnimation<Color>(Color(0xFF1D56CF)),
// //                   ),
// //                 );
// //               }

// //               if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// //                 return _buildEmptyState("No leaderboard data available");
// //               }

// //               var allResults = snapshot.data!.docs;
// //               Map<String, dynamic> bestScores = {}; // Highest score per user
// //               List<String> filteredUserIds = [];

// //               return FutureBuilder(
// //                 future: FirebaseFirestore.instance.collection('users').get(),
// //                 builder: (context, AsyncSnapshot<QuerySnapshot> usersSnapshot) {
// //                   if (usersSnapshot.connectionState ==
// //                       ConnectionState.waiting) {
// //                     return const Center(
// //                       child: CircularProgressIndicator(
// //                         valueColor:
// //                             AlwaysStoppedAnimation<Color>(Color(0xFF1D56CF)),
// //                       ),
// //                     );
// //                   }

// //                   if (!usersSnapshot.hasData ||
// //                       usersSnapshot.data!.docs.isEmpty) {
// //                     return _buildEmptyState("No user data found");
// //                   }

// //                   var usersData = {
// //                     for (var doc in usersSnapshot.data!.docs)
// //                       doc.id: (doc.data() as Map<String, dynamic>)
// //                               .containsKey('city')
// //                           ? (doc.data() as Map<String, dynamic>)['city']
// //                           : "Unknown"
// //                   };

// //                   if (selectedCity != "All") {
// //                     filteredUserIds = usersData.entries
// //                         .where((entry) => entry.value == selectedCity)
// //                         .map((entry) => entry.key)
// //                         .toList();
// //                   }

// //                   for (var doc in allResults) {
// //                     var data = doc.data() as Map<String, dynamic>;
// //                     String userId = data['user_id'] ?? '';

// //                     if (userId.isEmpty) continue;

// //                     if (selectedCity != "All" &&
// //                         !filteredUserIds.contains(userId)) {
// //                       continue;
// //                     }

// //                     if (!bestScores.containsKey(userId) ||
// //                         (data['score'] > bestScores[userId]['score'])) {
// //                       bestScores[userId] = data;
// //                     }
// //                   }

// //                   if (bestScores.isEmpty) {
// //                     return _buildEmptyState(selectedCity == "All"
// //                         ? "No scores recorded yet!"
// //                         : "No scores for $selectedCity yet!");
// //                   }

// //                   var sortedResults = bestScores.values.toList();
// //                   sortedResults.sort(((a, b) =>
// //                       (b['score'] as int).compareTo(a['score'] as int));

// //                   // Get top 3 users for the bar chart
// //                   top3Users = sortedResults
// //                       .take(3)
// //                       .map((data) => {
// //                         'rank': sortedResults.indexOf(data) + 1,
// //                         'score': data['score'] as double,
// //                         'title': data['username'] as String,
// //                        })
// //                       .toList();

// //                   return FadeTransition(
// //                     opacity: _animation,
// //                     child: Column(
// //                       children: [
// //                         if (sortedResults.length >= 3)
// //                           _buildTopThreeHeader(sortedResults, screenWidth),
// //                         for (var data in sortedResults)
// //                           _buildRankCard(data, sortedResults.indexOf(data) + 1,
// //                               isSmallScreen),
// //                       ],
// //                     ),
// //                   );
// //                 },
// //               );
// //             },
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildEmptyState(String message) {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(
// //             Icons.emoji_events_outlined,
// //             size: 64,
// //             color: Colors.grey[400],
// //           ),
// //           const SizedBox(height: 16),
// //           Text(
// //             message,
// //             style: TextStyle(
// //               fontSize: 18,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.grey[600],
// //             ),
// //             textAlign: TextAlign.center,
// //           ),
// //           const SizedBox(height: 8),
// //           if (selectedCity != "All")
// //             TextButton.icon(
// //               icon: const Icon(Icons.refresh),
// //               label: const Text("Show All Cities"),
// //               onPressed: () {
// //                 setState(() {
// //                   selectedCity = "All";
// //                 });
// //               },
// //             ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildTopThreeHeader(List<dynamic> results, double screenWidth) {
// //     return Container(
// //       height: 180,
// //       margin: const EdgeInsets.symmetric(vertical: 16),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         crossAxisAlignment: CrossAxisAlignment.end,
// //         children: [
// //           // Second place
// //           if (results.length > 1)
// //             _buildPodiumItem(
// //               results[1],
// //               2,
// //               screenWidth * 0.25,
// //               const Color(0xFFADB5BD),
// //               120.0,
// //             ),

// //           // First place
// //           _buildPodiumItem(
// //             results[0],
// //             1,
// //             screenWidth * 0.3,
// //             const Color(0xFFFFD700),
// //             150.0,
// //           ),
// //           // Third place
// //           if (results.length > 2)
// //             _buildPodiumItem(
// //               results[2],
// //               3,
// //               screenWidth * 0.25,
// //               const Color(0xFFCD7F32),
// //               100.0,
// //             ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildPodiumItem(Map<String, dynamic> data, int rank, double width,
// //       Color color, double height) {
// //     return Column(
// //       mainAxisAlignment: MainAxisAlignment.end,
// //       children: [
// //         // Avatar and crown for first place
// //         Stack(
// //           clipBehavior: Clip.none,
// //           children: [
// //             CircleAvatar(
// //               radius: rank == 1 ? 30 : 25,
// //               backgroundColor: Colors.white,
// //               child: CircleAvatar(
// //                 radius: rank == 1 ? 28 : 23,
// //                 backgroundColor: color.withOpacity(0.2),
// //                 child: Text(
// //                  (data['username'] ?? 'U')
// //                       .toString()
// //                       .substring(0, 1)
// //                       .toUpperCase(),
// //                   style: TextStyle(
// //                     color: color,
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: rank == 1 ? 24 : 20,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             if (rank == 1)
// //               Positioned(
// //                 top: -15,
// //                 left: 0,
// //                 right: 0,
// //                 child: Icon(
// //                  Icons.emoji_events,
// //                   color: color,
// //                   size: 24,
// //                 ),
// //               ),
// //           ],
// //         ),
// //         const SizedBox(height: 8),

// //         // Username
// //         SizedBox(
// //           width: width,
// //           child: Text(
// //             data['username'] ?? 'User',
// //             textAlign: TextAlign.center,
// //             overflow: TextOverflow.ellipsis,
// //             style: TextStyle(
// //               fontWeight: FontWeight.bold,
// //               fontSize: rank == 1 ? 14 : 12,
// //             ),
// //           ),
// //         ),

// //         // Score
// //         Text(
// //           "${data['score']}",
// //           style: TextStyle(
// //             fontWeight: FontWeight.w500,
// //             fontSize: rank == 1 ? 16 : 14,
// //             color: color,
// //           ),
// //         ),

// //         // Podium
// //         Container(
// //           margin: const EdgeInsets.symmetric(horizontal: 4),
// //           width: width,
// //           height: height,
// //           decoration: BoxDecoration(
// //             color: color,
// //             borderRadius: const BorderRadius.only(
// //               topLeft: Radius.circular(4),
// //               topRight: Radius.circular(4),
// //             ),
// //             boxShadow: [
// //               BoxShadow(
// //                 color: Colors.black.withOpacity(0.1),
// //                 blurRadius: 4,
// //                 offset: const Offset(0, 2),
// //               ),
// //             ],
// //           ),
// //           child: Center(
// //             child: Text(
// //               "#$rank",
// //               style: const TextStyle(
// //                 color: Colors.white,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildRankCard(
// //       Map<String, dynamic> data, int rank, bool isSmallScreen) {
// //     // Rank-based styling
// //     Color rankColor;
// //     if (rank == 1) {
// //       rankColor = const Color(0xFFFFD700); // Gold
// //     } else if (rank == 2) {
// //       rankColor = const Color(0xFFADB5BD); // Silver
// //     } else if (rank == 3) {
// //       rankColor = const Color(0xFFCD7F32); // Bronze
// //     } else {
// //       rankColor = const Color(0xFF1D56CF); // Blue
// //     }

// //     return SlideTransition(
// //       position: Tween<Offset>(
// //         begin: const Offset(1, 0),
// //         end: Offset.zero,
// //       ).animate(CurvedAnimation(
// //         parent: _animationController,
// //         curve: Interval(
// //           0.4 + (rank * 0.05).clamp(0.0, 0.5),
// //           1.0,
// //           curve: Curves.easeOutQuart,
// //         ),
// //       )),
// //       child: Container(
// //         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(15),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withOpacity(0.05),
// //               blurRadius: 10,
// //               offset: const Offset(0, 2),
// //             ),
// //           ],
// //         ),
// //         child: ListTile(
// //           contentPadding: EdgeInsets.symmetric(
// //             horizontal: isSmallScreen ? 12 : 16,
// //             vertical: 8,
// //           ),
// //           leading: Container(
// //             width: 40,
// //             height: 40,
// //             decoration: BoxDecoration(
// //               color: rankColor.withOpacity(0.2),
// //               shape: BoxShape.circle,
// //               border: Border.all(color: rankColor, width: 2),
// //             ),
// //             child: Center(
// //               child: Text(
// //                 rank.toString(),
// //                 style: TextStyle(
// //                   color: rankColor,
// //                   fontWeight: FontWeight.bold,
// //                   fontSize: 16,
// //                 ),
// //               ),
// //             ),
// //           ),
// //           title: Text(
// //             data['username'] ?? 'User',
// //             style: const TextStyle(
// //               fontSize: 16,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.black87,
// //             ),
// //             overflow: TextOverflow.ellipsis,
// //           ),
// //           subtitle: Row(
// //             children: [
// //               Icon(
// //                 Icons.star,
// //                 size: 14,
// //                 color: Colors.amber[700],
// //               ),
// //               const SizedBox(width: 4),
// //               Text(
// //                 "Score: ${data['score']}",
// //                 style: TextStyle(
// //                   fontSize: 14,
// //                   color: Colors.grey[700],
// //                 ),
// //               ),
// //             ],
// //           ),
// //           trailing: Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //             decoration: BoxDecoration(
// //               color: _getPercentageColor(data['percentage'] ?? 0),
// //               borderRadius: BorderRadius.circular(12),
// //             ),
// //             child: Text(
// //               "${(data['percentage'] ?? 0).toStringAsFixed(1)}%",
// //               style: const TextStyle(
// //                 fontWeight: FontWeight.bold,
// //                 fontSize: 14,
// //                 color: Colors.white,
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Color _getPercentageColor(dynamic percentage) {
// //     double score = percentage is double
// //         ? percentage
// //         : (percentage is int ? percentage.toDouble() : 0.0);

// //     if (score >= 90) return Colors.green[700]!;
// //     if (score >= 75) return Colors.green[500]!;
// //     if (score >= 60) return Colors.amber[700]!;
// //     if (score >= 40) return Colors.orange[700]!;
// //     return Colors.red[700]!;
// //   }
// // }
