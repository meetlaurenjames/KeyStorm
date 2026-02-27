import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../game/user_settings.dart';
import 'game_screen.dart';

class LoadingScreen extends StatefulWidget {
  final UserSettings settings; // Accept settings now

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
    selectedDuration = widget.settings.timedDurationSeconds;
    customColor = widget.settings.customColor ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Hero logo for smooth transition from splash screen
              Hero(
                tag: 'keystorm-logo',
                child: SvgPicture.asset(
                  'assets/images/keystorm_cloud.svg',
                  width: 150,
                  height: 150,
                ),
              ),
              const SizedBox(height: 40),

              // MODE SELECTION
              const Text("Select Mode", style: TextStyle(color: Colors.white)),
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
                  "Duration: ${selectedDuration ~/ 60}m ${selectedDuration % 60}s",
                  style: const TextStyle(color: Colors.white),
                ),
                Slider(
                  value: selectedDuration.toDouble(),
                  min: 30,
                  max: 300,
                  divisions: 9,
                  label: '${selectedDuration ~/ 60}m ${selectedDuration % 60}s',
                  onChanged: (value) {
                    setState(() => selectedDuration = (value ~/ 30 * 30));
                  },
                ),
              ],

              const SizedBox(height: 30),

              // THEME SELECTION
              const Text("Select Theme", style: TextStyle(color: Colors.white)),
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
                      builder: (_) => GameScreen(settings: settings),
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