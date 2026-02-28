import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flame/game.dart';
import 'package:video_player/video_player.dart';
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
  bool zenStopped = false;

  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();

    // Initialize the game
    game = LetterGame(settings: widget.settings);

    // Initialize background video
    final videoPath = widget.settings.backgroundVideo;
    if (videoPath != null) {
      _videoController = VideoPlayerController.asset(videoPath)
        ..setLooping(true)
        ..initialize().then((_) {
          setState(() {});
          _videoController!.play();
        });
    }

    // Focus keyboard after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    _videoController?.dispose();
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // 1️⃣ Video background or solid color
          if (_videoController != null && _videoController!.value.isInitialized)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            )
          else
            Container(color: widget.settings.backgroundColor),

          // 2️⃣ GameWidget (letters)
          Positioned.fill(
            child: GameWidget(
              game: game,
              backgroundBuilder: (_) => Container(color: Colors.transparent),
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
                                displayText +=
                                    '\nHigh Score: ${g.highScoreNotifier.value}';
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
                                      builder: (_) =>
                                          LoadingScreen(settings: widget.settings),
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
                },
              },
            ),
          ),

          // 3️⃣ Cloud logo on top
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
                      heightFactor: heightFactor,
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

          // 4️⃣ HUD + Zen buttons
          Positioned(
            top: screenHeight * 0.1,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Score + Timer Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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

                // Zen Pause / Resume / Stop buttons
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
                      if (zenPaused) ...[
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
                    ],
                  ),
                ],
              ],
            ),
          ),

          // 5️⃣ Invisible TextField for keyboard input
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
        ],
      ),
    );
  }
}