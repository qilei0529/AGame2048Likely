import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

// frame
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/extensions.dart';
import 'package:flutter_game_2048_fight/models/game_system.dart';

// scene
import 'start_scene.dart';
import 'world_scene.dart';

// elements
import 'package:flutter_game_2048_fight/elements/background.dart';

// system

// component
class TheGameScene extends FlameGame {
  TheGameScene();
  late Background ground;

  late Background mask;

  GameSystem system = GameSystem();

  late XmlSpriteSheet elements;
  late XmlSpriteSheet blocks;

  goHome() async {
    world = StartScene();
  }

  gameStart() async {
    // get level data
    // var level = await loadLevel();
    // show black ground
    // showMask();
    // wait for the data ready
    await system.loadLevel("level_1");

    try {
      final [boardImage, elementImage] = await [
        images.load('sheet_board.png'),
        images.load('sheet_element.png'),
      ].wait;
      // 拆分 sprite xml 对象
      elements = XmlSpriteSheet(
        elementImage,
        await rootBundle.loadString('assets/sheets/element.xml'),
      );
      blocks = XmlSpriteSheet(
        boardImage,
        await rootBundle.loadString('assets/sheets/block.xml'),
      );
      print(elements);
      print(blocks);

      var item = elements.getSprite("element_hp");
      print(item);

      var block = blocks.getSprite("cover_hero");
      print(item);
    } catch (e) {
      print(e);
    }
    world = WorldScene(system: system);
    // show game
  }

  showMask() {
    mask = Background(color: Colors.red.shade300);
    final viewport = camera.viewport;
    viewport.add(mask);
  }

  void initBackgound() {
    ground = Background();
    add(ground);
  }

  @override
  FutureOr<void> onLoad() async {
    initBackgound();
    gameStart();
    // goHome();
    print("view port ${camera.viewport.size}");
    var size = camera.viewport.size;
    var ratio = size.x / size.y;
    var width = 400.0;
    var height = 400 / ratio;
    if (height < 800) {
      height = 800;
    }
    camera = CameraComponent.withFixedResolution(width: width, height: height);

    return super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    // need add a debonce to reload views
    print("size change: $size");
  }
}

class XmlSpriteSheet {
  XmlSpriteSheet(this.image, String xml) {
    final document = XmlDocument.parse(xml);
    for (final node in document.xpath('//TextureAtlas/SubTexture')) {
      final name = node.getAttribute('name')!;
      final x = double.parse(node.getAttribute('x')!);
      final y = double.parse(node.getAttribute('y')!);
      final width = double.parse(node.getAttribute('width')!);
      final height = double.parse(node.getAttribute('height')!);
      _rects[name] = Rect.fromLTWH(x, y, width, height);
    }
    print(_rects);
  }

  final ui.Image image;
  final _rects = <String, Rect>{};

  Sprite getSprite(String name) {
    final rect = _rects[name];
    if (rect == null) {
      throw ArgumentError('Sprite $name not found');
    }
    return Sprite(
      image,
      srcPosition: rect.topLeft.toVector2(),
      srcSize: rect.size.toVector2(),
    );
  }
}
