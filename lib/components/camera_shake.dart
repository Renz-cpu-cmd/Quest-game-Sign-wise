import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

/// Camera shake effect component
class CameraShake extends Component {
  CameraShake({required this.duration, this.intensity = 10.0, this.onComplete});

  final double duration;
  final double intensity;
  final VoidCallback? onComplete;

  double _elapsed = 0;
  Vector2 _originalPosition = Vector2.zero();
  bool _isShaking = false;

  @override
  void onMount() {
    super.onMount();
    _isShaking = true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_isShaking) return;

    _elapsed += dt;

    if (_elapsed >= duration) {
      // Shake complete
      _isShaking = false;
      onComplete?.call();
      removeFromParent();
      return;
    }

    // Calculate shake offset using random values
    final progress = _elapsed / duration;
    final currentIntensity = intensity * (1 - progress); // Decrease over time

    final random = Random();
    final offsetX = (random.nextDouble() - 0.5) * currentIntensity * 2;
    final offsetY = (random.nextDouble() - 0.5) * currentIntensity * 2;

    // Apply shake to camera
    if (parent != null && parent is PositionComponent) {
      final posComponent = parent as PositionComponent;
      posComponent.position = _originalPosition + Vector2(offsetX, offsetY);
    }
  }

  /// Start the shake effect
  void start(Vector2 cameraPosition) {
    _originalPosition = cameraPosition.clone();
    _elapsed = 0;
    _isShaking = true;
  }
}
