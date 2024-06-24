import 'package:flutter/material.dart';

// frame
import 'package:flame/components.dart';
import 'package:flutter_game_2048_fight/models/system/game.dart';
import 'package:flutter_game_2048_fight/models/util.dart';

// scene
import 'package:flutter_game_2048_fight/scenes/game_scene.dart';

class BlockComponent extends RectangleComponent
    with HasGameReference<TheGameScene> {
  late Color color;

  late GamePoint point;

  BlockComponent({
    super.key,
    super.position,
    Vector2? size,
    Color? color,
    int? life,
    GamePoint? point,
  }) {
    this.color = color ?? Colors.white60;
    super.size = size ?? Vector2(50, 50);
    super.anchor = Anchor.center;
  }

  @override
  void onMount() {
    setColor(color);
    super.onMount();
  }
}

mixin HasBoardReference on BlockComponent {
  RectangleComponent get board => parent! as RectangleComponent;

  Vector2 getBoardSize() {
    return globalBoardSize;
  }
}
