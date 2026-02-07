import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'main_menu_screen.dart';

/// Splash Screen with animated logo and circular reveal transition
/// Features:
/// - 3-layer blurred parallax background (Sigma 5.0)
/// - Logo fade-in (1.5s) + breathing scale animation (1.0 -> 1.05)
/// - Loading Bar
/// - Circular clip reveal transition to Main Menu after 3s
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _breathingController;
  late AnimationController _revealController;
  late AnimationController _loadingBarController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<double> _revealAnimation;
  late Animation<double> _loadingBarAnimation;

  // Asset loading state
  bool _assetsLoaded = false;
  bool _transitionStarted = false;

  @override
  void initState() {
    super.initState();

    // Fade-in animation (1.5 seconds)
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Breathing/pulse animation (1.0 -> 1.05 scale, 2s duration)
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOut,
        reverseCurve: Curves.easeInOut,
      ),
    );

    // Loading Bar Animation (3 seconds to fill)
    _loadingBarController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _loadingBarAnimation = CurvedAnimation(
      parent: _loadingBarController,
      curve: Curves.linear,
    );

    // Circular reveal animation
    _revealController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _revealAnimation = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeInOut,
    );

    // Start sequence after a short delay to ensure build is complete
    Future.delayed(const Duration(milliseconds: 100), _startSplashSequence);
  }

  Future<void> _startSplashSequence() async {
    if (!mounted) return;

    // Simulate asset loading delay + show assets
    setState(() {
      _assetsLoaded = true;
    });

    // Start animations
    _fadeController.forward();
    _loadingBarController.forward();
    _breathingController.repeat(reverse: true);

    // Wait for splash duration (3 seconds total)
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      _startTransition();
    }
  }

  void _startTransition() {
    if (_transitionStarted || !mounted) return;

    setState(() {
      _transitionStarted = true;
    });

    _revealController.forward().then((_) {
      if (!mounted) return;
      // Navigate to Main Menu
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainMenuScreen(),
          transitionDuration: Duration.zero,
        ),
      );
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _breathingController.dispose();
    _revealController.dispose();
    _loadingBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Relative scaling based on screen height
    final gameHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF1a0f2e), // Dark purple fallback
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred parallax background
          if (_assetsLoaded) _buildBlurredBackground(),

          // Animated logo and loading bar
          if (_assetsLoaded)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAnimatedLogo(gameHeight),
                  SizedBox(height: gameHeight * 0.05),
                  _buildCrystalLoadingBar(gameHeight),
                ],
              ),
            ),

          // Circular reveal overlay
          if (_transitionStarted) _buildCircularReveal(),
        ],
      ),
    );
  }

  /// Build 3-layer blurred parallax background (Sigma 5.0)
  Widget _buildBlurredBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildLayer('bg_layer1.png'),
        _buildLayer('bg_layer2.png'),
        _buildLayer('bg_layer3.png'),

        // Blur overlay (Sigma 5.0)
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(color: const Color(0xFF1a0f2e).withOpacity(0.4)),
          ),
        ),
      ],
    );
  }

  Widget _buildLayer(String filename) {
    return Positioned.fill(
      child: Image.asset(
        'assets/images/environment/parallax/$filename',
        fit: BoxFit.cover,
        filterQuality: FilterQuality.none,
      ),
    );
  }

  /// Build centered logo with fade-in and breathing animation
  Widget _buildAnimatedLogo(double gameHeight) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedBuilder(
        animation: _breathingAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _breathingAnimation.value,
            child: child,
          );
        },
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.6,
            maxHeight: gameHeight * 0.4,
          ),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(0.6),
                blurRadius: 50,
                spreadRadius: 15,
              ),
            ],
          ),
          child: Image.asset('assets/images/ui/logo.png', fit: BoxFit.contain),
        ),
      ),
    );
  }

  /// Crystal Loading Bar
  Widget _buildCrystalLoadingBar(double gameHeight) {
    final barWidth = MediaQuery.of(context).size.width * 0.6;
    final barHeight = gameHeight * 0.02;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: barWidth,
        height: barHeight,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.purpleAccent.withOpacity(0.5),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 10),
          ],
        ),
        child: Stack(
          children: [
            // Fill animation
            AnimatedBuilder(
              animation: _loadingBarAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  widthFactor: _loadingBarAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFFC084FC)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      image: const DecorationImage(
                        image: AssetImage(
                          'assets/images/environment/tilesets/tileset.png',
                        ), // Subtle texture
                        fit: BoxFit.cover,
                        opacity: 0.2,
                        filterQuality: FilterQuality.none,
                      ),
                    ),
                  ),
                );
              },
            ),
            // Shine effect
            AnimatedBuilder(
              animation: _loadingBarAnimation,
              builder: (context, child) {
                return Positioned(
                  left: barWidth * _loadingBarAnimation.value - 10,
                  top: 0,
                  bottom: 0,
                  width: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.5),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build circular clip reveal (magic portal effect)
  /// Uses a solid color instead of embedding the next screen directly
  Widget _buildCircularReveal() {
    return AnimatedBuilder(
      animation: _revealAnimation,
      builder: (context, child) {
        return ClipPath(
          clipper: CircularRevealClipper(
            fraction: _revealAnimation.value,
            center: Offset(
              MediaQuery.of(context).size.width / 2,
              MediaQuery.of(context).size.height / 2,
            ),
          ),
          // Use a solid color that will expand, then navigate
          child: Container(color: const Color(0xFF1a0f2e)),
        );
      },
    );
  }
}

/// Custom clipper for circular reveal effect
class CircularRevealClipper extends CustomClipper<Path> {
  final double fraction;
  final Offset center;

  CircularRevealClipper({required this.fraction, required this.center});

  @override
  Path getClip(Size size) {
    // Calculate maximum radius (corner to corner)
    final maxRadius = math.sqrt(
      math.pow(math.max(center.dx, size.width - center.dx), 2) +
          math.pow(math.max(center.dy, size.height - center.dy), 2),
    );

    final currentRadius = maxRadius * fraction;

    return Path()
      ..addOval(Rect.fromCircle(center: center, radius: currentRadius));
  }

  @override
  bool shouldReclip(CircularRevealClipper oldClipper) {
    return fraction != oldClipper.fraction || center != oldClipper.center;
  }
}
