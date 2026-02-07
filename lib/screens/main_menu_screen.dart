import 'package:flutter/material.dart';

import '../main.dart'; // For GameScreen
import '../widgets/hero_selection_carousel.dart';
import 'leaderboard_screen.dart';
import 'settings_screen.dart';

/// Main Menu Screen
/// Displays the game title and the Hero Selection Carousel
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Responsive sizing
    final size = MediaQuery.of(context).size;
    final titleSize = size.height * 0.1;

    return Scaffold(
      body: Builder(
        builder: (context) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // --- Background Layers ---
              Image.asset(
                'assets/images/environment/parallax/bg_layer1.png',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.none,
              ),
              Image.asset(
                'assets/images/environment/parallax/bg_layer2.png',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.none,
              ),
              Image.asset(
                'assets/images/environment/parallax/bg_layer3.png',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.none,
              ),

              // --- Dark Overlay ---
              Container(color: Colors.black54),

              // --- Center Content ---
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        'Sign-Wise',
                        style: TextStyle(
                          fontSize: titleSize,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(
                              color: Colors.purpleAccent,
                              blurRadius: 20,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Crystal Quest',
                        style: TextStyle(
                          fontSize: titleSize * 0.6,
                          color: const Color(0xFFC084FC),
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: size.height * 0.05),

                      // Carousel
                      HeroSelectionCarousel(
                        onHeroSelected: (hero) {
                          debugPrint('Selected: ${hero.name}');
                        },
                        onPlay: () {
                          debugPrint(
                            'MainMenu: onPlay called! Navigating to GameScreen...',
                          );
                          // Schedule navigation for the next frame to avoid build conflicts
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (context.mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const GameScreen(),
                                ),
                              );
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // --- Corner Icons (positioned last to be on top) ---

              // Leaderboard (Top Left)
              Positioned(
                top: 40,
                left: 20,
                child: SafeArea(
                  child: _buildIconMenuButton(
                    context,
                    icon: Icons.emoji_events,
                    label: 'Heroes',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LeaderboardScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Settings (Top Right)
              Positioned(
                top: 40,
                right: 20,
                child: SafeArea(
                  child: _buildIconMenuButton(
                    context,
                    icon: Icons.settings,
                    label: 'Settings',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIconMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFC084FC), width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.purpleAccent, blurRadius: 10),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 32),
            onPressed: onPressed,
            tooltip: label,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }
}
