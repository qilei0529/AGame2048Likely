import 'package:flutter_game_2048_fight/models/events/block_enemy_event.dart';

import '../game_system.dart';
import '../system/game.dart';

class FloorRedEvent extends GameBlockEvent {
  GameSystem system;

  // move
  FloorRedEvent({required this.system});

  @override
  action(payload) {
    print("event floor red ------->");
    var leftBlock = payload.block;

    var block = system.getBlockAt(leftBlock.position);
    if (block != null) {
      block.life = 0;
      reduceDeadAction(block: block, system: system);

      var deadAction = GameActionData(
        target: leftBlock.id,
        type: GameActionType.removeFloor,
      );
      system.actions.add(deadAction);
    }

    return null;
  }
}
