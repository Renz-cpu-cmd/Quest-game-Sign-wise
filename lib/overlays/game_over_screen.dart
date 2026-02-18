import 'package:flutter/material.dart';
import '../game/crystal_quest_game.dart';
import '../screens/main_menu_screen.dart';

/// Game Over screen overlay
/// Uses SingleChildScrollView to prevent overflow errors
class GameOverScreen extends StatelessWidget {
  final CrystalQuestGame game;

  const GameOverScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 190),
            decoration: BoxDecoration(
              color: const Color(0xFF2a1f3d),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Game Over',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B5CF6),
                    fontFamily: 'Pixel',
                  ),
                ),
                const SizedBox(height: 16),

                // Score & Gold
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Score',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          '${game.gameState.score}',
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontFamily: 'Pixel',
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          'Gold',
                          style: TextStyle(color: Colors.amberAccent),
                        ),
                        Text(
                          '+${game.gameState.gold}',
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.amber,
                            fontFamily: 'Pixel',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    debugPrint('>>> Try Again button pressed');
                    try {
                      game.restart();
                    } catch (e) {
                      debugPrint('>>> Error restarting game: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    debugPrint('>>> Return to Menu pressed');
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const MainMenuScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Return to Menu',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
