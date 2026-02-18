import 'package:flutter/material.dart';
import '../game/crystal_quest_game.dart';

/// Heads-Up Display overlay
/// Shows lives, XP, and progress bar during gameplay
class GameHUD extends StatefulWidget {
  final CrystalQuestGame game;

  const GameHUD({super.key, required this.game});

  @override
  State<GameHUD> createState() => _GameHUDState();
}

class _GameHUDState extends State<GameHUD> {
  @override
  void initState() {
    super.initState();

    // Listen to game state changes to rebuild
    widget.game.gameState.onLivesChanged = (_) {
      if (mounted) setState(() {});
    };
    widget.game.gameState.onXPChanged = (_) {
      if (mounted) setState(() {});
    };
    widget.game.gameState.onGoldChanged = (_) {
      if (mounted) setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    final lives = widget.game.gameState.lives;
    final xp = widget.game.gameState.xp;
    final gold = widget.game.gameState.gold;
    final maxLives = 3;
    final xpForNextLevel = 500;
    final progress = (xp % xpForNextLevel) / xpForNextLevel;

    return Positioned.fill(
      child: IgnorePointer(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            40,
            20,
            20,
          ), // Top padding for notch
          child: Column(
            children: [
              // Top Bar: Lives -- Gold -- XP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- LIVES (Hearts) ---
                  _buildHudContainer(
                    borderColor: const Color(0xFFEF4444), // Red
                    gradientColors: [
                      Colors.black.withOpacity(0.8),
                      const Color(0xFF450a0a).withOpacity(0.8),
                    ],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < maxLives; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Icon(
                              i < lives
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: i < lives
                                  ? const Color(0xFFEF4444)
                                  : Colors.white.withOpacity(0.3),
                              size: 30,
                              shadows: i < lives
                                  ? [
                                      const Shadow(
                                        blurRadius: 8,
                                        color: Color(0xFFEF4444),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // --- GOLD COUNTER ---
                  _buildHudContainer(
                    borderColor: const Color(0xFFFFD700), // Gold
                    gradientColors: [
                      Colors.black.withOpacity(0.8),
                      const Color(0xFF422006).withOpacity(0.8),
                    ],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Color(0xFFFFD700),
                          size: 20,
                          shadows: [
                            Shadow(blurRadius: 8, color: Color(0xFFFFD700)),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$gold',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace', // Monospaced for numbers
                            shadows: [
                              Shadow(blurRadius: 2, color: Colors.black),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- XP COUNTER ---
                  _buildHudContainer(
                    borderColor: const Color(0xFF3B82F6), // Blue
                    gradientColors: [
                      Colors.black.withOpacity(0.8),
                      const Color(0xFF1e3a8a).withOpacity(0.8),
                    ],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.stars,
                          color: Color(0xFF60A5FA),
                          size: 30,
                          shadows: [
                            Shadow(blurRadius: 8, color: Color(0xFF3B82F6)),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$xp XP',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(blurRadius: 2, color: Colors.black),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // --- LEVEL PROGRESS BAR ---
              Container(
                height: 25, // Thinner bar
                margin: const EdgeInsets.symmetric(horizontal: 100),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Stack(
                    children: [
                      // Progress fill
                      FractionallySizedBox(
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                            ),
                          ),
                        ),
                      ),
                      // Level text overlay
                      Center(
                        child: Text(
                          'Level ${(xp ~/ xpForNextLevel) + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(blurRadius: 2, color: Colors.black),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHudContainer({
    required Widget child,
    required Color borderColor,
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  void dispose() {
    // Clean up callbacks
    widget.game.gameState.onLivesChanged = null;
    widget.game.gameState.onXPChanged = null;
    widget.game.gameState.onGoldChanged = null;
    super.dispose();
  }
}
