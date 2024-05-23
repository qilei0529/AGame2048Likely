import 'dart:async';

import 'package:flame/effects.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

// frame
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';

// system
import 'package:flutter_game_2048_fight/models/board_system.dart';

// component
import 'package:flutter_game_2048_fight/elements/enemy.dart';
import 'package:flutter_game_2048_fight/elements/hero.dart';
import 'package:flutter_game_2048_fight/scenes/main_scene.dart';

class LevelScene extends FlameGame {
  LevelScene()
      : super(
          // 设置 2D 环境
          // gravity: Vector2(0, 0),
          // 设置 camera
          // 游戏中的 camera 很重要
          // camera: CameraComponent.withFixedResolution(width: 800, height: 600),
          world: Level(1),
        );

  // 当前 已进行的 step
  late int step = 0;

  late BoardSystem system = BoardSystem(BoardSize(5, 5));

  late bool isStart = true;

  late final TextComponent header;

  @override
  FutureOr<void> onLoad() async {
    print('level scene');
    // header = TextComponent(
    //   text: 'test',
    //   position: Vector2(size.x / 2, 50),
    //   anchor: Anchor.center,
    // );

    // final viewport = camera.viewport;
    // viewport.add(header);

    return super.onLoad();
  }
}

class Level extends World with HasGameReference<LevelScene> {
  int level;

  Level(this.level);

  @override
  FutureOr<void> onLoad() {
    // TODO: implement onLoad
    print("hello");

    var button = Button("level: $level");
    add(button);

    var size = game.size;
    var nextLevel = level + 1;
    if (nextLevel > 3) {
      nextLevel = 1;
    }
    var a = LevelButton(
      'Go Level $nextLevel',
      onPressed: () {
        game.world = Level(nextLevel);
      },
      position: Vector2(0, 40),
    );

    add(a);

    // add(TextComponent("hello"));
    return super.onLoad();
  }
}

class LevelButton extends ButtonComponent {
  LevelButton(String text, {super.onPressed, super.position})
      : super(
          button: ButtonBackground(Colors.white),
          buttonDown: ButtonBackground(Colors.orangeAccent),
          children: [
            TextComponent(
              text: text,
              position: Vector2(60, 20),
              anchor: Anchor.center,
            ),
          ],
          size: Vector2(120, 40),
          anchor: Anchor.center,
        );
}

class ButtonBackground extends PositionComponent with HasAncestor<LevelButton> {
  ButtonBackground(Color color) {
    _paint.color = color;
  }

  @override
  void onMount() {
    super.onMount();
    size = ancestor.size;
  }

  late final _background = RRect.fromRectAndRadius(
    size.toRect(),
    const Radius.circular(5),
  );
  final _paint = Paint()..style = PaintingStyle.stroke;

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(_background, _paint);
  }
}
