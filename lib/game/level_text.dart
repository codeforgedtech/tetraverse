import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LevelText extends TextComponent {
  final double blockSize;
  int level = 1;

  LevelText({
    required this.blockSize,
    required Vector2 screenSize,
  }) {
    text = '$level';

    textRenderer = TextPaint(
      style: TextStyle(
        color: Colors.white,
        fontSize: blockSize * 0.9,
        fontWeight: FontWeight.bold,
        shadows: [
          const Shadow(
            color: Colors.black54,
            offset: Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
    );

    anchor = Anchor.topLeft;
   
  }

  void updateLevel(int newLevel) {
    if (newLevel != level) {
      level = newLevel;
      text = '$level';
    }
  }
}



