import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import '../game/crystal_quest_game.dart';
import '../core/constants.dart';

/// FloorTerrain - Scrolling crystal ground floor
/// Uses large crystal blocks from the tileset for a visible platform
class FloorTerrain extends PositionComponent with HasGameRef<CrystalQuestGame> {
  static const double _floorHeight = 80.0; // Visible floor height
  static const double _tileWidth = 64.0; // Width of each tile
  static const double _tileHeight = 64.0; // Height of each tile

  late Sprite _crystalBlockSprite;
  double _scrollOffset = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load tileset image
    final tilesetImage = await gameRef.images.load(
      'environment/tilesets/tileset.png',
    );

    // Use the large crystal blocks from the tileset
    // These appear in the left side as vertical columns (around x=0-64, y=128-256)
    // Using the solid rectangular crystal segments
    _crystalBlockSprite = Sprite(
      tilesetImage,
      srcPosition: Vector2(0, 128), // Large crystal block section
      srcSize: Vector2(64, 64),
    );

    // Position at floor level
    position = Vector2(0, gameRef.floorY);
    size = Vector2(gameRef.size.x, _floorHeight);

    // Set priority so it renders behind characters but above background
    priority = 1;

    debugPrint(
      'FloorTerrain: y=${position.y}, screenH=${gameRef.size.y}, floorY=${gameRef.floorY}',
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Scroll at 30% of world speed
    _scrollOffset += (GameConstants.worldSpeed * 0.3) * dt;
    if (_scrollOffset >= _tileWidth) {
      _scrollOffset -= _tileWidth;
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw dark gradient base
    final baseGradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0xFF1a1a3e), // Dark purple-blue at top
          Color(0xFF0d0d1a), // Almost black at bottom
        ],
      ).createShader(Rect.fromLTWH(0, 0, gameRef.size.x, _floorHeight));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, gameRef.size.x, _floorHeight),
      baseGradient,
    );

    // Draw crystal blocks on top row
    final tilesNeeded = (gameRef.size.x / _tileWidth).ceil() + 2;

    for (int i = 0; i < tilesNeeded; i++) {
      final x = (i * _tileWidth) - _scrollOffset;

      // Render crystal tile at top of floor
      _crystalBlockSprite.render(
        canvas,
        position: Vector2(x, 0),
        size: Vector2(_tileWidth, _tileHeight),
      );
    }

    // Draw a highlight line at top for visual edge
    final edgePaint = Paint()
      ..color = const Color(0xFF3a3a6e)
      ..strokeWidth = 2.0;
    canvas.drawLine(const Offset(0, 0), Offset(gameRef.size.x, 0), edgePaint);
  }
}
