import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:keystorm/screens/game_screen.dart';

import '../game/letter_game.dart';
import '../game/user_settings.dart';

class SettingsScreen extends StatefulWidget {
  final GameMode selectedMode;

  const SettingsScreen({super.key, required this.selectedMode});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool soundEnabled = true;
  bool sayLetterName = false;
  GameTheme selectedTheme = GameTheme.space;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Settings',
                style: TextStyle(fontSize: 32, color: Colors.white),
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Enable Sound',
                    style: TextStyle(color: Colors.white)),
                value: soundEnabled,
                onChanged: (val) => setState(() => soundEnabled = val),
              ),
              SwitchListTile(
                title: const Text('Say Letter Name',
                    style: TextStyle(color: Colors.white)),
                value: sayLetterName,
                onChanged: (val) => setState(() => sayLetterName = val),
              ),
              const SizedBox(height: 10),
              const Text('Select Theme',
                  style: TextStyle(color: Colors.white)),
              for (final theme in GameTheme.values)
                RadioListTile<GameTheme>(
                  title: Text(
                    theme.name.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  value: theme,
                  groupValue: selectedTheme,
                  onChanged: (val) => setState(() => selectedTheme = val!),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final settings = UserSettings()
                    ..mode = widget.selectedMode
                    ..theme = selectedTheme
                    ..announceLetters = sayLetterName;

                 ElevatedButton(
                    onPressed: () {
                      final settings = UserSettings()
                        ..mode = widget.selectedMode
                        ..theme = selectedTheme
                        ..announceLetters = sayLetterName;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameScreen(settings: settings), // 👈 HERE
                        ),
                      );
                    },
                    child: const Text('Start Game'),
                  ),
                },
                child: const Text('Start Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}