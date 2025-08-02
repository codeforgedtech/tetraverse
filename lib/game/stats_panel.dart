import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image;
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
    const Radius.circular(20),
  );

  // Mörkare glassmorfism bakgrund
  final paint = Paint()
    ..shader = const LinearGradient(
      colors: [
        Color(0xAA1A1A2E), // mörk blågrå nyans med opacitet
        Color(0x661A1A2E),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, width, height))
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

  canvas.drawRRect(rrect, paint);

  // Inre border
  final borderPaint = Paint()
    ..color = Colors.white.withOpacity(0.2)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;
  canvas.drawRRect(rrect, borderPaint);

  super.render(canvas);
}
}