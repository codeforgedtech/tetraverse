import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'tetromino.dart';

class NextBlockDisplay extends PositionComponent {
  final double blockSize;
  Tetromino nextBlock;

  NextBlockDisplay({
    required this.nextBlock,
    required this.blockSize,
  }) {
    // Mindre visningsyta men behåller 5x5 grid
    final double scaleFactor = 0.5; // Justera mellan 0.5 - 0.8 för olika storlek
    size = Vector2(blockSize * 5 * scaleFactor, blockSize * 5 * scaleFactor);
  }

  void updateNextBlock(Tetromino newBlock) {
    nextBlock = newBlock;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final double width = size.x;
    final double height = size.y;

    final backgroundPaint = Paint()..color = const Color(0xFF1565C0);
    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, width, height),
      const Radius.circular(8),
    );
    canvas.drawRRect(backgroundRect, backgroundPaint);

    final shape = nextBlock.shape;
    final blockColor = nextBlock.color;

    final int shapeWidth = shape[0].length;
    final int shapeHeight = shape.length;

    final double cellSize = size.x / 5; // Ny blockstorlek baserat på komponentens storlek

    final double offsetX = (width - shapeWidth * cellSize) / 2;
    final double offsetY = (height - shapeHeight * cellSize) / 2;

    for (int y = 0; y < shapeHeight; y++) {
      for (int x = 0; x < shapeWidth; x++) {
        if (shape[y][x] == 1) {
          final double drawX = offsetX + x * cellSize;
          final double drawY = offsetY + y * cellSize;
          final rect = Rect.fromLTWH(drawX, drawY, cellSize, cellSize);
          final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3));

          canvas.drawShadow(
            Path()..addRRect(rrect),
            Colors.black.withOpacity(0.5),
            4,
            true,
          );

          final fillPaint = Paint()
            ..shader = LinearGradient(
              colors: [
                blockColor.withOpacity(0.85),
                blockColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(rect);

          canvas.drawRRect(rrect, fillPaint);

          final borderPaint = Paint()
            ..color = blockColor.withOpacity(0.9)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2;

          canvas.drawRRect(rrect, borderPaint);
        }
      }
    }
  }
}

