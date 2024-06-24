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

    // for (var leftBlock in blocks) {
    var point = leftBlock.point;
    // 获取 block 射程范围内 是否有 对象
    var attackPoisiton = point.addPosition(leftBlock.position);

    var key = getBlockKey(attackPoisiton);
    var rightBlock = vos[key];
    if (rightBlock != null) {
      var canAttack = false;
      if (rightBlock.isDead) {
        // oh it is dead
      } else if (checkBlockCanAttack(leftBlock.type, rightBlock.type)) {
        // move must above 0 then can attack
        if (leftBlock.move > 0) {
          canAttack = true;
        }
      }

      if (canAttack) {
        reduceAttackEffect(block: leftBlock, system: system);
        return true;
      }
    }
    return null;
  }
}

reduceInjourAction({
  required BoardItem block,
  required int act,
  required GameSystem system,
  BoardItem? fromBlock,
}) {
  // injour from left to right
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

    reduceDeadAction(
      block: block,
      system: system,
      formBlock: fromBlock,
    );
  }
}

reduceDeadAction({
  required BoardItem block,
  required GameSystem system,
  BoardItem? formBlock,
}) {
  if (block.life == 0) {
    block.isDead = true;
    var deadAction = GameActionData(
      target: block.id,
      type: GameActionType.dead,
    );
    system.actions.add(deadAction);
    var events =
        block.events.where((event) => event.type == GameEventType.dead);
    // 获取 当前 block dead event
    if (events.isNotEmpty) {
      for (var event in events) {
        var payload = GameBlockPayload(block);
        payload.fromBlock = formBlock;
        event.action(payload);
      }
    }
  }
}

reduceAttackEffect({
  required BoardItem block,
  required GameSystem system,
  int? act,
}) {
  var events =
      block.events.where((event) => event.type == GameEventType.attack);
  // 获取 当前 block 的attack event
  if (events.isNotEmpty) {
    for (var event in events) {
      event.action(GameBlockPayload(block));
    }
  }
  // 处理 attack event
}
