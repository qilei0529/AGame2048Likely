import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:flutter_game_2048_fight/scenes/main_scene.dart';

void main() {
  runApp(
    GameWidget.controlled(
      gameFactory: MainScene.new, // Modify this line
    ),
  );
}
