import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flame/game.dart';
import '../game/letter_game.dart';
import '../game/user_settings.dart';
import 'loading_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class GameScreen extends StatefulWidget {
  final UserSettings settings;

  const GameScreen({super.key, required this.settings});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final LetterGame game;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  bool zenPaused = false;
  bool zenStopped = false; // Zen stop flag
  bool gameStarted = false; // for logo animation

  @override
  void initState() {
    super.initState();
    game = LetterGame(settings: widget.settings);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      setState(() => gameStarted = true);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleTextInput(String value) {
    if (value.isEmpty) return;
    final key = value.characters.last;
    game.handleKey(key);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Invisible TextField to force keyboard
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.0,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                onChanged: _handleTextInput,
                enableSuggestions: false,
                autocorrect: false,
                showCursor: false,
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
          ),

          // Game widget
          GameWidget(
            game: game,
            overlayBuilderMap: {
              'GameOver': (context, gameInstance) {
                final g = gameInstance as LetterGame;
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.black87,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ValueListenableBuilder<int>(
                          valueListenable: g.scoreNotifier,
                          builder: (context, score, _) {
                            String displayText = 'Game Over\nScore: $score';
                            if (widget.settings.mode == GameMode.survival) {
                              displayText += '\nHigh Score: ${g.highScoreNotifier.value}';
                            }
                            return Text(
                              displayText,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.orbitron(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                g.reset();
                                setState(() {
                                  zenPaused = false;
                                  zenStopped = false;
                                  gameStarted = true;
                                });
                                _focusNode.requestFocus();
                              },
                              child: const Text('Restart'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => LoadingScreen(
                                      settings: widget.settings,
                                    ),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: const Text('Main Menu'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              }
            },
          ),

          /// Cloud logo (partially off-screen top, show only bottom)
          /// Cloud logo with smooth Hero transition
          /// Cloud logo: full during Hero transition, then move up and clip
        /// Cloud logo: starts full, then moves up and gets clipped
        Hero(
          tag: 'keystorm-logo',
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 1.0, end: 0.35),
            duration: const Duration(seconds: 1),
            curve: Curves.easeOut,
            builder: (context, heightFactor, child) {
              return Align(
                alignment: Alignment.topCenter,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    heightFactor: heightFactor, // 1.0 = full cloud, 0.35 = clipped
                    child: child,
                  ),
                ),
              );
            },
            child: SvgPicture.asset(
              'assets/images/keystorm_cloud.svg',
              width: 230,
              height: 230,
              fit: BoxFit.cover,
            ),
          ),
        ),
          /// HUD below the cloud
          Positioned(
            top: screenHeight * 0.1, // slightly below cloud bottom
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// Score (always show)
                    ValueListenableBuilder<int>(
                      valueListenable: game.scoreNotifier,
                      builder: (context, score, _) => Text(
                        'Score: $score',
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    /// Timed mode: show timer
                    if (widget.settings.mode == GameMode.timed)
                      ValueListenableBuilder<int>(
                        valueListenable: game.timeNotifier,
                        builder: (context, totalSeconds, _) {
                          final minutes = totalSeconds ~/ 60;
                          final seconds = totalSeconds % 60;
                          final color = totalSeconds <= 5
                              ? Colors.red
                              : (totalSeconds <= 10 ? Colors.yellow : Colors.white);
                          return Text(
                            'Time: ${minutes}:${seconds.toString().padLeft(2, '0')}',
                            style: GoogleFonts.orbitron(
                              color: color,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                  ],
                ),

                /// Zen mode pause/resume/stop
                if (widget.settings.mode == GameMode.zen && !zenStopped) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!zenPaused)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              zenPaused = true;
                              game.pauseZen();
                            });
                          },
                          child: const Text('Pause'),
                        ),
                      if (zenPaused)
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  zenPaused = false;
                                  game.resumeZen();
                                });
                              },
                              child: const Text('Resume'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  game.gameOver();
                                  zenPaused = false;
                                  zenStopped = true;
                                });
                              },
                              child: const Text('Stop'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}