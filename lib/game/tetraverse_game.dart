import 'package:Tetrisverse/game/game_board.dart';
import 'package:Tetrisverse/game/gravity.dart';
import 'package:Tetrisverse/game/input_controller.dart';
import 'package:Tetrisverse/game/level_text.dart';
import 'package:Tetrisverse/game/next_block_display.dart';
import 'package:Tetrisverse/game/score_text.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class StatsPanel extends PositionComponent {
  final Component child;
  final double width;
  final double height;

  StatsPanel({
    required this.child,
    required this.width,
    required this.height,
    super.position,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(child);
  }

  @override
  void render(Canvas canvas) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, width, height),
      const Radius.circular(12),
    );

    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xAA1A1A2E), // mörk blågrå nyans med opacitet
        Color(0x661A1A2E),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawRRect(rrect, paint);

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rrect, borderPaint);

    super.render(canvas);
  }
}

class TetraverseGame extends FlameGame {
  late InputController input;
  late NextBlockDisplay nextBlockDisplay;
  late ScoreText scoreText;
  late TextComponent gameOverText;
  late LevelText levelText;
  late GameBoard board;
  final GravityManager gravity;

  TetraverseGame(this.gravity);

 @override
Future<void> onLoad() async {
  await super.onLoad();

  final double boardWidth = size.x * 0.8;
  final double boardHeight = size.y * 0.85;

  final double horizontalOffset = 25;
  final double verticalOffset = 140;

  board = GameBoard.create(gravity, Vector2(boardWidth, boardHeight))
    ..position = Vector2(
      (size.x - boardWidth) / 2 + horizontalOffset,
      (size.y - boardHeight) / 2 + verticalOffset,
    );
  add(board);

  final double blockSize = board.blockSize;
  final double smallBlockSize = blockSize * 0.6;
  final double iconSize = 50.0;
  final double spacing = 12;
  final double statsPanelHeight = blockSize * 2.5;
  final double statsPanelWidth = boardWidth;

  input = InputController(
    onMove: board.moveCurrentBlock,
    getCurrentBlockRect: board.getCurrentBlockRects,
  )
    ..size = size
    ..position = Vector2.zero();
  add(input);

  nextBlockDisplay = NextBlockDisplay(
    nextBlock: board.nextBlock,
    blockSize: smallBlockSize,
  );

  scoreText = ScoreText(
    blockSize: blockSize,
    screenSize: size,
  );

  levelText = LevelText(
    screenSize: size,
    blockSize: blockSize,
  );

  final statsContent = PositionComponent();

  await statsContent.addAll([
    nextBlockDisplay..position = Vector2(12, 12),
    SpriteComponent()
      ..sprite = await loadSprite('icons/score.png')
      ..size = Vector2.all(iconSize)
      ..position = Vector2(90, 12),
    scoreText..position = Vector2(150, 17),
    SpriteComponent()
      ..sprite = await loadSprite('icons/level.png')
      ..size = Vector2.all(iconSize)
      ..position = Vector2(200, 12),
    levelText..position = Vector2(250, 17),
  ]);

  final statsPanel = StatsPanel(
  child: statsContent,
  width: statsPanelWidth,
  height: statsPanelHeight,
  position: Vector2((size.x - statsPanelWidth) / 2, 80), // Ändrad från 30 till 80
);

  add(statsPanel);

  gameOverText = TextComponent(
    text: 'Game Over',
    textRenderer: TextPaint(
      style: TextStyle(
        color: Colors.red.withOpacity(0.0),
         fontSize: 48,
        fontWeight: FontWeight.bold,
      ),
    ),
  )
    ..anchor = Anchor.center
    ..position = size / 2;
  add(gameOverText);
}


  @override
  void update(double dt) {
    super.update(dt);

    if (board.isGameOver) {
      gameOverText.textRenderer = TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      );
      return;
    }

    board.update(dt);
    nextBlockDisplay.updateNextBlock(board.nextBlock);
    scoreText.updateScore(board.score);
    levelText.updateLevel(board.level);
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF2c3e50),
          Color(0xFF8e44ad),
          Color(0xFFe91e63),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

    canvas.drawRect(rect, paint);
    super.render(canvas);
  }
}

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Alignment> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _gradientAnimation = Tween<Alignment>(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _buttonWidth(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2c3e50),
              Color(0xFF8e44ad),
              Color(0xFFe91e63),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: AnimatedBuilder(
                    animation: _gradientAnimation,
                    builder: (context, child) {
                      return ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: const [
                            Colors.pinkAccent,
                            Colors.deepPurpleAccent,
                            Colors.cyanAccent,
                          ],
                          begin: _gradientAnimation.value,
                          end: Alignment.center,
                        ).createShader(bounds),
                        child: const Text(
                          'TETRAVERSE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                            letterSpacing: 4,
                            shadows: [
                              Shadow(
                                color: Colors.black87,
                                blurRadius: 10,
                                offset: Offset(3, 3),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 80),
                _glassButton(
                  label: 'Start Game',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GameScreen(),
                      ),
                    );
                  },
                  width: _buttonWidth(context),
                ),
                const SizedBox(height: 20),
                _glassButton(
                  label: 'How to Play',
                  onPressed: () => _showInfoDialog(
                    context,
                    'How to Play',
                    '''
Use arrow keys or swipe to move the block.

Tap the screen to rotate the piece.

Complete a full line to clear it.

Each time you clear a line, gravity reverses!
                    ''',
                  ),
                  width: _buttonWidth(context),
                ),
                const SizedBox(height: 20),
                _glassButton(
                  label: 'About',
                  onPressed: () => _showInfoDialog(
                    context,
                    'About',
                    '''
Tetraverse is a creative twist on the classic Tetris experience.

With dynamic gravity that changes direction every time you clear a line, this game challenges your spatial thinking in a whole new way.

Created by Christer Holm (CodeCraftsMan).
Visit: www.codecraftsman.se
                    ''',
                  ),
                  width: _buttonWidth(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassButton({
    required String label,
    required VoidCallback onPressed,
    required double width,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
          width: 1.5,
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF311B92),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          content,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.4,
          ),
          textAlign: TextAlign.left,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.pinkAccent,
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2c3e50),
              Color(0xFF8e44ad),
              Color(0xFFe91e63),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: GameWidget<TetraverseGame>(
          game: TetraverseGame(GravityManager()),
        ),
      ),
    );
  }
}


