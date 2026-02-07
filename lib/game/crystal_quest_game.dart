import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

import '../core/constants.dart';
import '../core/game_state.dart';
import '../core/audio_manager.dart';
import '../entities/player.dart';
import '../entities/enemy.dart';
import '../entities/coin.dart';
import '../entities/obstacle.dart';
import '../entities/ground_enemy.dart';
import '../entities/bat_enemy.dart';
import '../entities/floor_terrain.dart';
import '../models/asl_sign.dart';
import '../models/hero_data.dart';
import '../components/particle_effects.dart';
import '../components/camera_shake.dart';

/// Main game class for Sign-Wise: Crystal Quest
/// A state-driven side-scroller where the world moves left and Gino stays centered
class CrystalQuestGame extends FlameGame with HasCollisionDetection {
  late Player player;
  late ParallaxComponent parallaxBackground;
  late GameStateManager gameState;
  double floorY = 0;

  // Economy
  static const String prefGoldKey = 'gold_balance';

  // Spawning System
  double spawnTimer = 0;
  // Increase difficulty -> decrease interval
  double spawnInterval = 3.0;
  final math.Random _random = math.Random();

  final List<RunnerEnemy> activeEnemies = [];

  // Callback when game is fully loaded
  VoidCallback? onGameReady;

  // Current clash state
  PositionComponent? currentClashEnemy;
  AslSign? currentQuizSign;

  @override
  Color backgroundColor() => const Color(0xFF1a0f2e); // Dark purple fallback

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize audio
    await AudioManager.instance.initialize();
    await AudioManager.instance.playBGM();

    // Initialize game state
    gameState = GameStateManager();
    gameState.onGameOver = _handleGameOver;

    // Calculate floor position (90% down the screen)
    floorY = size.y * GameConstants.floorHeightRatio;

    // Load and set up the 3-layer parallax background
    await _setupParallax();

    // Add visible floor terrain (crystal platform tiles)
    final floorTerrain = FloorTerrain();
    await add(floorTerrain);

    // Add the player
    await _addPlayer();

    // Camera setup - fixed position (world moves, not camera)
    camera.viewfinder.position = Vector2.zero();

    // Notify listeners that game is ready
    onGameReady?.call();

