import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  void initState() {
    super.initState();
    game = LetterGame(settings: widget.settings);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
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
    return Scaffold(
      body: Stack(
        children: [
          /// Invisible TextField to force keyboard
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

          /// Game widget
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
                            return ValueListenableBuilder<int>(
                              valueListenable: g.highScoreNotifier,
                              builder: (context, highScore, _) {
                                return Text(
                                  'Game Over\nScore: $score\nHigh Score: $highScore',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.orbitron(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                );
                              },
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

          /// HUD (Score + Timer + Zen pause/resume)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Score
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

                      /// Timed mode: MM:SS
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
                  if (widget.settings.mode == GameMode.zen) ...[
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
                                  });
                                },
                                child: const Text('Stop'),
                              ),
                            ],
                          )
                      ],
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}