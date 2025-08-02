import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';

import 'gravity.dart';
import 'tetromino.dart';

class GameBoard extends PositionComponent {
  static const int rows = 16;
  static const int cols = 8;

  final double blockSize;
  final GravityManager gravity;
  bool isGameOver = false;

  late final List<List<Color?>> boardGrid;

  Tetromino? currentBlock;
  late Tetromino nextBlock;

  double fallTimer = 0;
  double fallInterval = 1.0;

  int score = 0;
  int level = 1;

  static const double minFallInterval = 0.1;
  static const double fallIntervalDecrease = 0.05;

  int lastDifficultyLevel = 0;

  List<int> blinkingRows = [];
  double blinkingTimer = 0;
  final double blinkDuration = 0.6;
  bool blinkVisible = true;
  bool isBlinking = false;

  factory GameBoard.create(GravityManager gravity, Vector2 screenSize) {
    final double maxWidth = screenSize.x * 0.8;
    final double maxHeight = screenSize.y * 0.9;
    final double blockSize = (maxWidth / cols).clamp(0, maxHeight / rows);

    return GameBoard._internal(
      blockSize,
      gravity: gravity,
      screenSize: screenSize,
    );
  }

  GameBoard._internal(this.blockSize, {
    required this.gravity,
    required Vector2 screenSize,
  }) {
    boardGrid = List.generate(rows, (_) => List<Color?>.filled(cols, null));
    nextBlock = _generateRandomBlock();
    spawnNewBlock();
    size = Vector2(cols * blockSize, rows * blockSize);
    position = Vector2(
      (screenSize.x - size.x) / 2,
      (screenSize.y - size.y) / 2,
    );
  }

  Tetromino _generateRandomBlock() {
    final types = TetrominoType.values;
    final idx = DateTime.now().millisecondsSinceEpoch % types.length;
    return Tetromino(types[idx]);
  }

  void spawnNewBlockInstance() {
    currentBlock = nextBlock;
    currentBlock!.position = Vector2((cols / 2 - 1).floorToDouble(), 0);
    nextBlock = _generateRandomBlock();

    if (!canMove(currentBlock!.position, currentBlock!.shape)) {
      isGameOver = true;
    }
  }

  List<Rect> getCurrentBlockRects() {
    if (currentBlock == null) return [];

    final pos = currentBlock!.position;
    final shape = currentBlock!.shape;
    final rects = <Rect>[];

    for (int y = 0; y < shape.length; y++) {
      for (int x = 0; x < shape[y].length; x++) {
        if (shape[y][x] == 1) {
          rects.add(Rect.fromLTWH(
            (pos.x + x) * blockSize,
            (pos.y + y) * blockSize,
            blockSize,
            blockSize,
          ));
        }
      }
    }
    return rects;
  }

  void spawnNewBlock() {
    currentBlock = nextBlock;
    currentBlock!.position = Vector2((cols / 2 - 1).floorToDouble(), 0);
    nextBlock = _generateRandomBlock();

    if (!canMove(currentBlock!.position, currentBlock!.shape)) {
      isGameOver = true;
    }
  }

  void updateRotationFromGravity() {
    if (gravity.current == GravityDirection.up) {
      angle = pi;
      anchor = Anchor.center;
    } else {
      angle = 0;
      anchor = Anchor.topLeft;
    }
  }

  bool canMove(Vector2 newPos, List<List<int>> shape) {
    for (int y = 0; y < shape.length; y++) {
      for (int x = 0; x < shape[y].length; x++) {
        if (shape[y][x] == 0) continue;

        int boardX = (newPos.x + x).toInt();
        int boardY = (newPos.y + y).toInt();

        if (!_isInsideBoard(boardX, boardY)) return false;
        if (boardGrid[boardY][boardX] != null) return false;
      }
    }
    return true;
  }

  bool _isInsideBoard(int x, int y) {
    return x >= 0 && x < cols && y >= 0 && y < rows;
  }

