import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui'; // For BackdropFilter

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<int> _highScores = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHighScores();
  }

  Future<void> _loadHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScores = (prefs.getStringList('high_scores') ?? [])
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
      _highScores.sort((a, b) => b.compareTo(a)); // Descending order
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background - Dark Forest Theme
          Image.asset(
            'assets/images/environment/parallax/bg_layer1.png',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.6)), // Darken
          // Glassmorphism Content
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      const Text(
                        'HALL OF HEROES',
                        style: TextStyle(
                          fontFamily: 'Pixel',
                          fontSize: 28,
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(color: Colors.orangeAccent, blurRadius: 10),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.amber,
                                ),
                              )
                            : _highScores.isEmpty
                            ? _buildEmptyState()
                            : _buildScoreList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, color: Colors.white30, size: 64),
          const SizedBox(height: 16),
          Text(
            "The Hall of Heroes awaits\nits first legend!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: _highScores.length,
      itemBuilder: (context, index) {
        final score = _highScores[index];
        final rank = index + 1;
        Color rankColor = Colors.white;
        if (rank == 1) rankColor = const Color(0xFFFFD700); // Gold
        if (rank == 2) rankColor = const Color(0xFFC0C0C0); // Silver
        if (rank == 3) rankColor = const Color(0xFFCD7F32); // Bronze

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Text(
                '#$rank',
                style: TextStyle(
                  fontFamily: 'Pixel',
                  fontSize: 20,
                  color: rankColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '$score XP',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
