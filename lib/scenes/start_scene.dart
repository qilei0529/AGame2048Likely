import 'dart:async';

// frame
import 'package:flame/components.dart';

// scene
import 'package:flutter_game_2048_fight/scenes/game_scene.dart';

// elements
import 'package:flutter_game_2048_fight/elements/button.dart';

class StartScene extends World with HasGameReference<TheGameScene> {
  StartScene();

  @override
  FutureOr<void> onLoad() {
    var button = Button(
      text: "Start Game",
      size: Vector2(180, 40),
      position: Vector2(0, 40),
      onPressed: () {
        // trigger start
        game.gameStart();
      },
    );
    add(button);
    return super.onLoad();
  }
}
