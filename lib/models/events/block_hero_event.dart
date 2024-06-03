import 'dart:math';

import 'package:flutter_game_2048_fight/models/events/block_enemy_event.dart';

import '../game_system.dart';
import '../system/block.dart';
import '../system/game.dart';
import '../util.dart';

class BlockHeroEvent extends GameBlockEvent {
  GameSystem system;

  // move
  BlockHeroEvent({required this.system});

  @override
  action(payload) {
    var leftBlock = payload.block;
    List<GameActionData> tempActions = [];
    if (leftBlock.type != BlockType.hero) {
      return false;
    }
    var point = leftBlock.point;
    // 获取 block 射程范围内 是否有 对象
    var attackPoisiton = point.addPosition(leftBlock.position);

    var vos = getBlockPosVos(blocks: system.blocks);

    var key = getBlockKey(attackPoisiton);
    BoardItem? rightBlock = vos[key];
    if (rightBlock != null) {
      // only check eneny
      if (rightBlock.type != BlockType.enemy) {
        return false;
      }

      var canAttack = false;
      // ignore: avoid_print
      print("has block on $key");
      if (rightBlock.isDead) {
        // oh it is dead
        // only reduce hero check
      } else if (checkBlockCanAttack(leftBlock.type, rightBlock.type)) {
        // move must above 0 then can attack
        if (leftBlock.move > 0) {
          canAttack = true;
        }
      }

      if (canAttack) {
        // 判断 当前 游戏还有多少 act
        var act = system.act;
        if (act <= 0) {
          // 如果没有 攻击力了 则用基础攻击力
          act = leftBlock.act;
        } else {
          // 每次攻击少一点
          system.act = max(act - 1, 0);
        }

        // turnAction
        var attackAction = GameActionData(
          target: leftBlock.id,
          type: GameActionType.attack,
          toTarget: rightBlock.id,
          value: act,
        );

        tempActions.add(attackAction);

        reduceInjourAction(
          block: rightBlock,
          act: act,
          system: system,
        );

        system.actions.addAll(tempActions);
        return true;
      }
    }
    return null;
  }
}
