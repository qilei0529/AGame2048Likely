import 'package:flutter_game_2048_fight/models/events/block_enemy_event.dart';
import 'package:flutter_game_2048_fight/models/system/block.dart';

import '../game_system.dart';
import '../system/game.dart';

class FloorRedEvent extends GameBlockEvent {
  GameSystem system;

  int maxCount = 2;
  int count = 2;

  int limit = 999;

  // move
  FloorRedEvent({required this.system});

  @override
  action(payload) {
    print("event floor red ------->");
    var leftBlock = payload.block;

    if (count == 0) {
      var deadAction = GameActionData(
        target: leftBlock.id,
        type: GameActionType.removeFloor,
      );
      system.removeFloor(leftBlock);
      system.actions.add(deadAction);

      return null;
    }
    var block = system.getBlockAt(leftBlock.position);
    if (block != null) {
      if (block.type == BlockType.door) {
      } else if (block.type == BlockType.hero ||
          block.type == BlockType.enemy) {
        reduceInjourAction(block: block, act: 1, system: system);
      } else {
        block.life = 0;
        reduceDeadAction(block: block, system: system);
      }

      var deadAction = GameActionData(
        target: leftBlock.id,
        type: GameActionType.removeFloor,
      );
      system.removeFloor(leftBlock);
      system.actions.add(deadAction);
    } else {}

    count -= 1;

    return null;
  }
}
