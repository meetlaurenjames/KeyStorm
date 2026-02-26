import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'letter_game.dart';
import 'user_settings.dart'; // 

class LetterComponent extends PositionComponent
    with HasGameRef<LetterGame> {
  final String letter;
  final TextPaint textPaint;

  LetterComponent({
    required this.letter,
    required Vector2 position,
    required double speed,
  })  : textPaint = TextPaint(
          style: const TextStyle(
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ) {
    this.position = position;
    size = Vector2.all(40);
    _speed = speed;
  }

  late double _speed;

  @override
  void update(double dt) {
    super.update(dt);
    position.y += _speed * dt;

    if (position.y > gameRef.size.y) {
      // Survival mode = game over if letter reaches bottom
      if (gameRef.settings.mode == GameMode.survival) {
        gameRef.gameOver();
      }
      gameRef.letters.remove(this);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    textPaint.render(canvas, letter, Vector2.zero());
  }
}