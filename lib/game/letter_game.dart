import 'dart:async' as async;
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_settings.dart';
import 'letter_component.dart';

class LetterGame extends FlameGame {
  final UserSettings settings;
  final Random random = Random();

  LetterGame({required this.settings});

  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  final ValueNotifier<int> timeNotifier = ValueNotifier(0);
  final ValueNotifier<int> highScoreNotifier = ValueNotifier(0);

  async.Timer? _spawnTimer;
  async.Timer? _timeTimer;

  double _spawnInterval = 1.2;
  double _letterSpeed = 120;

  final List<LetterComponent> letters = [];
  bool _isPaused = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadHighScore();

    if (settings.mode == GameMode.timed) {
      timeNotifier.value = settings.timedDurationSeconds;
      _timeTimer = async.Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          if (!_isPaused) {
            if (timeNotifier.value > 0) {
              timeNotifier.value--;
            } else {
              timer.cancel();
              gameOver();
            }
          }
        },
      );
    }

    _startSpawning();
  }

  void _startSpawning() {
    _spawnTimer?.cancel();
    _spawnTimer = async.Timer.periodic(
      Duration(milliseconds: (_spawnInterval * 1000).toInt()),
      (_) {
        if (!_isPaused) _spawnLetter();
      },
    );
  }

  void _spawnLetter() {
    if (size.x <= 0) return;
    final letter = String.fromCharCode(random.nextInt(26) + 65);
    final x = random.nextDouble() * (size.x - 40);
    final component = LetterComponent(
      letter: letter,
      position: Vector2(x, 0),
      speed: _letterSpeed,
    );
    add(component);
    letters.add(component);
  }

  /// Zen pause
  void pauseZen() {
    if (settings.mode != GameMode.zen) return;
    _isPaused = true;
    pauseEngine();
    _spawnTimer?.cancel();
    for (final letter in letters) {
      letter.pause();
    }
  }

  /// Zen resume
  void resumeZen() {
    if (settings.mode != GameMode.zen) return;
    _isPaused = false;
    resumeEngine();
    _startSpawning();
    for (final letter in letters) {
      letter.resume();
    }
  }

  void handleKey(String key) {
    if (_isPaused && settings.mode == GameMode.zen) return;
    final pressed = key.toUpperCase();
    if (pressed.length != 1) return;
    for (final letter in letters.toList()) {
      if (letter.letter.toUpperCase() == pressed) {
        scoreNotifier.value++;
        letter.hit();
        letters.remove(letter);
        _increaseDifficulty();
        return;
      }
    }
    if (settings.mode == GameMode.survival) {
      gameOver();
    }
  }

  @override
  void render(Canvas canvas) {
    // Only draw background if there is NO video
    if (settings.backgroundVideo == null) {
      canvas.drawRect(
        size.toRect(),
        Paint()..color = settings.backgroundColor,
      );
    }
    super.render(canvas);
  }

  // Make Flame transparent so video shows behind
  @override
  Color backgroundColor() => Colors.transparent;

  void _increaseDifficulty() {
    if (scoreNotifier.value % 10 == 0 && scoreNotifier.value > 0) {
      _letterSpeed += 20;
      _spawnInterval = (_spawnInterval - 0.1).clamp(0.4, 2.0);
      _startSpawning();
    }
  }

  void gameOver() async {
    _spawnTimer?.cancel();
    _timeTimer?.cancel();
    pauseEngine();

    if (settings.mode == GameMode.survival &&
        scoreNotifier.value > highScoreNotifier.value) {
      highScoreNotifier.value = scoreNotifier.value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highscore', highScoreNotifier.value);
    }

    overlays.add('GameOver');
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    highScoreNotifier.value = prefs.getInt('highscore') ?? 0;
  }

  void reset() {
    for (final letter in letters.toList()) {
      letter.removeFromParent();
    }
    letters.clear();

    scoreNotifier.value = 0;
    _letterSpeed = 120;
    _spawnInterval = 1.2;
    _isPaused = false;

    overlays.remove('GameOver');

    _spawnTimer?.cancel();
    _timeTimer?.cancel();

    if (settings.mode == GameMode.timed) {
      timeNotifier.value = settings.timedDurationSeconds;
      _timeTimer = async.Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          if (!_isPaused) {
            if (timeNotifier.value > 0) {
              timeNotifier.value--;
            } else {
              timer.cancel();
              gameOver();
            }
          }
        },
      );
    }

    _startSpawning();
    resumeEngine();
  }
}