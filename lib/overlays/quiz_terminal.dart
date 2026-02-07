import 'package:flutter/material.dart';
import '../game/crystal_quest_game.dart';
import '../models/asl_sign.dart';

/// Magic Grimoire-style ASL Quiz Terminal
/// Displays when player attacks an enemy (ASL Clash)
class QuizTerminal extends StatefulWidget {
  final CrystalQuestGame game;

  const QuizTerminal({super.key, required this.game});

  @override
  State<QuizTerminal> createState() => _QuizTerminalState();
}

class _QuizTerminalState extends State<QuizTerminal> {
  String? selectedAnswer;
  bool answered = false;

  late List<String> choices;
  late String correctAnswer;

  @override
  void initState() {
    super.initState();

    // Get quiz data from game
    correctAnswer = widget.game.currentQuizSign?.letter ?? 'A';
    choices = AslSign.generateQuizChoices(correctAnswer);
  }

  void _handleAnswer(String answer) {
    if (answered) return;

    setState(() {
      selectedAnswer = answer;
      answered = true;
    });

    // Give brief visual feedback before closing
    Future.delayed(const Duration(milliseconds: 800), () {
      widget.game.onQuizAnswer(answer);
    });
  }

  @override
  Widget build(BuildContext context) {
    final aslAssetPath = widget.game.currentQuizSign?.assetPath ?? '';
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700;
    // Reduce sizes slightly to better fit screen
    final imageSize = isSmallScreen ? 100.0 : 150.0;
    final padding = isSmallScreen ? 12.0 : 24.0;
    final fontSize = isSmallScreen ? 16.0 : 24.0;

    return Material(
      color: Colors.black87,
      child: SafeArea(
        child: Center(
          // Use FittedBox to ensure it fits correctly without scrolling
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              // Constrain width to reasonable size
              width:
                  400, // Fixed width for consistent layout, scaled by FittedBox
              margin: const EdgeInsets.all(16),
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2a1f3d), Color(0xFF1a0f2e)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF8B5CF6), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_fix_high,
                        color: const Color(0xFFFFD700),
                        size: isSmallScreen ? 24 : 32,
                      ),
                      const SizedBox(width: 8),
                      // Removed Flexible, as FittedBox handles scaling
                      Text(
                        'ASL CLASH',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFD700),
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.auto_fix_high,
                        color: const Color(0xFFFFD700),
                        size: isSmallScreen ? 24 : 32,
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // ASL Sign Display
                  Container(
                    width: imageSize + 20,
                    height: imageSize + 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF8B5CF6).withOpacity(0.3),
                          const Color(0xFF6366F1).withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF8B5CF6),
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        aslAssetPath,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF1a0f2e),
                            child: Center(
                              child: Text(
                                correctAnswer,
                                style: TextStyle(
                                  fontSize: imageSize * 0.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF8B5CF6),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 16 : 32),

                  // Question
                  Text(
                    'What letter is this sign?',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 12 : 24),

                  // Answer Grid (2x2)
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    mainAxisSpacing: isSmallScreen ? 8 : 12,
                    crossAxisSpacing: isSmallScreen ? 8 : 12,
                    childAspectRatio: isSmallScreen ? 2.5 : 2,
                    physics: const NeverScrollableScrollPhysics(),
                    children: choices.map((choice) {
                      final isSelected = selectedAnswer == choice;
                      final isCorrect = choice == correctAnswer;

                      Color backgroundColor;
                      Color borderColor;

                      if (answered) {
                        if (isCorrect) {
                          backgroundColor = const Color(0xFF10B981);
                          borderColor = const Color(0xFF059669);
                        } else if (isSelected) {
                          backgroundColor = const Color(0xFFEF4444);
                          borderColor = const Color(0xFFDC2626);
                        } else {
                          backgroundColor = const Color(0xFF374151);
                          borderColor = const Color(0xFF4B5563);
                        }
                      } else {
                        backgroundColor = const Color(0xFF4C1D95);
                        borderColor = const Color(0xFF7C3AED);
                      }

                      return ElevatedButton(
                        onPressed: answered
                            ? null
                            : () => _handleAnswer(choice),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: backgroundColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: backgroundColor,
                          disabledForegroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: borderColor, width: 2),
                          ),
                          elevation: 8,
                          shadowColor: borderColor.withOpacity(0.5),
                        ),
                        child: Text(
                          choice,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 24 : 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  if (answered) ...[
                    SizedBox(height: isSmallScreen ? 12 : 20),
                    Text(
                      selectedAnswer == correctAnswer
                          ? '✨ Correct! +100 XP'
                          : '❌ Wrong! Try again next time',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 18,
                        fontWeight: FontWeight.bold,
                        color: selectedAnswer == correctAnswer
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
