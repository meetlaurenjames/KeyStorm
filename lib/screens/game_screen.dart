import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';

import '../game/letter_game.dart';
import '../game/user_settings.dart';
import 'loading_screen.dart';

class GameScreen extends StatefulWidget {
  final UserSettings settings;

  const GameScreen({super.key, required this.settings});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final LetterGame game;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    game = LetterGame(settings: widget.settings);

    // Request focus automatically after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey.keyLabel;
      if (key.isNotEmpty) {
        game.handleKey(key); // send key to LetterGame
      }
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _onKey,
        child: Stack(
          children: [
            // GameWidget
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
                                    style: const TextStyle(
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

            // Top HUD: Score + Timer
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Score display
                    ValueListenableBuilder<int>(
                      valueListenable: game.scoreNotifier,
                      builder: (context, score, _) {
                        return Text(
                          'Score: $score',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),

                    // Timer display (only in Timed mode)
                    if (widget.settings.mode == GameMode.timed)
                      ValueListenableBuilder<int>(
                        valueListenable: game.timeNotifier,
                        builder: (context, secondsLeft, _) {
                          final Color color;
                          if (secondsLeft <= 5) {
                            color = Colors.red;
                          } else if (secondsLeft <= 10) {
                            color = Colors.yellow;
                          } else {
                            color = Colors.white;
                          }

                          return Text(
                            'Time: $secondsLeft',
                            style: TextStyle(
                              color: color,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}