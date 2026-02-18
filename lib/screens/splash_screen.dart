import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/audio_manager.dart';
import 'main_menu_screen.dart';

/// Splash Screen with animated logo and circular reveal transition
/// Features:
/// - 3-layer blurred parallax background (Sigma 5.0)
/// - Floating magic particles (purple & amber)
/// - Staggered animation: bg (0-0.5s) → logo slide-up (0.5-1.5s) → loading bar (1.5s+)
/// - Logo breathing scale animation (1.0 -> 1.05)
/// - Rotating glow ring behind logo
/// - Flavor text above loading bar
/// - Loading Bar with shine effect
/// - Pulsing "Tap to Begin" after loading completes
/// - Version number at bottom
/// - Circular clip reveal transition to Main Menu
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _bgFadeController;
  late AnimationController _logoFadeController;
  late AnimationController _logoSlideController;
  late AnimationController _breathingController;
  late AnimationController _loadingBarController;
  late AnimationController _loadingFadeController;
  late AnimationController _revealController;
  late AnimationController _particleController;
  late AnimationController _glowRotationController;
  late AnimationController _tapPulseController;

  // Animations
  late Animation<double> _bgFadeAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<double> _loadingBarAnimation;
  late Animation<double> _loadingFadeAnimation;
  late Animation<double> _revealAnimation;
  late Animation<double> _glowRotationAnimation;
  late Animation<double> _tapPulseAnimation;

  // Particle state
  final List<_MagicParticle> _particles = [];
  final math.Random _random = math.Random();

  // Asset loading state
  bool _assetsLoaded = false;
  bool _transitionStarted = false;
  bool _loadingComplete = false;

  @override
  void initState() {
    super.initState();

    // --- Staggered Animation Controllers ---

    // 1) Background fade-in (0 → 0.5s)
    _bgFadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _bgFadeAnimation = CurvedAnimation(
      parent: _bgFadeController,
      curve: Curves.easeIn,
    );

    // 2) Logo fade-in + slide-up (0.5s → 1.5s)
    _logoFadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _logoFadeAnimation = CurvedAnimation(
      parent: _logoFadeController,
      curve: Curves.easeInOut,
    );

    _logoSlideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _logoSlideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0.15), // Start slightly below
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _logoSlideController,
            curve: Curves.easeOutCubic,
          ),
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

    // 3) Loading Bar + flavor text fade-in (appears at 1.5s)
    _loadingFadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadingFadeAnimation = CurvedAnimation(
      parent: _loadingFadeController,
      curve: Curves.easeIn,
    );

    // Loading Bar fill animation (1.5s duration after it appears)
    _loadingBarController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _loadingBarAnimation = CurvedAnimation(
      parent: _loadingBarController,
      curve: Curves.easeInOut,
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

    // Particle animation controller (runs continuously)
    _particleController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..addListener(_updateParticles);

    // Rotating glow ring behind logo (slow 8s rotation)
    _glowRotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _glowRotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_glowRotationController);

    // Pulsing "Tap to Begin" animation
    _tapPulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _tapPulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _tapPulseController, curve: Curves.easeInOut),
    );

    // Start sequence after a short delay to ensure build is complete
    Future.delayed(const Duration(milliseconds: 100), _startSplashSequence);
  }

  // --- Particle System ---

  void _spawnParticles(Size screenSize) {
    // Spawn 1-2 particles per frame, max 40
    if (_particles.length < 40 && _random.nextDouble() < 0.3) {
      _particles.add(
        _MagicParticle(
          x: _random.nextDouble() * screenSize.width,
          y: screenSize.height + 10,
          speed: _random.nextDouble() * 1.5 + 0.5,
          size: _random.nextDouble() * 4 + 2,
          opacity: _random.nextDouble() * 0.6 + 0.2,
          color: _random.nextBool()
              ? const Color(0xFF8B5CF6) // Purple
              : const Color(0xFFFFB800), // Amber
          wobbleOffset: _random.nextDouble() * math.pi * 2,
          wobbleSpeed: _random.nextDouble() * 0.02 + 0.01,
        ),
      );
    }
  }

  void _updateParticles() {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;

    _spawnParticles(size);

    setState(() {
      for (final p in _particles) {
        p.y -= p.speed;
        p.x += math.sin(p.wobbleOffset) * 0.5; // Gentle horizontal wobble
        p.wobbleOffset += p.wobbleSpeed;
        // Fade out as they rise
        p.currentOpacity = p.opacity * (p.y / size.height).clamp(0.0, 1.0);
      }
      // Remove particles that have gone off-screen
      _particles.removeWhere((p) => p.y < -20);
    });
  }

  // --- Animation Sequence ---

  Future<void> _startSplashSequence() async {
    if (!mounted) return;

    setState(() {
      _assetsLoaded = true;
    });

    // Start particles immediately
    _particleController.repeat();

    // Step 1: Background fades in (0 → 0.5s)
    _bgFadeController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // Step 2: Logo fades in + slides up (0.5s → 1.5s)
    _logoFadeController.forward();
    _logoSlideController.forward();
    _breathingController.repeat(reverse: true);

    // Play crystal chime when logo appears
    AudioManager.instance.playSplashChime();
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    // Step 3: Loading bar + flavor text appear (1.5s+)
    _loadingFadeController.forward();
    _loadingBarController.forward();

    // Start glow rotation
    _glowRotationController.repeat();

    // Wait for loading bar to complete (~2.5s), then show "Tap to Begin"
    await Future.delayed(const Duration(milliseconds: 2700));

    if (mounted) {
      setState(() {
        _loadingComplete = true;
      });
      _tapPulseController.repeat(reverse: true);
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
    _bgFadeController.dispose();
    _logoFadeController.dispose();
    _logoSlideController.dispose();
    _breathingController.dispose();
    _loadingBarController.dispose();
    _loadingFadeController.dispose();
    _revealController.dispose();
    _particleController.dispose();
    _glowRotationController.dispose();
    _tapPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Relative scaling based on screen height
    final gameHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF1a0f2e), // Dark purple fallback
      body: GestureDetector(
        onTap: () {
          if (_loadingComplete && !_transitionStarted) {
            _startTransition();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Blurred parallax background (staggered fade-in)
            if (_assetsLoaded)
              FadeTransition(
                opacity: _bgFadeAnimation,
                child: _buildBlurredBackground(),
              ),

            // Floating magic particles (behind logo)
            if (_assetsLoaded) _buildParticles(),

            // Animated logo and loading bar
            if (_assetsLoaded)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAnimatedLogo(gameHeight),
                    SizedBox(height: gameHeight * 0.05),
                    _buildFlavorText(),
                    const SizedBox(height: 8),
                    if (!_loadingComplete)
                      _buildCrystalLoadingBar(gameHeight)
                    else
                      _buildTapToBegin(),
                  ],
                ),
              ),

            // Version number at bottom
            if (_assetsLoaded)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _bgFadeAnimation,
                  child: const Text(
                    'v1.0.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),

            // Circular reveal overlay
            if (_transitionStarted) _buildCircularReveal(),
          ],
        ),
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

  /// Build floating magic particles
  Widget _buildParticles() {
    return CustomPaint(
      size: Size.infinite,
      painter: _ParticlePainter(particles: _particles),
    );
  }

  /// Build centered logo with fade-in, slide-up, breathing animation, and rotating glow ring
  Widget _buildAnimatedLogo(double gameHeight) {
    final logoSize = MediaQuery.of(context).size.width * 0.6;

    return FadeTransition(
      opacity: _logoFadeAnimation,
      child: SlideTransition(
        position: _logoSlideAnimation,
        child: AnimatedBuilder(
          animation: _breathingAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _breathingAnimation.value,
              child: child,
            );
          },
          child: SizedBox(
            width: logoSize,
            height: gameHeight * 0.4,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rotating glow ring behind logo
                AnimatedBuilder(
                  animation: _glowRotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _glowRotationAnimation.value,
                      child: Container(
                        width: logoSize * 0.85,
                        height: logoSize * 0.85,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              const Color(0xFF8B5CF6).withOpacity(0.0),
                              const Color(0xFF8B5CF6).withOpacity(0.6),
                              const Color(0xFFC084FC).withOpacity(0.3),
                              const Color(0xFFFFB800).withOpacity(0.4),
                              const Color(0xFF8B5CF6).withOpacity(0.0),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6).withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Logo image on top
                Container(
                  constraints: BoxConstraints(
                    maxWidth: logoSize,
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
                  child: Image.asset(
                    'assets/images/ui/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build flavor text above loading bar
  Widget _buildFlavorText() {
    return FadeTransition(
      opacity: _loadingFadeAnimation,
      child: const Text(
        'Awakening the Crystals...',
        style: TextStyle(
          color: Color(0xFFC084FC),
          fontSize: 18,
          fontStyle: FontStyle.italic,
          letterSpacing: 1.2,
          shadows: [Shadow(color: Color(0xFF8B5CF6), blurRadius: 8)],
        ),
      ),
    );
  }

  /// Build pulsing "Tap to Begin" text
  Widget _buildTapToBegin() {
    return AnimatedBuilder(
      animation: _tapPulseAnimation,
      builder: (context, child) {
        return Opacity(opacity: _tapPulseAnimation.value, child: child);
      },
      child: const Text(
        '— Tap to Begin —',
        style: TextStyle(
          color: Color(0xFFC084FC),
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: 2.0,
          shadows: [Shadow(color: Color(0xFF8B5CF6), blurRadius: 12)],
        ),
      ),
    );
  }

  /// Crystal Loading Bar
  Widget _buildCrystalLoadingBar(double gameHeight) {
    final barWidth = MediaQuery.of(context).size.width * 0.6;
    final barHeight = gameHeight * 0.02;

    return FadeTransition(
      opacity: _loadingFadeAnimation,
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
            // Crystal icon riding the loading bar edge
            AnimatedBuilder(
              animation: _loadingBarAnimation,
              builder: (context, child) {
                return Positioned(
                  left: barWidth * _loadingBarAnimation.value - 10,
                  top: -8,
                  child: Icon(
                    Icons.diamond,
                    color: Color.lerp(
                      const Color(0xFFC084FC),
                      const Color(0xFFFFB800),
                      _loadingBarAnimation.value,
                    ),
                    size: barHeight + 16,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.8),
                        blurRadius: 8,
                      ),
                    ],
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

/// Data class for a floating magic particle
class _MagicParticle {
  double x;
  double y;
  double speed;
  double size;
  double opacity;
  double currentOpacity;
  Color color;
  double wobbleOffset;
  double wobbleSpeed;

  _MagicParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.color,
    required this.wobbleOffset,
    required this.wobbleSpeed,
  }) : currentOpacity = opacity;
}

/// Custom painter to render magic particles
class _ParticlePainter extends CustomPainter {
  final List<_MagicParticle> particles;

  _ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // Core particle
      final paint = Paint()
        ..color = p.color.withOpacity(p.currentOpacity.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);

      // Soft glow around particle
      final glowPaint = Paint()
        ..color = p.color.withOpacity((p.currentOpacity * 0.3).clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(p.x, p.y), p.size * 2.5, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
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
