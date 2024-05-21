import 'dart:async';

import 'package:flutter/material.dart';

// frame
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
// import 'package:flame_forge2d/flame_forge2d.dart';

// system
import 'package:flutter_game_2048_fight/models/board_system.dart';

// component
import 'package:flutter_game_2048_fight/elements/enemy.dart';
import 'package:flutter_game_2048_fight/elements/hero.dart';

class MainScene extends FlameGame {
  MainScene()
      : super(
        // 设置 2D 环境
        // gravity: Vector2(0, 0),
        // 设置 camera
        // 游戏中的 camera 很重要
        // camera: CameraComponent.withFixedResolution(width: 800, height: 600),
        );

  // 当前 已进行的 step
  late int step = 0;

  late BoardSystem system = BoardSystem(BoardSize(5, 5));

  late Ground _ground;

  @override
  FutureOr<void> onLoad() async {
    print('main scene');

    // 添加
    // 添加 场景 block
    initGround();
    // 获取 数据
    // 加载 位置 block
    initHero();
    initEnemy();
    // 监听 操作

    initControl();

    return super.onLoad();
  }

  slideTo(PointType point) {
    system.slideTo(point);
  }

  initControl() {
    var control = ControlArea(Vector2(0, 200), Vector2(320, 160));
    world.add(control);

    var list = [
      {"text": "L", "top": -160, "point": PointType.left},
      {"text": "R", "top": -80, "point": PointType.right},
      {"text": "T", "top": 0, "point": PointType.top},
      {"text": "B", "top": 80, "point": PointType.bottom},
    ];

    for (var item in list) {
      var text = item["text"];
      var button = Button(text as String);
      var point = item["point"] as PointType;
      var top = item["top"] as int;
      button.position = Vector2(170 + top.toDouble(), 50);
      button.size = Vector2(60, 60);
      button.onPressed = () {
        print('on pressed $text');
        slideTo(point);
      };
      control.add(button);
    }
    control.debugMode = true;
  }

  initGround() {
    _ground = Ground(Vector2(0, -80));
    world.add(_ground);

    _ground.debugMode = true;

    for (var x = 1; x < 6; x += 1) {
      for (var y = 1; y < 6; y += 1) {
        var pos = getGroundPositionAt(x, y);
        var block = Block(pos);
        _ground.add(block);
      }
    }
  }

  initHero() {
    // add
    var pos = BoardPosition(2, 3);
    var block = BlockTarget("HERO", pos, "HERO");
    var key = ComponentKey.named("HERO");

    var hero = HeroBlock(key, getGroundPositionAt(pos.x, pos.y));
    hero.life.text = "${block.life}";
    block.body = hero;
    _ground.add(hero);

    system.addBlock(block);
  }

  initEnemy() {
    for (var n = 1; n < 3; n++) {
      var pos = BoardPosition(4, n);
      var block = BlockTarget("ENEMY_$n", pos, "ENEMY");
      block.life = n;

      var key = ComponentKey.named("ENEMY_$n");
      var enemy = EnemyBlock(key, getGroundPositionAt(pos.x, pos.y));
      _ground.add(enemy);

      enemy.life.text = "${block.life}";
      block.body = enemy;

      system.addBlock(block);
    }
  }

  // get the position from int x y
  getGroundPositionAt(int x, int y) {
    var width = 300;
    var height = 300;
    print("$width, $height");
    var dx = 60.0 * x.toDouble() - 30;
    var dy = 60.0 * y.toDouble() - 30;
    return Vector2(dx, dy);
  }

  // get the position from int x y
  getGridPositionAt(int x, int y) {
    var width = camera.visibleWorldRect.width;
    var height = camera.visibleWorldRect.height;
    print("$width, $height");
    Vector2 offset = Vector2(width / 2, height / 2);
    var dx = 60.0 * x.toDouble() - 5 - offset.x;
    var dy = 60.0 * y.toDouble() - 5 - offset.y;
    return Vector2(dx, dy);
  }
}

class Button extends AdvancedButtonComponent {
  String text;

  Button(this.text);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    defaultLabel = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 32,
          color: BasicPalette.red.color,
        ),
      ),
    );

    defaultSkin = RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 200, 0, 1));

    hoverSkin = RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 180, 0, 1));

    downSkin = RoundedRectComponent()
      ..setColor(const Color.fromRGBO(0, 100, 0, 1));
  }
}

class RoundedRectComponent extends PositionComponent with HasPaint {
  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        0,
        0,
        width,
        height,
        topLeft: Radius.circular(height),
        topRight: Radius.circular(height),
        bottomRight: Radius.circular(height),
        bottomLeft: Radius.circular(height),
      ),
      paint,
    );
  }
}

class Block extends ShapeComponent {
  Block(Vector2 position)
      : super(
          anchor: Anchor.center,
          position: position,
        );

  @override
  void onMount() {
    super.onMount();
    size = Vector2(60, 60);
    debugColor = Colors.black;
  }
}

class Ground extends ShapeComponent {
  Ground(Vector2 position)
      : super(
          anchor: Anchor.center,
          position: position,
        );

  @override
  void onMount() {
    super.onMount();
    size = Vector2.all(300);
    debugMode = true;
    debugColor = Colors.pink.shade300;
  }
}

class ControlArea extends ShapeComponent {
  ControlArea(Vector2 position, Vector2 size)
      : super(
          anchor: Anchor.center,
          position: position,
          size: size,
        );

  @override
  void onMount() {
    super.onMount();
    debugColor = Colors.pink.shade300;
  }
}
