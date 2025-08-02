import 'dart:ui';

import 'package:flame/components.dart';

enum TetrominoType { I, O, T, S, Z, J, L, P,Y, MiniLine, Dote }

enum BlockEffect {
  none,
  clearRow,
  clearColumn,
  clearArea,
}

class Tetromino {
  TetrominoType type;
  BlockEffect effect;
  List<List<int>> shape; // 2D-matris som beskriver blocket, 1 = block, 0 = tomt
  Vector2 position; // aktuell position i spelrutan (kol, rad)
  Color color; // 👈 Ny egenskap för färg

  Tetromino(this.type)
      : position = Vector2(3, 0),
        effect = _getEffect(type),
        shape = _getShape(type),
        color = _getColor(type); // 👈 Sätt färg baserat på typ

  static BlockEffect _getEffect(TetrominoType type) {
    switch (type) {
      case TetrominoType.P:
        return BlockEffect.clearArea;
      case TetrominoType.MiniLine:
        return BlockEffect.clearRow;
      case TetrominoType.Dote:
        return BlockEffect.clearColumn;
      default:
        return BlockEffect.none;
    }
  }

  static Color _getColor(TetrominoType type) {
    switch (type) {
      case TetrominoType.I:
        return const Color(0xFF00FFFF); // Cyan
      case TetrominoType.O:
        return const Color(0xFFFFFF00); // Gul
      case TetrominoType.T:
        return const Color(0xFF800080); // Lila
      case TetrominoType.S:
        return const Color(0xFF00FF00); // Grön
      case TetrominoType.Z:
        return const Color(0xFFFF0000); // Röd
      case TetrominoType.J:
        return const Color(0xFF0000FF); // Blå
      case TetrominoType.L:
        return const Color(0xFFFFA500); // Orange
      case TetrominoType.P:
        return const Color(0xFFFF69B4); // Rosa (special)
      case TetrominoType.MiniLine:
        return const Color(0xFFB0E0E6); // Ljusblå (special)
      case TetrominoType.Dote:
        return const Color(0xFFADFF2F); // Lime (special)
      default:
        return const Color(0xFFFFFFFF); // Vit (fallback)
    }
  }

  void rotate() {
    final n = shape.length;
    List<List<int>> rotated = List.generate(n, (_) => List<int>.filled(n, 0), growable: false);

    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        rotated[j][n - 1 - i] = shape[i][j];
      }
    }
    shape = rotated;
  }

  static List<List<int>> _getShape(TetrominoType type) {
    switch (type) {
      case TetrominoType.I:
        return [
          [0, 0, 0, 0],
          [1, 1, 1, 1],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ];
      case TetrominoType.O:
        return [
          [1, 1],
          [1, 1],
        ];
      case TetrominoType.T:
        return [
          [0, 1, 0],
          [1, 1, 1],
          [0, 0, 0],
        ];
      case TetrominoType.S:
        return [
          [0, 1, 1],
          [1, 1, 0],
          [0, 0, 0],
        ];
      case TetrominoType.Z:
        return [
          [1, 1, 0],
          [0, 1, 1],
          [0, 0, 0],
        ];
      case TetrominoType.J:
        return [
          [1, 0, 0],
          [1, 1, 1],
          [0, 0, 0],
        ];
      case TetrominoType.L:
        return [
          [0, 0, 1],
          [1, 1, 1],
          [0, 0, 0],
        ];
      case TetrominoType.P:
        return [
          [0, 1, 0],
          [1, 1, 1],
          [0, 1, 0],
        ];
      case TetrominoType.MiniLine:
        return [
          [1, 1, 1],
          [0, 0, 0],
          [0, 0, 0],
        ];
      case TetrominoType.Dote:
        return [
          [0, 1, 0],
          [0, 1, 0],
          [0, 0, 0],
        ];
        case TetrominoType.Y:
        return [
          [1],];
          
    }
  }
}
