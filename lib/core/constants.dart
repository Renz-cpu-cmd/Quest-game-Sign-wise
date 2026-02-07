/// Game constants for Sign-Wise: Crystal Quest
library;

class GameConstants {
  // Player configuration (screen-relative sizing)
  // Player height is 25% of screen height for balanced gameplay
  static const double playerHeightRatio = 0.25;
  static const double playerAspectRatio =
      68.0 / 52.0; // Original sprite dimensions

  // Enemy configuration (screen-relative)
  // Enemy same size as player (25% of screen height)
  static const double enemyHeightRatio = 0.25;
  // Flying enemy (ninja) sprite dimensions from enemy04_sheet.png
  static const double enemySpriteWidth = 52.0; // Each frame width
  static const double enemySpriteHeight = 50.0; // Each frame height

  // Physics
  static const double gravity = 900.0;
  static const double jumpForce = -500.0;
  static const double maxFallSpeed = 800.0;

  // World movement
  static const double worldSpeed = 200.0;

  // Floor positioning (90% down the screen)
  static const double floorHeightRatio = 0.9;

  // Player positioning (30% from left edge)
  static const double playerXRatio = 0.3;

  // Parallax layer velocities (relative to world speed)
  static const double parallaxLayer1Speed = 0.3; // Slowest (background)
  static const double parallaxLayer2Speed = 0.5; // Mid
  static const double parallaxLayer3Speed = 0.7; // Fastest (foreground)

  // Animation frame rates (frames per second)
  static const double runAnimationSpeed = 0.1;
  static const double jumpAnimationSpeed = 0.1;
  static const double duckAnimationSpeed = 0.1;
  static const double attackAnimationSpeed = 0.08;
}
