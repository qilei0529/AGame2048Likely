import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game_2048_fight/elements/enemy.dart';
import 'package:flutter_game_2048_fight/elements/hero.dart';
import 'package:flutter_game_2048_fight/models/board_system.dart';

class MainScene extends Forge2DGame {
  MainScene()
      : super(
          // 设置 2D 环境
          gravity: Vector2(0, 0),
          // 设置 camera
          // 游戏中的 camera 很重要
          camera: CameraComponent.withFixedResolution(width: 800, height: 600),
        );

  // 当前 已进行的 step
  late int step = 0;

  late BoardSystem system = BoardSystem(BoardSize(5, 5));

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

    print(system);
    system.vos.forEach((key, value) {
      print(key);
    });
    return super.onLoad();
  }

  slideTo(PointType point) {
    system.slideTo(point);
  }

  initControl() {
    var list = [
      {"text": "L", "top": -12, "point": PointType.left},
      {"text": "R", "top": -6, "point": PointType.right},
      {"text": "T", "top": 0, "point": PointType.top},
      {"text": "B", "top": 6, "point": PointType.bottom},
    ];

    for (var item in list) {
      var text = item["text"];
      var button = Button(text as String);
      var point = item["point"] as PointType;
      var top = item["top"] as int;
      button.position = Vector2(-35, top.toDouble());
      button.size = Vector2(5, 5);
      button.onPressed = () {
        print('on pressed $text');
        slideTo(point);
      };
      world.add(button);
    }
  }

  initGround() {
    for (var x = 1; x < 6; x += 1) {
      for (var y = 1; y < 6; y += 1) {
        var pos = getGridPositionAt(x, y);
        var block = Block(pos);
        world.add(block);
      }
    }
  }

  initHero() {
    // add
    var pos = getGridPositionAt(2, 3);
    var key = ComponentKey.named("HERO");
    var hero = HeroBlock(key, pos);
    world.add(hero);

    var block = BlockTarget("HERO", BoardPosition(2, 3), "HERO");
    block.body = hero;
    system.addBlock(block);
  }

  initEnemy() {
    for (var n = 1; n < 3; n++) {
      var pos = getGridPositionAt(4, n);
      var key = ComponentKey.named("ENEMY_$n");
      var body = EnemyBlock(key, pos);
      world.add(body);

      var block = BlockTarget("ENEMY_$n", BoardPosition(4, n), "ENEMY");
      block.life = n;
      block.body = body;
      system.addBlock(block);
    }
  }

  // get the position from int x y
  getGridPositionAt(int x, int y) {
    var width = camera.visibleWorldRect.width;
    var height = camera.visibleWorldRect.height;
    print("$width, $height");
    Vector2 offset = Vector2(width / 2 - 15, height / 2 - 5);
    var dx = 10.0 * x.toDouble() - 5 - offset.x;
    var dy = 10.0 * y.toDouble() - 5 - offset.y;
    return Vector2(dx, dy);
  }

  @override
  update(dt) {
    super.update(dt);
  }

  // @override
  // void onTapDown(int pointerId, TapDownInfo info) {
  //   print(pointerId);
  //   print(info);
  //   // lastEventDescription = _describe('TapDown', info);
  // }
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
          fontSize: 3,
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
    size = Vector2(10, 10);
    // position = this.position;
    debugMode = true;
    debugColor = Colors.green.shade200;
  }
}
