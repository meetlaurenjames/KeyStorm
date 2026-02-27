import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'loading_screen.dart';
import '../game/user_settings.dart';

class SplashScreen extends StatefulWidget {
  final UserSettings? settings; // optional now

  const SplashScreen({super.key, this.settings});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late UserSettings settings;

  @override
  void initState() {
    super.initState();

    // Use provided settings or default
    settings = widget.settings ?? UserSettings()
      ..mode = GameMode.survival
      ..theme = GameTheme.space;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();

    // Navigate to loading screen after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => LoadingScreen(settings: settings),
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Hero(
            tag: 'keystorm-logo',
            child: SvgPicture.asset(
              'assets/images/keystorm_cloud.svg',
              width: 200,
              height: 200,
            ),
          ),
        ),
      ),
    );
  }
}