    // Activate UI overlays
    overlays.add('hud');
    overlays.add('input');
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameState.currentState == GameState.playing) {
      gameState.updateInvincibility(dt);
      _updateSpawning(dt);
    }
  }

  // --- Spawning Logic ---

  void _updateSpawning(double dt) {
    spawnTimer += dt;
    if (spawnTimer >= spawnInterval) {
      spawnTimer = 0;
      _spawnEntity();
    }
  }

  void _spawnEntity() {
    // Randomly choose what to spawn
    final rand = _random.nextDouble();
    // 50% Enemy, 30% Coin, 20% Spike
    if (rand < 0.5) {
      final enemyType = _random.nextDouble();
      if (enemyType < 0.33) {
        _spawnEnemy(); // Runner
      } else if (enemyType < 0.66) {
        _spawnGroundEnemy(); // Ground Mob
      } else {
        _spawnBat(); // Bat (Aerial)
      }
    } else if (rand < 0.8) {
      _spawnCoin();
    } else {
      _spawnObstacle();
    }
  }

  void _spawnEnemy() {
    // Spawn runner on ground
    final enemy = RunnerEnemy(position: Vector2(size.x + 100, floorY));
    add(enemy);
    activeEnemies.add(enemy);

    // Cleanup destroyed
    activeEnemies.removeWhere((e) => e.state == EnemyState.destroyed);
  }

  void _spawnGroundEnemy() {
    // Spawn at floor level - with bottomLeft anchor, position.y = floor level
    final enemy = GroundEnemy(
      position: Vector2(
        size.x + 50,
        floorY, // With bottomLeft anchor, bottom of sprite will be at floorY
      ),
      speed: 250 + (gameState.difficulty * 20),
    );
    add(enemy);
  }

  void _spawnBat() {
    // Spawn at head height (approx 120px above floor) to force ducking
    final enemy = BatEnemy(
      position: Vector2(size.x + 50, floorY - 120),
      speed: 220 + (gameState.difficulty * 15),
    );
    add(enemy);
  }

  void _spawnCoin() {
    // Coins spawn at jump height or ground height
    final isHigh = _random.nextBool();
    final yPos = isHigh ? floorY - 150 : floorY - 50;

    final coin = Coin(position: Vector2(size.x + 50, yPos));
    add(coin);
  }

  void _spawnObstacle() {
    // Spikes always on ground
    final spike = Obstacle(
      position: Vector2(size.x + 50, floorY),
      type: ObstacleType.spike,
    );
    add(spike);
  }

  // --- Economy Logic ---

  /// Add Gold to session
  void addGold(int amount) {
    gameState.addGold(amount);
    // Play sound / effect
    // AudioManager.instance.playCollectSFX();
  }

  Future<void> _saveGold() async {
    final prefs = await SharedPreferences.getInstance();
    final currentTotal = prefs.getInt(prefGoldKey) ?? 0;
    await prefs.setInt(prefGoldKey, currentTotal + gameState.gold);
  }

  // --- Setup Helpers ---

  /// Set up the 3-layer parallax background system
  Future<void> _setupParallax() async {
    final parallax = await loadParallaxComponent(
      [
        ParallaxImageData('environment/parallax/bg_layer1.png'),
        ParallaxImageData('environment/parallax/bg_layer2.png'),
        ParallaxImageData('environment/parallax/bg_layer3.png'),
      ],
      baseVelocity: Vector2(
        GameConstants.worldSpeed * GameConstants.parallaxLayer1Speed,
        0,
      ),
      velocityMultiplierDelta: Vector2(
        (GameConstants.parallaxLayer3Speed -
                GameConstants.parallaxLayer1Speed) /
            2,
        0,
      ),
      repeat: ImageRepeat.repeat,
      fill: LayerFill.width,
    );

    parallaxBackground = parallax;
    add(parallaxBackground);
  }

  /// Add the player character (Gino or selected hero)
  Future<void> _addPlayer() async {
    // Load selected hero from persistence
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('selected_hero_index') ?? 0;
    final roster = HeroData.getRoster();
    final selectedHero = roster[index];

    player = Player(
      position: Vector2(size.x * GameConstants.playerXRatio, floorY),
      floorY: floorY,
      heroData: selectedHero,
    );
    await add(player);
  }

  // --- Input Handlers ---

  /// Handle tap on left side of screen (Jump)
  void onLeftTap() {
    if (gameState.currentState == GameState.playing) {
      player.jump();
    }
  }

  /// Handle tap on right side of screen (Attack)
  void onRightTap() {
    if (gameState.currentState == GameState.playing) {
      player.attack();
    }
  }

  /// Handle swipe down (Duck/Slide)
  void onSwipeDown() {
    if (gameState.currentState == GameState.playing) {
      player.duck();
    }
  }

  // --- Combat / Gameplay Logic ---

  /// Called when Player hits a Hazard (Spike or Ground Enemy)
  void onPlayerHit() {
    if (gameState.isInvincible) return;

    gameState.loseLife();
    AudioManager.instance.playDamageSFX();
    _triggerScreenShake(intensity: 20);
  }

  /// Trigger ASL Clash when player hits enemy
  void triggerClash(PositionComponent enemy) {
    if (gameState.currentState != GameState.playing) return;

    // Pause the game
    pauseEngine();
    gameState.enterClash();

    // Store current clash info
    currentClashEnemy = enemy;
    currentQuizSign = AslSign.random();

    // Show quiz overlay
    overlays.add('quizTerminal');
  }

  /// Handle quiz answer
  void onQuizAnswer(String answer) {
    if (currentQuizSign == null || currentClashEnemy == null) return;

    final isCorrect = answer.toUpperCase() == currentQuizSign!.letter;

    if (isCorrect) {
      // Correct answer!
      gameState.addXP(100);

      // Play success effects
      AudioManager.instance.playCorrectAnswerSFX();
      AudioManager.instance.playEnemyDefeatSFX();

      // Add success sparkles at enemy position
      final sparkles = ParticleEffectComponent.createSuccessSparkles(
        currentClashEnemy!.position,
      );
      add(sparkles);

      // Add crystal explosion at enemy position
      final explosion = ParticleEffectComponent.createCrystalExplosion(
        currentClashEnemy!.position,
      );
      add(explosion);
    } else {
      // Wrong answer!
      gameState.loseLife();

      // Play damage effects
      AudioManager.instance.playDamageSFX();

      // Trigger screen shake
      _triggerScreenShake(intensity: 15.0, duration: 0.3);
    }

    // ALWAYS remove the enemy after clash (win or lose) to prevent "stuck" bugs
    currentClashEnemy!.removeFromParent();

    // Clean up and resume after delay for VFX
    Future.delayed(const Duration(milliseconds: 600), () {
      currentClashEnemy = null;
      currentQuizSign = null;
      overlays.remove('quizTerminal');
      resumeEngine();
      gameState.resume();
    });
  }

  /// Trigger screen shake effect
  void _triggerScreenShake({double intensity = 10.0, double duration = 0.3}) {
    final shake = CameraShake(intensity: intensity, duration: duration);
    shake.start(camera.viewfinder.position);
    camera.viewfinder.add(shake);
  }

  /// Pause game engine
  void pauseEngine() {
    paused = true;
  }

  /// Resume game engine
  void resumeEngine() {
    paused = false;
  }

  /// Handle game over
  void _handleGameOver() {
    pauseEngine();
    _saveGold(); // Save earnings
    overlays.add('gameOver');
  }

  /// Restart the game
  void restart() {
    // Remove all entities
    children.whereType<RunnerEnemy>().forEach((e) => e.removeFromParent());
    children.whereType<Coin>().forEach((e) => e.removeFromParent());
    children.whereType<Obstacle>().forEach((e) => e.removeFromParent());
    activeEnemies.clear();

    // Reset game state
    gameState.reset();
    spawnTimer = 0;
    // sessionGold handled by gameState.reset()

    // Reset player position
    player.position = Vector2(
      size.x * GameConstants.playerXRatio,
      floorY - player.playerHeight,
    );

    // Resume
    overlays.remove('gameOver');
    resumeEngine();
  }
}
