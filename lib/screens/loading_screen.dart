import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../game/user_settings.dart';
import 'game_screen.dart';

class LoadingScreen extends StatefulWidget {
  final UserSettings settings;

  const LoadingScreen({super.key, required this.settings});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late GameMode selectedMode;
  late GameTheme selectedTheme;
  int selectedDuration = 60;
  Color customColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    selectedMode = widget.settings.mode;
    selectedTheme = widget.settings.theme;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Keystorm',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),

              // MODE SELECTION
              const Text("Select Mode",
                  style: TextStyle(color: Colors.white)),
              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                children: GameMode.values.map((mode) {
                  return ChoiceChip(
                    label: Text(mode.name.toUpperCase()),
                    selected: selectedMode == mode,
                    onSelected: (_) {
                      setState(() => selectedMode = mode);
                    },
                  );
                }).toList(),
              ),

              if (selectedMode == GameMode.timed) ...[
                const SizedBox(height: 20),
                Text(
                  "Duration: $selectedDuration seconds",
                  style: const TextStyle(color: Colors.white),
                ),
                Slider(
                  value: selectedDuration.toDouble(),
                  min: 10,
                  max: 120,
                  divisions: 11,
                  label: selectedDuration.toString(),
                  onChanged: (value) {
                    setState(() =>
                        selectedDuration = value.toInt());
                  },
                ),
              ],

              const SizedBox(height: 30),

              // THEME SELECTION
              const Text("Select Theme",
                  style: TextStyle(color: Colors.white)),
              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                children: GameTheme.values.map((theme) {
                  return ChoiceChip(
                    label: Text(theme.name.toUpperCase()),
                    selected: selectedTheme == theme,
                    onSelected: (_) {
                      setState(() => selectedTheme = theme);
                    },
                  );
                }).toList(),
              ),

              if (selectedTheme == GameTheme.custom) ...[
                const SizedBox(height: 20),
                BlockPicker(
                  pickerColor: customColor,
                  onColorChanged: (color) {
                    setState(() => customColor = color);
                  },
                )
              ],

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () {
                  final settings = UserSettings()
                    ..mode = selectedMode
                    ..theme = selectedTheme
                    ..timedDurationSeconds = selectedDuration
                    ..customColor = customColor;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          GameScreen(settings: settings),
                    ),
                  );
                },
                child: const Text("Start Game"),
              )
            ],
          ),
        ),
      ),
    );
  }
}