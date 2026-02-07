import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/crystal_quest_game.dart';
import 'overlays/game_over_screen.dart';
import 'overlays/quiz_terminal.dart';
import 'overlays/game_hud.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const SignWiseCrystalQuestApp());
}

class SignWiseCrystalQuestApp extends StatelessWidget {
  const SignWiseCrystalQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign-Wise: Crystal Quest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6), // Purple theme
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final CrystalQuestGame game;
  @override
  void initState() {
    super.initState();
    game = CrystalQuestGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: game,
        overlayBuilderMap: {
          'gameOver': (context, game) =>
              GameOverScreen(game: game as CrystalQuestGame),
          'quizTerminal': (context, game) =>
              QuizTerminal(game: game as CrystalQuestGame),
          'hud': (context, game) => GameHUD(game: game as CrystalQuestGame),
          'input': (context, game) =>
              GameInputOverlay(game: game as CrystalQuestGame),
        },
      ),
    );
  }
}

/// Overlay widget that handles touch input for the game
class GameInputOverlay extends StatefulWidget {
  final CrystalQuestGame game;

  const GameInputOverlay({super.key, required this.game});

  @override
  State<GameInputOverlay> createState() => _GameInputOverlayState();
}

class _GameInputOverlayState extends State<GameInputOverlay> {
  Offset? _startPosition;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) {
        debugPrint('>>> TAP DETECTED at ${details.localPosition}');
        final screenWidth = MediaQuery.of(context).size.width;
        final tapX = details.localPosition.dx;

        if (tapX < screenWidth / 2) {
          // Left side tap - Jump
          debugPrint('>>> LEFT TAP - calling onLeftTap()');
          widget.game.onLeftTap();
        } else {
          // Right side tap - Attack
          debugPrint('>>> RIGHT TAP - calling onRightTap()');
          widget.game.onRightTap();
        }
      },
      onPanStart: (details) {
        _startPosition = details.localPosition;
      },
      onPanUpdate: (details) {
        if (_startPosition != null) {
          final delta = details.localPosition - _startPosition!;

          // Detect downward swipe
          if (delta.dy > 50 && delta.dy.abs() > delta.dx.abs()) {
            widget.game.onSwipeDown();
            _startPosition = null; // Prevent multiple triggers
          }
        }
      },
      onPanEnd: (details) {
        _startPosition = null;
      },
      child: Container(color: Colors.transparent),
    );
  }
}
