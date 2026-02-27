import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/splash_screen.dart';

void main() {
  runApp(const KeyStormApp());
}

class KeyStormApp extends StatelessWidget {
  const KeyStormApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData.dark();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(
          fontFamily: GoogleFonts.orbitron().fontFamily,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
//this works