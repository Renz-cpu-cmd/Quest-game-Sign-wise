import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/audio_manager.dart';
import '../game/crystal_quest_game.dart';
import '../components/particle_effects.dart';
import 'enemy.dart';
import 'ground_enemy.dart';
import 'obstacle.dart';
import '../core/enums.dart'; // PlayerState, HeroAssetType
import '../models/hero_data.dart';

/// Player character component
/// Handles animations, physics, and player actions
/// Supports polymorphic loading (Frames vs Sprite Sheets)
class Player extends SpriteAnimationGroupComponent<PlayerState>
    with HasGameReference<CrystalQuestGame>, CollisionCallbacks {
  final HeroData heroData;

  Player({
    required Vector2 position,
    required this.floorY,
    required this.heroData,
  }) : super(position: position, anchor: Anchor.bottomLeft);

  final double floorY;
  Vector2 velocity = Vector2.zero();
  bool isOnGround = true;
  bool isJumping = false;
  bool isDucking = false;
  bool isAttacking = false;

  // Responsive size calculated from screen
  late double playerHeight;
  late double playerWidth;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Calculate responsive size based on screen height
    playerHeight = game.size.y * GameConstants.playerHeightRatio;

    // For sprite sheet heroes, calculate aspect ratio from actual sprite dimensions
    if (heroData.assetType == HeroAssetType.frames) {
      // Gino: use original aspect ratio
      playerWidth = playerHeight * GameConstants.playerAspectRatio;
    } else {
      // Sprite sheet heroes: calculate from actual first frame dimensions
      final idleConfig = heroData.spriteSheetConfigs?[PlayerState.idle];
      if (idleConfig != null) {
        final image = await game.images.load(idleConfig.assetPath);
        final frameWidth = (image.width ~/ idleConfig.frameCount).toDouble();
        final frameHeight = image.height.toDouble();
        final actualAspectRatio = frameWidth / frameHeight;
        playerWidth = playerHeight * actualAspectRatio;
        debugPrint(
          'Sprite sheet hero: ${heroData.name} - Frame: ${frameWidth}x$frameHeight, Aspect: $actualAspectRatio',
        );
      } else {
        playerWidth = playerHeight; // Fallback to 1:1
      }
    }
    size = Vector2(playerWidth, playerHeight);

    // Apply Tint if present (e.g. Robot)
    if (heroData.tint != null) {
      paint.colorFilter = ColorFilter.mode(heroData.tint!, BlendMode.srcATop);
    }

    // Load animations based on Asset Type
    if (heroData.assetType == HeroAssetType.frames) {
      // Legacy Loading for Gino (Frames)
      animations = {
        PlayerState.run: await _loadGinoRun(),
        PlayerState.jump: await _loadGinoJump(),
        PlayerState.duck: await _loadGinoDuck(),
        PlayerState.attack: await _loadGinoAttack(),
        PlayerState.idle: await _loadGinoRun(), // Fallback
      };
    } else {
      // Modern Loading for Sheets (Wizard, Knight, Archer, etc.)
      animations = {
        PlayerState.idle: await _loadSpriteSheetAnimation(PlayerState.idle),
        PlayerState.run: await _loadSpriteSheetAnimation(PlayerState.run),
        PlayerState.jump: await _loadSpriteSheetAnimation(PlayerState.jump),
        PlayerState.duck: await _loadSpriteSheetAnimation(PlayerState.duck),
        PlayerState.attack: await _loadSpriteSheetAnimation(PlayerState.attack),
        PlayerState.hit: await _loadSpriteSheetAnimation(PlayerState.hit),
      };
    }

    // Set initial state
    current = PlayerState.run;

    // Add collision detection with matching hitbox size
    // Add collision detection with reduced hitbox for tighter gameplay
    add(
      RectangleHitbox(
        size: size * 0.6,
        position: size / 2,
        anchor: Anchor.center,
      ),
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    // Check if player is attacking and hits an enemy
    // Use isAttacking flag which is more reliable than current state
    if (isAttacking) {
      debugPrint('Player attacking collision with ${other.runtimeType}');
      if (other is RunnerEnemy) {
        other.onHitByPlayer();
        return; // Attack successful, no damage to player
      } else if (other is GroundEnemy) {
        other.onHitByPlayer();
        return;
      }
    }

    // Passive collision (take damage)
    if (other is RunnerEnemy || other is GroundEnemy || other is Obstacle) {
      game.onPlayerHit();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Apply gravity
    if (!isOnGround) {
      velocity.y += GameConstants.gravity * dt;
      if (velocity.y > GameConstants.maxFallSpeed) {
        velocity.y = GameConstants.maxFallSpeed;
      }
    }

    // Update position
    position.y += velocity.y * dt;

    // Ground collision check
    if (position.y >= floorY) {
      position.y = floorY;
      velocity.y = 0;
      isOnGround = true;
      isJumping = false;

      // Return to run state if not ducking or attacking
      if (current == PlayerState.jump && !isDucking && !isAttacking) {
        current = PlayerState.run;
        _resetHitbox();
      }
    }

    // Check animation completion using animationTicker
    if (current == PlayerState.attack || current == PlayerState.duck) {
      final ticker = animationTicker;
      if (ticker != null && ticker.done()) {
        // Animation finished (using done() for non-looping animations)

        if (isDucking) _resetHitbox(); // Reset hitbox if we were ducking

        isAttacking = false;
        isDucking = false;
        current = PlayerState.run;
      }
    }
  }

  /// Jump action
  void jump() {
    if (isOnGround && !isDucking && !isAttacking) {
      velocity.y = GameConstants.jumpForce;
      isOnGround = false;
      isJumping = true;
      current = PlayerState.jump;

      // Reset jump animation
      animationTicker?.reset();

      AudioManager.instance.playJumpSFX();

      final dustPosition = Vector2(position.x, position.y + size.y);
      final dustCloud = ParticleEffectComponent.createDustCloud(dustPosition);
      game.add(dustCloud);
    }
  }

  /// Duck/slide action
  void duck() {
    if (isOnGround && !isJumping && !isAttacking) {
      isDucking = true;
      current = PlayerState.duck;
      animationTicker?.reset();

      // Resize hitbox for ducking (50% height)
      final hitbox = children.query<RectangleHitbox>().first;
      hitbox.size = Vector2(size.x, size.y * 0.5);
      hitbox.position = Vector2(0, size.y * 0.5); // Move down
    }
  }

  void _resetHitbox() {
    final hitbox = children.query<RectangleHitbox>().first;
    hitbox.size = size;
    hitbox.position = Vector2.zero();
  }

  /// Attack action
  void attack() {
    if (!isAttacking && !isDucking) {
      isAttacking = true;
      current = PlayerState.attack;
      animationTicker?.reset();
      AudioManager.instance.playAttackSFX();
    }
  }

  // --- SPRITE SHEET LOADER ---

  Future<SpriteAnimation> _loadSpriteSheetAnimation(PlayerState state) async {
    final config = heroData.spriteSheetConfigs?[state];
    if (config == null) {
      // Fallback to idle or create placeholder
      return _createFallbackAnimation();
    }

    try {
      final image = await game.images.load(config.assetPath);

      // Use integer division (floor) to prevent fractional frame widths
      // This fixes the "wrap" effect where sprites bleed into adjacent frames
      final frameWidth = (image.width ~/ config.frameCount).toDouble();
      final frameHeight = image.height.toDouble();

      debugPrint('Loading $state: ${config.assetPath}');
      debugPrint(
        '  Image: ${image.width}x${image.height}, Frames: ${config.frameCount}',
      );
      debugPrint('  Frame size: ${frameWidth}x$frameHeight');
      debugPrint('  Component size: ${size.x}x${size.y}');

      // Build frames manually with exact integer positions to avoid texture bleeding
      final sprites = <Sprite>[];
      for (int i = 0; i < config.frameCount; i++) {
        sprites.add(
          Sprite(
            image,
            srcPosition: Vector2(i * frameWidth, 0),
            srcSize: Vector2(frameWidth, frameHeight),
          ),
        );
      }

      return SpriteAnimation.spriteList(
        sprites,
        stepTime: config.stepTime,
        loop: config.loop,
      );
    } catch (e) {
      debugPrint('Error loading ${config.assetPath}: $e');
      return _createFallbackAnimation();
    }
  }

  Future<SpriteAnimation> _createFallbackAnimation() async {
    // Return a dummy red square animation
    // Ideally use a 'missing texture' asset, but re-using run01 is safe fallback
    try {
      final sprite = await Sprite.load('heroes/gino/run/run01.png');
      return SpriteAnimation.spriteList([sprite], stepTime: 0.1);
    } catch (e) {
      // Last resort
      return SpriteAnimation.spriteList([], stepTime: 1); // Empty
    }
  }

  // --- LEGACY GINO FRAMES LOADER ---

  Future<SpriteAnimation> _loadGinoRun() async {
    final frames = [
      'run01.png',
      'run02.png',
      'run03.png',
      'run04.png',
      'run05.png',
      'run06.png',
      'run07.png',
      'run08.png',
    ];
    return _loadAnimationFromFrames(
      'heroes/gino/run',
      frames,
      GameConstants.runAnimationSpeed,
      loop: true,
    );
  }

  Future<SpriteAnimation> _loadGinoJump() async {
    final frames = [
      'jump_start01.png',
      'jump_start02.png',
      'jump_mid01.png',
      'jump_mid02.png',
      'jump_mid03.png',
      'jump_mid04.png',
      'jump_landing.png',
    ];
    return _loadAnimationFromFrames(
      'heroes/gino/run',
      frames,
      GameConstants.jumpAnimationSpeed,
      loop: false,
    );
  }

  Future<SpriteAnimation> _loadGinoDuck() async {
    final frames = [
      'slide_start01.png',
      'slide_start02.png',
      'slide.png',
      'slide_end01.png',
      'slide_end02.png',
    ];
    return _loadAnimationFromFrames(
      'heroes/gino/duck',
      frames,
      GameConstants.duckAnimationSpeed,
      loop: false,
    );
  }

  Future<SpriteAnimation> _loadGinoAttack() async {
    final frames = [
      'AttackA01.png',
      'AttackA02.png',
      'AttackA03.png',
      'AttackA04.png',
      'AttackA05.png',
      'AttackA06.png',
      'AttackA07.png',
    ];
    return _loadAnimationFromFrames(
      'heroes/gino/attack',
      frames,
      GameConstants.attackAnimationSpeed,
      loop: false,
    );
  }

  Future<SpriteAnimation> _loadAnimationFromFrames(
    String basePath,
    List<String> frameNames,
    double stepTime, {
    bool loop = true,
  }) async {
    final sprites = <Sprite>[];
    for (final frameName in frameNames) {
      try {
        final image = await game.images.load('$basePath/$frameName');
        sprites.add(Sprite(image));
      } catch (e) {
        debugPrint('Warning: Could not load sprite $basePath/$frameName: $e');
      }
    }
    if (sprites.isEmpty) return _createFallbackAnimation();
    return SpriteAnimation.spriteList(sprites, stepTime: stepTime, loop: loop);
  }

  @override
  void render(Canvas canvas) {
    canvas.save();

    // VISUAL FIX: Shift sprite down slightly to sink feet into ground
    // Sinking 12 pixels to account for bottom padding or floating feel
    canvas.translate(0, 12);

    // Clip sprite to component bounds to prevent overflow/wrap effect
    // This is important for attack animations where the character moves within the frame
    canvas.clipRect(Rect.fromLTWH(0, 0, size.x, size.y));

    paint.filterQuality = FilterQuality.none;
    super.render(canvas);
    canvas.restore();
  }
}
