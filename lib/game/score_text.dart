import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ScoreText extends TextComponent {
  final double blockSize;
  int score = 0;

  ScoreText({
    required this.blockSize,
    required Vector2 screenSize,
  }) {
    text = '$score';

    textRenderer = TextPaint(
      style: TextStyle(
        color: Colors.white,
        fontSize: blockSize * 0.9,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            offset: const Offset(2, 2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.5),
          ),
        ],
      ),
    );

    anchor = Anchor.topLeft;
    
  }

  void updateScore(int newScore) {
    if (newScore != score) {
      score = newScore;
      text = '$score';
    }
  }
}










