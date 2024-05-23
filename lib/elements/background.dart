import 'package:flutter/material.dart';

// frame
import 'package:flame/components.dart';

// scene
import 'package:flutter_game_2048_fight/scenes/game_scene.dart';

class Background extends RectangleComponent
    with HasGameReference<TheGameScene> {
  late Color color;

  Background({
    super.position,
    super.size,
    Color? color,
  }) {
    this.color = color ?? Colors.white60;
    super.anchor = Anchor.center;
  }
  @override
  void onMount() {
    var bg = RectangleComponent();
    bg.setColor(color);
    var size = game.camera.visibleWorldRect;
    bg.size = Vector2(size.width, size.height);
    add(bg);
    super.onMount();
  }
}
