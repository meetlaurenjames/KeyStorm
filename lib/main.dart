import 'package:flutter/material.dart';
import 'screens/loading_screen.dart';
import 'game/user_settings.dart';

void main() {
  runApp(const KeyStormApp());
}

class KeyStormApp extends StatelessWidget {
  const KeyStormApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: LoadingScreen(settings: UserSettings()),
    );
  }
}