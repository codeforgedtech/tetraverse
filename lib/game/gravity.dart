import 'package:flame/components.dart';

enum GravityDirection { down, up }

class GravityManager {
  GravityDirection current = GravityDirection.down;

  void changeGravity() {
    // Skapa en lista med alla möjliga riktningar förutom den nuvarande
    final directions = GravityDirection.values.where((d) => d != current).toList();
    directions.shuffle();
    current = directions.first;
    print("Gravity changed to: $current");
  }

  // Returnerar gravitationsvektor som Vector2
Vector2 getGravityVector() {
  switch (current) {
    case GravityDirection.down:
      return Vector2(0, 1);
    case GravityDirection.up:
      return Vector2(0, -1);
  }
  // Denna rad nås aldrig i praktiken men behövs för kompilatorn:
  return Vector2(0, 1);
}
}


