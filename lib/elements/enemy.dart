import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game_2048_fight/elements/board_component.dart';

class EnemyBlock extends BoardComponent {
  EnemyBlock(ComponentKey key, Vector2 position)
      : super(
          key: key,
          position: position,
        );

  @override
  void onMount() {
    super.onMount();
    debugColor = Colors.orange.shade200;
  }
}
