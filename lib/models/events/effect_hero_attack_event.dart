import 'dart:math';

import 'package:flutter_game_2048_fight/models/events/block_enemy_event.dart';
import 'package:flutter_game_2048_fight/models/system/block.dart';

import '../game_system.dart';
import '../system/game.dart';

class EffectHeroAttackEvent extends GameBlockEvent {
  GameSystem system;

  late int act;
  late BoardItem parent;

  // Move
  EffectHeroAttackEvent({required this.system}) {
    // 是有 攻击的时候有效
    type = GameEventType.attack;
  }

  @override
  action(payload) {
    print("Effect hero attack --------- >");
    // 根据 效果的位置 去匹配 block
    var leftBlock = payload.block;

    // 获取 block 射程范围内 是否有 对象;
    var attackAction = GameActionData(
      target: leftBlock.id,
      type: GameActionType.attack,
      value: 1,
    );
    system.actions.add(attackAction);

    // 获取攻击
    var act = system.act;
    if (act <= 0) {
      // 如果没有 攻击力了 则用基础攻击力
      act = leftBlock.act;
    } else {
      // 每次攻击少一点
      // TODO 可以 变成 event 推送
      system.act = max(act - 1, 0);

      var actAction = GameActionData(
        target: leftBlock.id,
        type: GameActionType.healACT,
        value: system.act > 0 ? system.act : leftBlock.act,
      );
      system.actions.add(actAction);
    }

    var point = leftBlock.point;
    var attackPoisiton = point.addPosition(leftBlock.position);
    var rightBlock = system.getBlockAt(attackPoisiton);

    if (rightBlock != null) {
      reduceInjourAction(
        block: rightBlock,
        act: act,
        system: system,
        fromBlock: leftBlock,
      );
    }

    return null;
  }
}
