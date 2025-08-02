import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

class InputController extends PositionComponent
    with TapCallbacks, DragCallbacks {
  final void Function(String) onMove;

  Vector2? dragStart;
  bool hasMoved = false;

  InputController({required this.onMove});

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    final touchX = absoluteToLocal(event.localPosition).x;
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
    super.onDragStart(event);
    dragStart = event.localPosition;
    hasMoved = false;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (dragStart == null || hasMoved) return;

    final delta = event.localDelta;

    // Snabb drop: drop om draget går neråt > 15 pixlar
    if (delta.y > 15) {
      hasMoved = true;
      onMove('drop');
      return;
    }

    // Flytta vänster/höger om draget går horisontellt > 15 pixlar
    if (delta.x.abs() > 15) {
      hasMoved = true;
      onMove(delta.x > 0 ? 'right' : 'left');
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    dragStart = null;
    hasMoved = false;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    dragStart = null;
    hasMoved = false;
  }
}









