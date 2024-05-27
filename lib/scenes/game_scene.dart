import 'dart:async';

// frame
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
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

    return super.onLoad();
  }
}
