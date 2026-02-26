import 'package:flutter/material.dart';
import 'settings_screen.dart';
import '../game/letter_game.dart';
import 'package:flame/game.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  GameMode selectedMode = GameMode.survival;

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
                'Select Mode',
                style: TextStyle(fontSize: 32, color: Colors.white),
              ),
              const SizedBox(height: 20),
              for (final mode in GameMode.values)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: ElevatedButton(
                    onPressed: () {
                      selectedMode = mode;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingsScreen(selectedMode: selectedMode),
                        ),
                      );
                    },
                    child: Text(mode.name.toUpperCase()),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SettingsScreen(selectedMode: selectedMode)),
                  );
                },
                child: const Text('Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}