  void lockBlock() {
    if (currentBlock == null || isBlinking) return;

    FlameAudio.play('block_land.ogg');

    _placeBlockOnBoard();
    _applyBlockEffect(currentBlock!);

    blinkingRows = _getFullRows();

    if (blinkingRows.isNotEmpty) {
      isBlinking = true;
      blinkingTimer = 0;
      blinkVisible = true;
    } else {
      spawnNewBlock();
    }
  }

  List<int> _getFullRows() {
    List<int> rowsToClear = [];
    for (int y = rows - 1; y >= 0; y--) {
      if (boardGrid[y].every((cell) => cell != null)) {
        rowsToClear.add(y);
      }
    }
    return rowsToClear;
  }

  void _clearBlinkingRows() {
    int linesCleared = blinkingRows.length;
    for (int row in blinkingRows) {
      boardGrid.removeAt(row);
      boardGrid.insert(0, List<Color?>.filled(cols, null));
    }

    switch (linesCleared) {
      case 1:
      case 2:
      case 3:
        FlameAudio.play('line_clear.mp3');
        break;
      case 4:
        FlameAudio.play('tetris_clear.mp3');
        break;
    }

    _updateScore(linesCleared);
    blinkingRows.clear();
    isBlinking = false;
    spawnNewBlock();
  }

  void _placeBlockOnBoard() {
    final pos = currentBlock!.position;
    final shape = currentBlock!.shape;

    for (int y = 0; y < shape.length; y++) {
      for (int x = 0; x < shape[y].length; x++) {
        if (shape[y][x] == 1) {
          int boardX = (pos.x + x).toInt();
          int boardY = (pos.y + y).toInt();

          if (_isInsideBoard(boardX, boardY)) {
            boardGrid[boardY][boardX] = currentBlock!.color;
          }
        }
      }
    }
  }

  void _applyBlockEffect(Tetromino block) {
    switch (block.effect) {
      case BlockEffect.clearRow:
        _clearRow(block.position.y.toInt());
        break;
      case BlockEffect.clearColumn:
        _clearColumn(block.position.x.toInt());
        break;
      case BlockEffect.clearArea:
        _clearArea(block.position);
        break;
      case BlockEffect.none:
        break;
    }
  }

  void _clearRow(int row) {
    if (!_isInsideBoard(0, row)) return;
    boardGrid[row] = List<Color?>.filled(cols, null);
  }

  void _clearColumn(int col) {
    if (!_isInsideBoard(col, 0)) return;
    for (int y = 0; y < rows; y++) {
      boardGrid[y][col] = null;
    }
  }

  void _clearArea(Vector2 center, {int radius = 1}) {
    int cx = center.x.toInt();
    int cy = center.y.toInt();

    for (int y = cy - radius; y <= cy + radius; y++) {
      for (int x = cx - radius; x <= cx + radius; x++) {
        if (_isInsideBoard(x, y)) {
          boardGrid[y][x] = null;
        }
      }
    }
  }

  int clearLines() => 0;

  void _updateScore(int linesCleared) {
    if (linesCleared <= 0) return;
    score += 10 * linesCleared * linesCleared;
    level = (score ~/ 100) + 1;
  }

  void _updateDifficulty() {
    int difficultyLevel = score ~/ 100;

    if (difficultyLevel > lastDifficultyLevel) {
      fallInterval = (0.5 - (level - 1) * 0.05).clamp(minFallInterval, 0.5);
      lastDifficultyLevel = difficultyLevel;
    }
  }

  void moveCurrentBlock(String action) {
    if (currentBlock == null) return;

    Vector2 pos = currentBlock!.position;
    List<List<int>> shape = currentBlock!.shape;

    if (gravity.current == GravityDirection.up) {
      if (action == 'left') action = 'right';
      else if (action == 'right') action = 'left';
    }

    switch (action) {
      case 'left':
        _tryMoveBlock(Vector2(pos.x - 1, pos.y), shape);
        break;
      case 'right':
        _tryMoveBlock(Vector2(pos.x + 1, pos.y), shape);
        break;
      case 'rotate':
        _tryRotateBlock();
        break;
      default:
        break;
    }
  }

