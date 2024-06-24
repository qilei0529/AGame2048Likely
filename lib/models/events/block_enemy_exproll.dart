import 'package:flutter_game_2048_fight/models/events/block_enemy_event.dart';

import '../game_system.dart';
import '../system/game.dart';

class BlockEnemyExprollEvent extends GameBlockEvent {
  GameSystem system;

  int maxCount = 2;
  int count = 2;

  int limit = 999;

  // move
  BlockEnemyExprollEvent({required this.system});

  reset() {
    // reset
    count = maxCount;
    limit -= 1;
  }

  @override
  action(payload) {
    var leftBlock = payload.block;
    count -= 1;
    if (limit > 0 && count <= 0) {
      leftBlock.count = 0;
      var countAction = GameActionData(
        target: leftBlock.id,
        type: GameActionType.count,
        value: 0,
      );
      countAction.level = 1;
      system.actions.add(countAction);

      reduceInjourAction(
        block: leftBlock,
        act: 1,
        system: system,
      );

      reset();

      if (leftBlock.life > 0) {
        leftBlock.count = count;
        var countAction = GameActionData(
          target: leftBlock.id,
          type: GameActionType.count,
          value: count,
        );
        countAction.level = 3;
        system.actions.add(countAction);
      }
    } else {
      print("block count ------- > $count");
      // 更新 count
      leftBlock.count = count;
      var countAction = GameActionData(
        target: leftBlock.id,
        type: GameActionType.count,
        value: count,
      );
      countAction.level = 1;
      system.actions.add(countAction);
    }
    return null;
  }

  @override
  void clear() {}
}
