import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:math';

/// Particle effect component for visual feedback
class ParticleEffectComponent extends Component {
  ParticleEffectComponent();

  /// Create crystal explosion effect when enemy is defeated
  static ParticleSystemComponent createCrystalExplosion(Vector2 position) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: 20,
        lifespan: 1.0,
        generator: (i) {
          final random = Random();
          final speed = random.nextDouble() * 200 + 100; // 100-300 pixels/s
          final angle = random.nextDouble() * 2 * pi;

          return AcceleratedParticle(
            acceleration: Vector2(0, 200), // Gravity
            speed: Vector2(cos(angle), sin(angle)) * speed,
            position: position.clone(),
            child: ComputedParticle(
              lifespan: 1.0,
              renderer: (canvas, particle) {
                final progress = particle.progress;
                final size = (1 - progress) * 8; // Shrink over time

                // Purple/blue crystal colors
                final colors = [
                  const Color(0xFF8B5CF6),
                  const Color(0xFF6366F1),
                  const Color(0xFFA78BFA),
                ];
                final color = colors[i % colors.length];

                final paint = Paint()..color = color.withOpacity(1 - progress);

                canvas.drawCircle(Offset.zero, size, paint);

                // Add glow
                final glowPaint = Paint()
                  ..color = color.withOpacity((1 - progress) * 0.3)
                  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

                canvas.drawCircle(Offset.zero, size * 1.5, glowPaint);
              },
            ),
          );
        },
      ),
      position: position,
    );
  }

  /// Create dust cloud effect when player jumps
  static ParticleSystemComponent createDustCloud(Vector2 position) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: 8,
        lifespan: 0.5,
        generator: (i) {
          final random = Random();
          final speed = random.nextDouble() * 50 + 20; // 20-70 pixels/s
          final angle =
              -pi / 2 + (random.nextDouble() - 0.5) * pi / 3; // Upward spread

          return AcceleratedParticle(
            acceleration: Vector2(0, 100), // Light gravity
            speed: Vector2(cos(angle), sin(angle)) * speed,
            position: position.clone(),
            child: ComputedParticle(
              lifespan: 0.5,
              renderer: (canvas, particle) {
                final progress = particle.progress;
                final size = (1 - progress) * 4; // Small dust particles

                final paint = Paint()
                  ..color = Colors.white.withOpacity((1 - progress) * 0.6);

                canvas.drawCircle(Offset.zero, size, paint);
              },
            ),
          );
        },
      ),
      position: position,
    );
  }

  /// Create sparkle effect for correct answer
  static ParticleSystemComponent createSuccessSparkles(Vector2 position) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: 30,
        lifespan: 1.5,
        generator: (i) {
          final random = Random();
          final speed = random.nextDouble() * 150 + 50;
          final angle = random.nextDouble() * 2 * pi;

          return AcceleratedParticle(
            acceleration: Vector2(0, -50), // Float upward
            speed: Vector2(cos(angle), sin(angle)) * speed,
            position: position.clone(),
            child: ComputedParticle(
              lifespan: 1.5,
              renderer: (canvas, particle) {
                final progress = particle.progress;
                final size = (1 - progress) * 6;

                // Gold color
                final paint = Paint()
                  ..color = const Color(0xFFFFD700).withOpacity(1 - progress);

                // Draw star shape
                canvas.drawCircle(Offset.zero, size, paint);

                // Add glow
                final glowPaint = Paint()
                  ..color = const Color(
                    0xFFFFD700,
                  ).withOpacity((1 - progress) * 0.4)
                  ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

                canvas.drawCircle(Offset.zero, size * 2, glowPaint);
              },
            ),
          );
        },
      ),
      position: position,
    );
  }
}