  void moveCurrentBlockInDirection(Vector2 direction) {
    if (currentBlock == null) return;

    Vector2 newPos = currentBlock!.position + direction;
    if (canMove(newPos, currentBlock!.shape)) {
      currentBlock!.position = newPos;
    } else {
      lockBlock();
    }
  }

  void _tryMoveBlock(Vector2 newPos, List<List<int>> shape, {bool lockIfFail = false}) {
    if (canMove(newPos, shape)) {
      currentBlock!.position = newPos;
    } else if (lockIfFail) {
      lockBlock();
    }
  }

  void _tryRotateBlock() {
    if (currentBlock == null) return;

    currentBlock!.rotate();
    if (!canMove(currentBlock!.position, currentBlock!.shape)) {
      for (int i = 0; i < 3; i++) currentBlock!.rotate();
    }
  }

  @override
  void update(double dt) {
    if (isGameOver) return;

    super.update(dt);
    _updateDifficulty();

    if (isBlinking) {
      blinkingTimer += dt;
      if ((blinkingTimer * 10).floor() % 2 == 0) {
        blinkVisible = true;
      } else {
        blinkVisible = false;
      }

      if (blinkingTimer >= blinkDuration) {
        _clearBlinkingRows();
      }
      return;
    }

    fallTimer += dt;
    if (fallTimer >= fallInterval) {
      fallTimer = 0;
      Vector2 gravityVec = gravity.getGravityVector();
      moveCurrentBlockInDirection(gravityVec);
    }
  }

  @override
  void render(Canvas canvas) {
    _drawBackground(canvas);
    _drawGlowAroundBoard(canvas);
    _drawGrid(canvas);
    _drawLockedBlocks(canvas);
    _drawCurrentBlock(canvas);
  }

  void _drawLockedBlocks(Canvas canvas) {
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        final color = boardGrid[y][x];
        bool isBlinkingRow = blinkingRows.contains(y);
        if (color != null && (!isBlinkingRow || blinkVisible)) {
          _drawBlock(canvas, x * blockSize, y * blockSize, color);
        }
      }
    }
  }
    void _drawCurrentBlock(Canvas canvas) {
    if (currentBlock == null) return;

    final pos = currentBlock!.position;
    final shape = currentBlock!.shape;
    final color = currentBlock!.color;

    for (int y = 0; y < shape.length; y++) {
      for (int x = 0; x < shape[y].length; x++) {
        if (shape[y][x] == 1) {
          _drawBlock(
            canvas,
            (pos.x + x) * blockSize,
            (pos.y + y) * blockSize,
            color,
          );
        }
      }
    }
  }

 void _drawBlock(Canvas canvas, double x, double y, Color color) {
  final rect = Rect.fromLTWH(x, y, blockSize, blockSize);
  final paint = Paint()
    ..shader = LinearGradient(
      colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(rect);
  canvas.drawRect(rect, paint);

  final border = Paint()
    ..color = Colors.black.withOpacity(0.5)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;
  canvas.drawRect(rect, border);
}

  void _drawGrid(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= cols; i++) {
      double x = i * blockSize;
      canvas.drawLine(Offset(x, 0), Offset(x, rows * blockSize), paint);
    }
    for (int i = 0; i <= rows; i++) {
      double y = i * blockSize;
      canvas.drawLine(Offset(0, y), Offset(cols * blockSize, y), paint);
    }
  }

void _drawBackground(Canvas canvas) {
  final rect = Rect.fromLTWH(0, 0, size.x, size.y);
  final paint = Paint()..color = const Color(0xFF1C2A5E);
  canvas.drawRect(rect, paint);
}

void _drawGlowAroundBoard(Canvas canvas) {
  final rect = Rect.fromLTWH(0, 0, size.x, size.y);
  final paint = Paint()
    ..shader = RadialGradient(
      colors: [
        Colors.blueAccent.withOpacity(0.12), // Synligt blått glow
        Colors.transparent,
      ],
      center: Alignment.center,
      radius: 1.5,
    ).createShader(rect);
  canvas.drawRect(rect, paint);
}
}











