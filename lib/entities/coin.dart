import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../game/crystal_quest_game.dart';
import '../core/constants.dart';
import 'player.dart';

class Coin extends SpriteComponent
    with HasGameReference<CrystalQuestGame>, CollisionCallbacks {
  bool _collected = false;

  Coin({required super.position})
    : super(size: Vector2(24, 24), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Attempt to load from 'ui/gui.png' or 'environment/tilesets/tileset.png'
    try {
      // Try loading a coin-like tile from tileset (generic loot position)
      final image = await game.images.load('environment/tilesets/tileset.png');
      sprite = Sprite(
        image,
        srcPosition: Vector2(32, 48),
        srcSize: Vector2(16, 16),
      );
    } catch (e) {
      debugPrint("Coin asset load failed, using fallback");
      // Fallback to simple circle (handled by not valid sprite, or we can add child)
    }

    add(CircleHitbox());

    // Float Effect
    add(
      MoveEffect.by(
        Vector2(0, -10),
        EffectController(
          duration: 1,
          reverseDuration: 1,
          infinite: true,
          curve: Curves.easeInOut,
        ),
      ),
    );

    // Glow Effect
    paint.colorFilter = const ColorFilter.mode(
      Colors.amber,
      BlendMode.modulate,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_collected) return;

    // Scroll with world
    x -= GameConstants.worldSpeed * dt;

    if (x < -50) removeFromParent();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player && !_collected) {
      _collected = true;
      // Effects
      add(
        ScaleEffect.to(
          Vector2.zero(),
          EffectController(duration: 0.2),
          onComplete: () => removeFromParent(),
        ),
      );

      game.addGold(10);
    }
  }
}
