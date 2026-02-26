import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';

import '../game/letter_game.dart';
import '../game/user_settings.dart';
import 'loading_screen.dart';

class GameScreen extends StatelessWidget {
  final UserSettings settings;

  const GameScreen({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    final game = LetterGame(settings: settings);

    return Scaffold(
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          final handled = game.onKeyEvent(event, const {});
          return handled ? KeyEventResult.handled : KeyEventResult.ignored;
        },
        child: Stack(
          children: [
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
                          Text(
                            'Game Over\nScore: ${g.scoreNotifier.value}\nHigh Score: ${g.highScoreNotifier.value}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: g.reset,
                                child: const Text('Restart'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () {
                                  g.overlays.remove('GameOver');
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) => LoadingScreen(
                                        settings: UserSettings(),
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
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                    if (settings.mode == GameMode.timed)
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