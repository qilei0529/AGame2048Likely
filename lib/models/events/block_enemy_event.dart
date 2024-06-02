import 'dart:math';

import 'package:flutter_game_2048_fight/models/system/block.dart';

import '../game_system.dart';
import '../system/game.dart';
import '../util.dart';

class BlockEnemyEvent extends GameBlockEvent {
  GameSystem system;

  BlockEnemyEvent({required this.system});

  @override
  action(payload) {
    var leftBlock = payload.block;

    var vos = getBlockPosVos(blocks: system.blocks);

    List<GameActionData> tempActions = [];

    // for (var leftBlock in blocks) {
    var point = leftBlock.point;
    // 获取 block 射程范围内 是否有 对象
    var attackPoisiton = point.addPosition(leftBlock.position);

    var key = getBlockKey(attackPoisiton);
    var rightBlock = vos[key];
    if (rightBlock != null) {
      var canAttack = false;
      print("has block on ${key}");
      if (rightBlock.isDead) {
        // oh it is dead
      } else if (checkBlockCanAttack(leftBlock.type, rightBlock.type)) {
        canAttack = true;
      }

      if (canAttack) {
        // act from leftBlock
        print("leftBlock act ---- ${leftBlock.act}");
        var act = leftBlock.act;

        // turnAction
        var attackAction = GameActionData(
          target: leftBlock.id,
          type: GameActionType.attack,
          toTarget: rightBlock.id,
          value: act,
          point: leftBlock.point,
        );
        tempActions.add(attackAction);

        reduceInjourAction(
          block: rightBlock,
          act: act,
          system: system,
        );
      }
    }
    system.actions.addAll(tempActions);
    return null;
  }
}

reduceInjourAction({
  required BoardItem block,
  required int act,
  required GameSystem system,
}) {
  var life = max(0, block.life - act);

  if (block.life != life) {
    block.life = life;

    var injureAction = GameActionData(
      target: block.id,
      type: GameActionType.injure,
      value: act,
      life: life,
    );
    system.actions.add(injureAction);

    reduceDeadAction(block: block, system: system);
  }
}

reduceDeadAction({
  required BoardItem block,
  required GameSystem system,
}) {
  if (block.life == 0) {
    block.isDead = true;
    var deadAction = GameActionData(
      target: block.id,
      type: GameActionType.dead,
    );
    system.actions.add(deadAction);
  }
}
