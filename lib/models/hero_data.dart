import 'package:flutter/material.dart';
import '../core/enums.dart';

class AnimationConfig {
  final String assetPath;
  final int frameCount;
  final double stepTime;
  final bool loop;

  const AnimationConfig({
    required this.assetPath,
    required this.frameCount,
    required this.stepTime,
    this.loop = true,
  });
}

class HeroData {
  final String id;
  final String name;
  final HeroAssetType assetType;

  // For Carousel & Basic Info
  final String previewPath; // Using for Carousel (Idle)
  final int previewFrameCount;

  // For Gameplay (Sprite Sheets)
  final Map<PlayerState, AnimationConfig>? spriteSheetConfigs;

  final Color? tint;
  final int price;
  final bool isLocked;

  const HeroData({
    required this.id,
    required this.name,
    required this.assetType,
    required this.previewPath,
    this.previewFrameCount = 12,
    this.spriteSheetConfigs,
    this.tint,
    this.price = 0,
    this.isLocked = false,
  });

  static List<HeroData> getRoster() {
    return [
      // Wizard - sprite sheet hero
      HeroData(
        id: 'wizard',
        name: 'Wizard',
        assetType: HeroAssetType.spriteSheet,
        previewPath: 'heroes/wizard/Wizard_idle0001-sheet.png',
        previewFrameCount: 12,
        spriteSheetConfigs: {
          PlayerState.idle: const AnimationConfig(
            assetPath: 'heroes/wizard/Wizard_idle0001-sheet.png',
            frameCount: 12,
            stepTime: 0.1,
          ),
          PlayerState.run: const AnimationConfig(
            assetPath: 'heroes/wizard/Wizard_run0001-sheet.png',
            frameCount: 12,
            stepTime: 0.08,
          ),
          PlayerState.jump: const AnimationConfig(
            assetPath: 'heroes/wizard/Wizard_jump0001-sheet.png',
            frameCount: 12,
            stepTime: 0.08,
            loop: false,
          ),
          PlayerState.duck: const AnimationConfig(
            assetPath: 'heroes/wizard/Wizard_crouch0001-sheet.png',
            frameCount: 12,
            stepTime: 0.08,
            loop: false,
          ),
          PlayerState.attack: const AnimationConfig(
            assetPath: 'heroes/wizard/Wizard_punch0001-sheet.png',
            frameCount: 8,
            stepTime: 0.08,
            loop: false,
          ),
          PlayerState.hit: const AnimationConfig(
            assetPath: 'heroes/wizard/Wizard_hit0001-sheet.png',
            frameCount: 8,
            stepTime: 0.08,
            loop: false,
          ),
        },
      ),

      // Knight - sprite sheet hero
      HeroData(
        id: 'knight',
        name: 'Knight',
        assetType: HeroAssetType.spriteSheet,
        previewPath: 'heroes/knight/Knight_idle0001-sheet.png',
        previewFrameCount: 12,
        spriteSheetConfigs: {
          PlayerState.idle: const AnimationConfig(
            assetPath: 'heroes/knight/Knight_idle0001-sheet.png',
            frameCount: 12,
            stepTime: 0.1,
          ),
          PlayerState.run: const AnimationConfig(
            assetPath: 'heroes/knight/Knight_run0001-sheet.png',
            frameCount: 12,
            stepTime: 0.08,
          ),
          PlayerState.jump: const AnimationConfig(
            assetPath: 'heroes/knight/Knight_jump0001-sheet.png',
            frameCount: 12,
            stepTime: 0.08,
            loop: false,
          ),
          PlayerState.duck: const AnimationConfig(
            assetPath: 'heroes/knight/Knight_crouch0001-sheet.png',
            frameCount: 12,
            stepTime: 0.08,
            loop: false,
          ),
          PlayerState.attack: const AnimationConfig(
            assetPath: 'heroes/knight/Knight_punch0001-sheet.png',
            frameCount: 8,
            stepTime: 0.08,
            loop: false,
          ),
          PlayerState.hit: const AnimationConfig(
            assetPath: 'heroes/knight/Knight_hit0001-sheet.png',
            frameCount: 8,
            stepTime: 0.08,
            loop: false,
          ),
        },
      ),

      // Archer - sprite sheet hero (locked)
      HeroData(
        id: 'archer',
        name: 'Archer',
        assetType: HeroAssetType.spriteSheet,
        previewPath: 'heroes/archer/Archer_idle0001-sheet.png',
        previewFrameCount: 12,
        price: 500,
        isLocked: true,
        spriteSheetConfigs: {
          PlayerState.idle: const AnimationConfig(
            assetPath: 'heroes/archer/Archer_idle0001-sheet.png',
            frameCount: 12,
            stepTime: 0.1,
          ),
          PlayerState.run: const AnimationConfig(
            assetPath: 'heroes/archer/Archer_run0001-sheet.png',
            frameCount: 12,
            stepTime: 0.08,
          ),
          PlayerState.jump: const AnimationConfig(
            assetPath: 'heroes/archer/Archer_jump0001-sheet.png',
            frameCount: 12,
            stepTime: 0.08,
            loop: false,
          ),
          PlayerState.duck: const AnimationConfig(
            assetPath: 'heroes/archer/Archer_crouch0001-sheet.png',
            frameCount: 12,
            stepTime: 0.08,
            loop: false,
          ),
          PlayerState.attack: const AnimationConfig(
            assetPath: 'heroes/archer/Archer_punch0001-sheet.png',
            frameCount: 8,
            stepTime: 0.08,
            loop: false,
          ),
          PlayerState.hit: const AnimationConfig(
            assetPath: 'heroes/archer/Archer_hit0001-sheet.png',
            frameCount: 8,
            stepTime: 0.08,
            loop: false,
          ),
        },
      ),

      // King - sprite sheet hero (locked)
      HeroData(
        id: 'king',
        name: 'King',
        assetType: HeroAssetType.spriteSheet,
        previewPath: 'heroes/king/King_idle0001-sheet.png',
        previewFrameCount: 12,
        price: 500,
        isLocked: true,
        spriteSheetConfigs: {
          PlayerState.idle: const AnimationConfig(
            assetPath: 'heroes/king/King_idle0001-sheet.png',
            frameCount: 12,
            stepTime: 0.1,
          ),
          PlayerState.run: const AnimationConfig(
            assetPath: 'heroes/king/King_run0001-sheet.png',
            frameCount: 12,
            stepTime: 0.08,
          ),
          PlayerState.jump: const AnimationConfig(
            assetPath: 'heroes/king/King_jump0001-sheet.png',
            frameCount: 12,
            stepTime: 0.08,
            loop: false,
          ),
          PlayerState.duck: const AnimationConfig(
            assetPath: 'heroes/king/King_crouch0001-sheet.png',
            frameCount: 12,
            stepTime: 0.08,
            loop: false,
          ),
          PlayerState.attack: const AnimationConfig(
            assetPath: 'heroes/king/King_punch0001-sheet.png',
            frameCount: 8,
            stepTime: 0.08,
            loop: false,
          ),
          PlayerState.hit: const AnimationConfig(
            assetPath: 'heroes/king/King_hit0001-sheet.png',
            frameCount: 8,
            stepTime: 0.08,
            loop: false,
          ),
        },
      ),

      // Pirate - sprite sheet hero (locked)
      HeroData(
        id: 'pirate',
        name: 'Pirate',
        assetType: HeroAssetType.spriteSheet,
        previewPath: 'heroes/pirate/Pirate_idle0001-sheet.png',
        previewFrameCount: 12,
        price: 750,
        isLocked: true,
        spriteSheetConfigs: {
          PlayerState.idle: const AnimationConfig(
            assetPath: 'heroes/pirate/Pirate_idle0001-sheet.png',
            frameCount: 12,
            stepTime: 0.1,
          ),
          PlayerState.run: const AnimationConfig(
            assetPath: 'heroes/pirate/Pirate_run0001-sheet.png',
            frameCount: 12,
            stepTime: 0.08,
          ),
          PlayerState.jump: const AnimationConfig(
            assetPath: 'heroes/pirate/Pirate_jump0001-sheet.png',
            frameCount: 12,
            stepTime: 0.08,
            loop: false,
          ),
          PlayerState.duck: const AnimationConfig(
            assetPath: 'heroes/pirate/Pirate_crouch0001-sheet.png',
            frameCount: 12,
            stepTime: 0.08,
            loop: false,
          ),
          PlayerState.attack: const AnimationConfig(
            assetPath: 'heroes/pirate/Pirate_punch0001-sheet.png',
            frameCount: 8,
            stepTime: 0.08,
            loop: false,
          ),
          PlayerState.hit: const AnimationConfig(
            assetPath: 'heroes/pirate/Pirate_hit0001-sheet.png',
            frameCount: 8,
            stepTime: 0.08,
            loop: false,
          ),
        },
      ),

      // Musketeer - sprite sheet hero (locked)
      HeroData(
        id: 'musketeer',
        name: 'Musketeer',
        assetType: HeroAssetType.spriteSheet,
        previewPath: 'heroes/musketeer/Musketeer_idle0001-sheet.png',
        previewFrameCount: 12,
        price: 1000,
        isLocked: true,
        spriteSheetConfigs: {
          PlayerState.idle: const AnimationConfig(
            assetPath: 'heroes/musketeer/Musketeer_idle0001-sheet.png',
            frameCount: 12,
            stepTime: 0.1,
          ),
          PlayerState.run: const AnimationConfig(
            assetPath: 'heroes/musketeer/Musketeer_run0001-sheet.png',
            frameCount: 12,
            stepTime: 0.08,
          ),
          PlayerState.jump: const AnimationConfig(
            assetPath: 'heroes/musketeer/Musketeer_jump0001-sheet.png',
            frameCount: 12,
            stepTime: 0.08,
            loop: false,
          ),
          PlayerState.duck: const AnimationConfig(
            assetPath: 'heroes/musketeer/Musketeer_crouch0001-sheet.png',
            frameCount: 12,
            stepTime: 0.08,
            loop: false,
          ),
          PlayerState.attack: const AnimationConfig(
            assetPath: 'heroes/musketeer/Musketeer_punch0001-sheet.png',
            frameCount: 8,
            stepTime: 0.08,
            loop: false,
          ),
          PlayerState.hit: const AnimationConfig(
            assetPath: 'heroes/musketeer/Musketeer_hit0001-sheet.png',
            frameCount: 8,
            stepTime: 0.08,
            loop: false,
          ),
        },
      ),
    ];
  }
}
