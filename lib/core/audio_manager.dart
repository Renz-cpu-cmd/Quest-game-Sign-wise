import 'package:audioplayers/audioplayers.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Audio manager for game sounds and music
class AudioManager {
  static final AudioManager instance = AudioManager._internal();
  factory AudioManager() => instance;
  AudioManager._internal();

  // Dedicated player for BGM (looping)
  final AudioPlayer _bgmPlayer = AudioPlayer();

  bool _initialized = false;

  // Volume settings (0.0 to 1.0)
  double bgmVolume = 0.5;
  double sfxVolume = 0.5;

  static const String prefBgmKey = 'settings_bgm_vol';
  static const String prefSfxKey = 'settings_sfx_vol';

  /// Initialize audio system
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Load volume settings
      final prefs = await SharedPreferences.getInstance();
      bgmVolume = prefs.getDouble(prefBgmKey) ?? 0.5;
      sfxVolume = prefs.getDouble(prefSfxKey) ?? 0.5;

      _initialized = true;
      debugPrint('Audio system initialized (BGM: $bgmVolume, SFX: $sfxVolume)');
    } catch (e) {
      debugPrint('Failed to initialize audio: $e');
    }
  }

  /// Update BGM Volume
  Future<void> setBgmVolume(double value) async {
    bgmVolume = value.clamp(0.0, 1.0);
    // Update active music volume if playing
    _bgmPlayer.setVolume(bgmVolume);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(prefBgmKey, bgmVolume);
  }

  /// Update SFX Volume
  Future<void> setSfxVolume(double value) async {
    sfxVolume = value.clamp(0.0, 1.0);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(prefSfxKey, sfxVolume);
  }

  /// Play splash screen crystal chime
  Future<void> playSplashChime() async {
    try {
      final player = AudioPlayer();
      await player.setVolume(sfxVolume);
      await player.play(AssetSource('audio/sfx/crystal_chime.mp3'));
      debugPrint('Playing splash chime');
    } catch (e) {
      debugPrint('Failed to play splash chime: $e');
    }
  }

  /// Play background music (looped)
  Future<void> playBGM() async {
    try {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(bgmVolume);
      await _bgmPlayer.play(AssetSource('audio/bgm/menu_theme.mp3'));
      debugPrint('BGM playing at volume $bgmVolume');
    } catch (e) {
      debugPrint('Failed to play BGM: $e');
    }
  }

  /// Stop background music
  Future<void> stopBGM() async {
    try {
      await _bgmPlayer.stop();
    } catch (e) {
      debugPrint('Failed to stop BGM: $e');
    }
  }

  /// Play attack sound effect
  Future<void> playAttackSFX() async {
    if (!_initialized) return;
    _playSFX('sword_swing.mp3');
  }

  /// Play correct answer sound effect
  Future<void> playCorrectAnswerSFX() async {
    if (!_initialized) return;
    _playSFX('magic_chime.mp3');
  }

  /// Play damage/wrong answer sound effect
  Future<void> playDamageSFX() async {
    if (!_initialized) return;
    _playSFX('glass_break.mp3');
  }

  /// Play jump sound effect
  Future<void> playJumpSFX() async {
    if (!_initialized) return;
    _playSFX('jump.mp3');
  }

  /// Play enemy defeat sound
  Future<void> playEnemyDefeatSFX() async {
    if (!_initialized) return;
    _playSFX('enemy_defeat.mp3');
  }

  /// Helper to play SFX with current volume
  Future<void> _playSFX(String file) async {
    if (sfxVolume <= 0) return;

    try {
      final player = AudioPlayer();
      await player.setVolume(sfxVolume);
      await player.play(AssetSource('audio/sfx/$file'));
      debugPrint('Playing SFX: $file at volume $sfxVolume');
    } catch (e) {
      debugPrint('Error playing SFX $file: $e');
    }
  }

  /// Clean up resources
  void dispose() {
    _bgmPlayer.dispose();
  }
}

/// Extension method to easily access audio manager
extension AudioManagerExtension on Object {
  AudioManager get audio => AudioManager.instance;
}
