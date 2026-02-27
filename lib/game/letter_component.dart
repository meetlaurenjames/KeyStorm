import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'letter_game.dart';
import 'user_settings.dart';

class LetterComponent extends PositionComponent with HasGameRef<LetterGame> {
  final String letter;
  late TextPaint textPaint;
  final double speed;

  bool _paused = false;

  LetterComponent({
    required this.letter,
    required Vector2 position,
    required this.speed,
  }) {
    this.position = position;
    size = Vector2.all(40);

    textPaint = TextPaint(
      style: GoogleFonts.orbitron(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ).copyWith(shadows: [
        const Shadow(
          blurRadius: 2,
          color: Colors.white,
          offset: Offset(0, 0),
        )
      ]),
    );
  }

  bool _hitAnimation = false;
  double _hitTime = 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (_paused) return;

    if (!_hitAnimation) {
      position.y += speed * dt;
      if (position.y > gameRef.size.y) {
        if (gameRef.settings.mode == GameMode.survival) {
          gameRef.gameOver();
        }
        gameRef.letters.remove(this);
        removeFromParent();
      }
    } else {
      _hitTime += dt;
      position.y -= speed * dt * 1.5 * dt;
      if (_hitTime > 0.2) removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    textPaint.render(canvas, letter, Vector2.zero());
  }

  void hit() {
    if (_hitAnimation) return;
    _hitAnimation = true;

    textPaint = TextPaint(
      style: GoogleFonts.orbitron(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Colors.yellowAccent,
      ).copyWith(shadows: [
        const Shadow(
          blurRadius: 8,
          color: Colors.yellow,
          offset: Offset(0, 0),
        )
      ]),
    );

    for (int i = 0; i < 5; i++) {
      final particle = CircleParticleComponent(
        position: position.clone() + Vector2(size.x / 2, size.y / 2),
        radius: 2,
        paint: Paint()..color = Colors.yellowAccent,
        velocity: Vector2(
          (gameRef.random.nextDouble() - 0.5) * 100,
          (gameRef.random.nextDouble() - 0.5) * 100,
        ),
        lifespan: 0.4 + gameRef.random.nextDouble() * 0.2,
      );
      gameRef.add(particle);
    }
  }

  void pause() => _paused = true;
  void resume() => _paused = false;
}

/// Minimal particle for Flame 1.35.1
class CircleParticleComponent extends PositionComponent {
  final Vector2 velocity;
  final Paint paint;
  final double lifespan;
  double _age = 0;
  final double radius;

  CircleParticleComponent({
    required Vector2 position,
    required this.velocity,
    required this.paint,
    required this.lifespan,
    this.radius = 2,
  }) {
    this.position = position;
    size = Vector2.all(radius * 2);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= lifespan) removeFromParent();
    position += velocity * dt;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset(radius, radius),
      radius,
      paint,
    );
  }
}