import 'package:flutter/material.dart';

enum GameMode { survival, timed, zen }
enum GameTheme { space, forest, ocean, custom }

class UserSettings {
  GameMode mode = GameMode.survival;
  GameTheme theme = GameTheme.space;
  Color customColor = Colors.grey;
  int timedDurationSeconds = 60;
  bool announceLetters = true;

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
}