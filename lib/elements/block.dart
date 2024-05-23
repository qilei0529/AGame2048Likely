import 'package:flutter/material.dart';

// frame
import 'package:flame/components.dart';
import 'package:flutter_game_2048_fight/models/system/block.dart';

// scene
import 'package:flutter_game_2048_fight/scenes/game_scene.dart';

class BlockComponent extends RectangleComponent
    with HasGameReference<TheGameScene> {
  late Color color;

  BlockComponent({
    super.key,
    super.position,
    Vector2? size,
    Color? color,
  }) {
    this.color = color ?? Colors.white60;
    super.size = size ?? Vector2(60, 60);
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
    return Vector2(300, 300);
  }
}

class BoardItemComponent extends BlockComponent with HasBoardReference {
  late BoardItem data;

  setPositionAt({required int x, required int y}) {
    var size = getBoardSize();
  }

  @override
  void onMount() {
    setColor(color);
    super.onMount();
  }
}
