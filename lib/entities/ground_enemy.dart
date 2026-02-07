import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import '../game/crystal_quest_game.dart';
import 'player.dart';

enum GroundEnemyState { walk, attack, hit }

/// GroundEnemy - A ground-based enemy that walks toward player and attacks when close
/// Uses individual sprite frames for walk, attack, and hit animations
class GroundEnemy extends SpriteAnimationGroupComponent<GroundEnemyState>
    with HasGameRef<CrystalQuestGame>, CollisionCallbacks {
  final double speed;
  bool _isHit = false;

  // Distance threshold for switching to attack animation
  static const double _attackDistance = 120.0;

  GroundEnemy({required Vector2 position, this.speed = 100})
    : super(
        position: position,
        size: Vector2.zero(),
        anchor: Anchor.bottomLeft,
      );

  @override
  Future<void> onLoad() async {
    // Calculate responsive size based on screen height (same as player)
    final enemyHeight = gameRef.size.y * GameConstants.enemyHeightRatio;
    final enemyWidth = enemyHeight; // 1:1 aspect ratio
    size = Vector2(enemyWidth, enemyHeight);

    debugPrint('GroundEnemy size: ${size.x}x${size.y}, pos: $position');

    // Load Walk Animation (6 frames)
    final walkSprites = <Sprite>[];
    for (int i = 1; i <= 6; i++) {
      final sprite = await gameRef.loadSprite('enemies/walk0$i.png');
      walkSprites.add(sprite);
    }
    final walkAnim = SpriteAnimation.spriteList(walkSprites, stepTime: 0.12);

    // Load Attack Animation (7 frames)
    final attackSprites = <Sprite>[];
    for (int i = 1; i <= 7; i++) {
      final sprite = await gameRef.loadSprite('enemies/attack0$i.png');
      attackSprites.add(sprite);
    }
    final attackAnim = SpriteAnimation.spriteList(attackSprites, stepTime: 0.1);

    // Load Hit Animation (3 frames)
    final hitSprites = <Sprite>[];
    for (int i = 1; i <= 3; i++) {
      final sprite = await gameRef.loadSprite('enemies/hit0$i.png');
      hitSprites.add(sprite);
    }
    final hitAnim = SpriteAnimation.spriteList(
      hitSprites,
      stepTime: 0.08,
      loop: false,
    );

    animations = {
      GroundEnemyState.walk: walkAnim,
      GroundEnemyState.attack: attackAnim,
      GroundEnemyState.hit: hitAnim,
    };
    current = GroundEnemyState.walk;

    // Hitbox (Increased to 55% width, 50% height for balance)
    add(
      RectangleHitbox(
        size: Vector2(size.x * 0.55, size.y * 0.5),
        position: Vector2(size.x / 2, size.y),
        anchor: Anchor.bottomCenter,
      ),
    );

    // Flip sprite to face LEFT (toward player)
    flipHorizontally();
  }

  /// Called when player attacks this enemy
  void onHitByPlayer() {
    debugPrint('GroundEnemy hit by player!');
    if (_isHit) return;
    gameRef.triggerClash(this);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isHit) {
      if (animationTicker?.done() == true) {
        removeFromParent();
      }
      return;
    }

    // Calculate distance to player
    final distanceToPlayer = x - gameRef.player.x;

    // Switch between walk and attack based on distance
    if (distanceToPlayer < _attackDistance && distanceToPlayer > 0) {
      if (current != GroundEnemyState.attack) {
        current = GroundEnemyState.attack;
      }
      // No slowdown - keep full speed to avoid "tracking" feel
      x -= speed * dt;
    } else {
      if (current != GroundEnemyState.walk) {
        current = GroundEnemyState.walk;
      }
      x -= speed * dt;
    }

    // Remove if off-screen left
    if (x < -size.x) {
      removeFromParent();
    }
  }

  void takeHit() {
    if (_isHit) return;
    _isHit = true;
    current = GroundEnemyState.hit;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      debugPrint('GroundEnemy collided with Player. isHit: $_isHit');
      if (!_isHit) {
        gameRef.onPlayerHit();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    // Clip to prevent sprite overflow
    canvas.clipRect(Rect.fromLTWH(0, 0, size.x, size.y));
    super.render(canvas);
    canvas.restore();
  }
}
