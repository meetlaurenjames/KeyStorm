import 'package:flutter/material.dart';

enum GameMode { survival, timed, zen }
enum GameTheme { space, forest, ocean, custom }

class UserSettings {
  GameMode mode = GameMode.survival;
  GameTheme theme = GameTheme.space;
  Color customColor = Colors.grey;
  int timedDurationSeconds = 60;
  bool announceLetters = true;

  /// Returns a solid color for UI fallback / custom theme
  Color get backgroundColor {
    switch (theme) {
      case GameTheme.space:
        return Colors.black;
      case GameTheme.forest:
        return Colors.green.shade900;
      case GameTheme.ocean:
        return Colors.blue.shade900;
      case GameTheme.custom:
        return customColor;
    }
  }

  /// Returns the asset path for video background if applicable
  String? get backgroundVideo {
    switch (theme) {
      case GameTheme.space:
        return 'assets/videos/space_loop.mp4';
      case GameTheme.forest:
        return 'assets/videos/forest_loop.mp4';
      case GameTheme.ocean:
        return 'assets/videos/ocean_loop.mp4';
      case GameTheme.custom:
        return null; // custom theme uses solid color
    }
  }
}