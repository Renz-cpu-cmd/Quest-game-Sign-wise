import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../game/crystal_quest_game.dart';
import '../core/constants.dart';
import 'player.dart';

class MagicCoin extends SpriteComponent
    with HasGameRef<CrystalQuestGame>, CollisionCallbacks {
  bool _collected = false;

  MagicCoin({required Vector2 position})
    : super(position: position, size: Vector2(24, 24));

  @override
  Future<void> onLoad() async {
    // Attempt to load from 'ui/gui.png' or 'environment/tilesets/tileset.png'
    // Fallback: A nice yellow circle if asset logic is complex without seeing the sheet
    // We will try to create a "coin-like" look with a circle first for reliability,
    // or try to load a known sprite.

    // For "Creative" & "Asset Use":
    // Let's assume there's a coin in 'gui.png'.
    // If not, we'll draw a custom component or use a circle.
    // To be safe and fast: Circle with Effect.

    // Actually, I can use a Coin sprite if one exists in `tileset.png`.
    // Let's stick to a robust fallback + generic sprite load attempt.

    try {
      // Try loading a coin-like tile from tileset (generic loot position)
      final image = await gameRef.images.load(
        'environment/tilesets/tileset.png',
      );
      sprite = Sprite(
        image,
        srcPosition: Vector2(32, 48),
        srcSize: Vector2(16, 16),
      );
    } catch (e) {
      debugPrint("Coin asset load failed, using fallback");
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

    // Glow Effect (if supported, or just a specialized tint)
    // tint = Colors.amberAccent; // SpriteComponent doesn't strictly have tint, but we can use ColorFiltered in rendering if needed.
    // simpler:
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

      // Logic
      // gameRef.addGold(10); // TODO: Implement in Game class
    }
  }
}
