import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Weapon extends ShapeComponent {
  Weapon(Vector2 position)
      : super(
          anchor: Anchor.center,
          position: position,
        );

  @override
  void onMount() {
    super.onMount();
    size = Vector2(3, 3);
    debugMode = true;
    debugColor = Colors.red.shade200;
  }
}
