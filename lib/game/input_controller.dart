import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

class InputController extends PositionComponent
    with TapCallbacks, DragCallbacks {
  final void Function(String) onMove;

  Vector2? dragStart;
  bool hasMoved = false;

  InputController({
    required this.onMove,
    required List<Rect> Function() getCurrentBlockRect,
  });

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event); // <-- Viktigt!
    final touchX = absoluteToLocal(event.canvasPosition).x;
    final sectionWidth = size.x / 3;

    if (touchX < sectionWidth) {
      onMove('left');
    } else if (touchX > 2 * sectionWidth) {
      onMove('right');
    } else {
      onMove('rotate');
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event); // <-- Viktigt!
    dragStart = absoluteToLocal(event.canvasPosition);
    hasMoved = false;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event); // <-- Viktigt!
    if (dragStart == null || hasMoved) return;

    final delta = event.localDelta + (dragStart ?? Vector2.zero());

    if (delta.x.abs() > 20 && delta.y.abs() < 20) {
      hasMoved = true;
      onMove(delta.x > 0 ? 'right' : 'left');
    }

    if (delta.y > 30 && delta.x.abs() < 20) {
      hasMoved = true;
      onMove('drop');
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event); // <-- Viktigt!
    dragStart = null;
    hasMoved = false;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event); // <-- Viktigt!
    dragStart = null;
    hasMoved = false;
  }
}






