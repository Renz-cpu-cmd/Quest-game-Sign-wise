/// Game state enumeration
enum GameState {
  playing,
  paused,
  clash, // ASL Quiz active
  gameOver,
}

/// Manages the game state including lives, score, and XP
class GameStateManager {
  GameState currentState = GameState.playing;
  int lives = 3;
  int score = 0;
  int xp = 0;
  int gold = 0;
  bool isInvincible = false;
  double invincibilityTimer = 0;

  // Difficulty scales with score: 0 = 0.0, 1000 = 1.0, etc.
  // Clamped to max 5.0 speed multiplier logic maybe
  double get difficulty => (score / 1000).clamp(0.0, 5.0);

  // Callbacks for state changes
  Function()? onGameOver;
  Function(int lives)? onLivesChanged;
  Function(int xp)? onXPChanged;
  Function(int gold)? onGoldChanged;

  /// Add XP and update score
  void addXP(int amount) {
    xp += amount;
    score += amount;
    onXPChanged?.call(xp);
    onXPChanged?.call(xp);
  }

  /// Add Gold to session
  void addGold(int amount) {
    gold += amount;
    onGoldChanged?.call(gold);
  }

  /// Lose a life (if not invincible)
  void loseLife() {
    if (isInvincible || lives <= 0) return;

    lives--;
    onLivesChanged?.call(lives);

    if (lives <= 0) {
      currentState = GameState.gameOver;
      onGameOver?.call();
    } else {
      // Trigger invincibility after taking damage
      setInvincible(2.0); // 2 seconds of invincibility
    }
  }

  /// Set invincibility for a duration
  void setInvincible(double duration) {
    isInvincible = true;
    invincibilityTimer = duration;
  }

  /// Update invincibility timer (call in game update loop)
  void updateInvincibility(double dt) {
    if (isInvincible) {
      invincibilityTimer -= dt;
      if (invincibilityTimer <= 0) {
        isInvincible = false;
        invincibilityTimer = 0;
      }
    }
  }

  /// Reset game state for new game
  void reset() {
    currentState = GameState.playing;
    lives = 3;
    score = 0;
    xp = 0;
    gold = 0;
    isInvincible = false;
    invincibilityTimer = 0;
  }

  /// Pause the game
  void pause() {
    if (currentState == GameState.playing) {
      currentState = GameState.paused;
    }
  }

  /// Resume the game
  void resume() {
    if (currentState == GameState.paused || currentState == GameState.clash) {
      currentState = GameState.playing;
    }
  }

  /// Enter clash state (quiz active)
  void enterClash() {
    currentState = GameState.clash;
  }
}
