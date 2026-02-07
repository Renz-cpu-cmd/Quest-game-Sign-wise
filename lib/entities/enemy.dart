import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../game/crystal_quest_game.dart';

/// Enemy spawn height options
enum EnemyHeight {
  low, // Near floor level - duck to avoid
  high, // Mid screen - jump to attack
}

/// Enemy state
enum EnemyState { flying, hit, destroyed }

/// RunnerEnemy component - fast running enemy that triggers ASL quizzes
/// Uses ninja sprite from enemy04_sheet.png
class RunnerEnemy extends SpriteAnimationComponent
    with HasGameReference<CrystalQuestGame>, CollisionCallbacks {
  RunnerEnemy({required Vector2 position})
    : super(position: position, anchor: Anchor.bottomLeft);

  EnemyState state =
      EnemyState.flying; // Keep enum for now, represents 'active'
  static const double speed = 250.0; // Faster than ground enemy

  late double enemyHeight;
  late double enemyWidth;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Calculate responsive size
    enemyHeight = game.size.y * GameConstants.enemyHeightRatio;
    enemyWidth =
        enemyHeight *
        (GameConstants.enemySpriteWidth / GameConstants.enemySpriteHeight);
    size = Vector2(enemyWidth, enemyHeight);

    // Load animation
    try {
      animation = await _loadRunAnimation();
    } catch (e) {
      debugPrint('Warning: Could not load runner animation: $e');
    }

    // Hitbox (Wider and taller to catch sword hits)
    add(
      RectangleHitbox(
        size: Vector2(size.x * 0.8, size.y * 0.6),
        position: Vector2(size.x / 2, size.y),
        anchor: Anchor.bottomCenter,
      ),
    );

    // Flip to face LEFT (toward player)
    flipHorizontally();

    debugPrint('RunnerEnemy spawned at $position, size: $size');
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (state == EnemyState.flying) {
      position.x -= speed * dt;

      if (position.x < -size.x) {
        removeFromParent();
      }
    }
  }

  Future<SpriteAnimation> _loadRunAnimation() async {
    try {
      final spriteSheetImage = await game.images.load(
        'enemies/enemy04_sheet.png',
      );

      const int frameCount = 28; // 1792 / 64 = 28 frames
      final frameWidth = (spriteSheetImage.width ~/ frameCount).toDouble();
      final frameHeight = spriteSheetImage.height.toDouble();

      debugPrint(
        'RunnerEnemy sprite: ${spriteSheetImage.width}x${spriteSheetImage.height}',
      );
      debugPrint('  Frame: ${frameWidth}x$frameHeight');

      final sprites = <Sprite>[];
      for (int i = 0; i < frameCount; i++) {
        sprites.add(
          Sprite(
            spriteSheetImage,
            srcPosition: Vector2(i * frameWidth, 0),
            srcSize: Vector2(frameWidth, frameHeight),
          ),
        );
      }

      return SpriteAnimation.spriteList(sprites, stepTime: 0.02, loop: true);
    } catch (e) {
      debugPrint('Failed to load enemy sprite sheet: $e');
      final fallbackImage = await game.images.load('ui/logo.png');
      return SpriteAnimation.spriteList(
        [Sprite(fallbackImage)],
        stepTime: 0.15,
        loop: true,
      );
    }
  }

  void onHitByPlayer() {
    if (state == EnemyState.flying) {
      state = EnemyState.hit;
      game.triggerClash(this);
    }
  }

  void destroy() {
    debugPrint('RunnerEnemy.destroy() called');
    state = EnemyState.destroyed;
    removeFromParent();
  }
}
