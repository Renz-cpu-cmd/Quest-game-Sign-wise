import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import '../game/crystal_quest_game.dart';
import 'player.dart';

enum BatEnemyState { fly, hit }

class BatEnemy extends SpriteAnimationGroupComponent<BatEnemyState>
    with HasGameRef<CrystalQuestGame>, CollisionCallbacks {
  final double speed;
  bool _isHit = false;

  BatEnemy({required Vector2 position, this.speed = 200.0})
    : super(position: position, size: Vector2(64, 32), anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load bat sprite (2 frames, 32x32 each)
    final image = await game.images.load('enemies/bat_fly.png');
    final frameWidth = 32.0;
    final frameHeight = 32.0;

    // Fly animation
    final flyAnimation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.1,
        textureSize: Vector2(frameWidth, frameHeight),
      ),
    );

    // Hit animation (same but faster or tinted - for now reuse)
    final hitAnimation = flyAnimation;

    animations = {
      BatEnemyState.fly: flyAnimation,
      BatEnemyState.hit: hitAnimation,
    };
    current = BatEnemyState.fly;

    // Hitbox (Top half only - so you can duck under it)
    add(
      RectangleHitbox(
        size: Vector2(size.x * 0.6, size.y * 0.6),
        position: Vector2(size.x / 2, size.y * 0.4),
        anchor: Anchor.center,
      ),
    );
  }

  /// Called when player attacks this enemy
  void onHitByPlayer() {
    debugPrint('BatEnemy hit by player!');
    if (_isHit) return;
    gameRef.triggerClash(this);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isHit) {
      removeFromParent(); // Instant remove for now
      return;
    }

    // Move left
    x -= speed * dt;

    // Remove if off-screen left
    if (x < -size.x) {
      removeFromParent();
    }
  }

  void takeHit() {
    if (_isHit) return;
    _isHit = true;
    current = BatEnemyState.hit;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      // If player is ducking, they might avoid it based on hitbox
      // But if collision happens, it happens.
      if (!_isHit) {
        gameRef.onPlayerHit();
      }
    }
  }
}
