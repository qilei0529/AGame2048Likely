import 'package:flutter_game_2048_fight/models/events/block_enemy_event.dart';
import 'package:flutter_game_2048_fight/models/system/block.dart';

import '../game_system.dart';
import '../system/game.dart';

class EffectEnemyDeadEvent extends GameBlockEvent {
  GameSystem system;

  late int act;
  late BoardItem parent;

  // Move
  EffectEnemyDeadEvent({required this.system}) {
    // 是有 攻击的时候有效
    type = GameEventType.dead;
  }

  @override
  action(payload) {
    // 死亡的时候 给 谁大它 1点伤害。
    var fromBlock = payload.fromBlock;
    if (fromBlock != null) {
      // when hero kill then heal 1
      // else loose heal
      if (fromBlock.type == BlockType.hero) {
        var heal = 1;
        fromBlock.life += heal;
        var healAction = GameActionData(
          target: fromBlock.id,
          type: GameActionType.healHP,
          life: fromBlock.life,
          value: heal,
        );
        system.actions.add(healAction);
      } else {
        reduceInjourAction(
          block: fromBlock,
          act: 1,
          system: system,
        );
      }
    }

    return null;
  }
}
