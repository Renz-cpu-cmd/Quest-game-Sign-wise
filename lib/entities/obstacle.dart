import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../game/crystal_quest_game.dart';
import '../core/constants.dart';
import '../entities/player.dart';

enum ObstacleType { spike, crystal }

class Obstacle extends SpriteComponent
    with HasGameReference<CrystalQuestGame>, CollisionCallbacks {
  final ObstacleType type;

  Obstacle({required Vector2 position, this.type = ObstacleType.spike})
    : super(position: position, anchor: Anchor.bottomCenter);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Responsive size - 10% of screen height for visibility
    final obstacleSize = game.size.y * 0.10;
    size = Vector2(obstacleSize, obstacleSize);

    // Load tileset and extract ice spike
    final image = await game.images.load('environment/tilesets/tileset.png');

    // Ice spike is near bottom of tileset (around row 27-28)
    // Position: ~(288, 432) based on visual inspection
    sprite = Sprite(
      image,
      srcSize: Vector2(32, 48), // Ice spike dimensions
      srcPosition: Vector2(288, 432), // Ice spike position in tileset
    );

    // Triangle hitbox for spike shape
    final hitbox = PolygonHitbox([
      Vector2(0, size.y),
      Vector2(size.x / 2, 0),
      Vector2(size.x, size.y),
    ]);
    add(hitbox);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Move with world speed
    position.x -= GameConstants.worldSpeed * dt;

    if (position.x < -100) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    // Player collision is handled by Player or Game loop usually,
    // but we can trigger it here too.
    if (other is Player) {
      // game.onPlayerHit(); // Need to implement this in game
    }
  }
}
