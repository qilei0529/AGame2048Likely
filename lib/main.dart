import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:flutter_game_2048_fight/scenes/game_scene.dart';

void main() {
  runApp(
    // ignore: prefer_const_constructors
    GameWidget.controlled(
      gameFactory: TheGameScene.new, // Modify this line
    ),
  );
}
