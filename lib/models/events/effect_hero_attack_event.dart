import 'package:flutter_game_2048_fight/models/events/block_enemy_event.dart';
import 'package:flutter_game_2048_fight/models/system/block.dart';

import '../game_system.dart';
import '../system/game.dart';

class EffectHeroAttackEvent extends GameBlockEvent {
  GameSystem system;

  late int act;
  late BoardItem parent;

  // Move
  EffectHeroAttackEvent({required this.system});

  @override
  action(payload) {
    print("Effect hero attack --------- >");
    // 根据 效果的位置 去匹配 block

    reduceInjourAction(
      block: payload.block,
      act: act,
      system: system,
    );

    // check remove
    if (parent != null) {
      // turnAction
      var removeAction = GameActionData(
        target: parent.id,
        type: GameActionType.removeEffect,
      );
      system.removeEffect(parent);
      system.actions.add(removeAction);
    }

    return null;
  }
}
