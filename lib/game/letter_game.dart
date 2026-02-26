import 'dart:async' as async;
import 'dart:math';

import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user_settings.dart';
import 'letter_component.dart';

class LetterGame extends FlameGame with KeyboardHandler {
  final UserSettings settings;

  LetterGame({required this.settings});

  final Random _random = Random();

  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  final ValueNotifier<int> timeNotifier = ValueNotifier(0);
  final ValueNotifier<int> highScoreNotifier = ValueNotifier(0);

  async.Timer? _spawnTimer;
  async.Timer? _timeTimer;

  double _spawnInterval = 1.2;
  double _letterSpeed = 120;

  final List<LetterComponent> letters = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadHighScore();

    if (settings.mode == GameMode.timed) {
      timeNotifier.value = settings.timedDurationSeconds;
      _timeTimer = async.Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          if (timeNotifier.value > 0) {
            timeNotifier.value--;
          } else {
            timer.cancel();
            gameOver();
          }
        },
      );
    }

    _startSpawning();
  }

  void _startSpawning() {
    _spawnTimer = async.Timer.periodic(
      Duration(milliseconds: (_spawnInterval * 1000).toInt()),
      (_) => _spawnLetter(),
    );
  }

  void _spawnLetter() {
    final letter =
        String.fromCharCode(_random.nextInt(26) + 65);

    final x = _random.nextDouble() * (size.x - 40);

    final component = LetterComponent(
      letter: letter,
      position: Vector2(x, 0),
      speed: _letterSpeed,
    );

    add(component);
    letters.add(component);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      size.toRect(),
      Paint()..color = settings.backgroundColor,
    );
    super.render(canvas);
  }

  @override
  bool onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is! KeyDownEvent) {
      return false;
    }

    final pressed = event.logicalKey.keyLabel.toUpperCase();
    if (pressed.length != 1) {
      return false;
    }

    for (final letter in letters.toList()) {
      if (letter.letter.toUpperCase() == pressed) {
        scoreNotifier.value++;
        letters.remove(letter);
        letter.removeFromParent();
        _increaseDifficulty();
        return true;
      }
    }

    if (settings.mode == GameMode.survival) {
      gameOver();
    }

    return true;
  }

  void _increaseDifficulty() {
    if (scoreNotifier.value % 10 == 0) {
      _letterSpeed += 20;
      _spawnInterval =
          (_spawnInterval - 0.1).clamp(0.4, 2.0);
      _spawnTimer?.cancel();
      _startSpawning();
    }
  }

  void gameOver() async {
    _spawnTimer?.cancel();
    _timeTimer?.cancel();
    pauseEngine();

    if (scoreNotifier.value > highScoreNotifier.value) {
      highScoreNotifier.value = scoreNotifier.value;
      final prefs =
          await SharedPreferences.getInstance();
      await prefs.setInt(
          'highscore', highScoreNotifier.value);
    }

    overlays.add('GameOver');
  }

  Future<void> _loadHighScore() async {
    final prefs =
        await SharedPreferences.getInstance();
    highScoreNotifier.value =
        prefs.getInt('highscore') ?? 0;
  }

  void reset() {
    children.whereType<LetterComponent>().forEach((e) {
      e.removeFromParent();
    });

    letters.clear();
    scoreNotifier.value = 0;
    _letterSpeed = 120;
    _spawnInterval = 1.2;
    overlays.remove('GameOver');
    resumeEngine();
    _startSpawning();
  }
}