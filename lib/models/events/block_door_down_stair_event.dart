import 'package:flutter_game_2048_fight/models/util.dart';

import '../game_system.dart';
import '../system/game.dart';

class BlockDownStireEvent extends GameBlockEvent {
  GameSystem system;

  // move
  BlockDownStireEvent({required this.system});

  @override
  action(payload) {
    // print
    // 判断当前位置 是否有 hero
    var hero = system.hero;
    if (hero != null) {
      var rightBlock = payload.block;
      if (isEqualPosition(hero.position, rightBlock.position)) {
        // 触发 hero enter 事件
        var enterAction = GameActionData(
          target: hero.id,
          type: GameActionType.enter,
        );
        system.actions.addAll([enterAction]);
      }
    }
    return null;
  }
}
