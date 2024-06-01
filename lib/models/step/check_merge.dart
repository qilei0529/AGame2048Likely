import 'dart:math';

import 'package:flutter_game_2048_fight/models/game_system.dart';
import 'package:flutter_game_2048_fight/models/system/block.dart';
import 'package:flutter_game_2048_fight/models/system/game.dart';
import 'package:flutter_game_2048_fight/models/util.dart';

checkMergeStep({
  // required GamePoint point,
  required BoardItem leftBlock,
  required GameSystem system,
}) {
  var vos = getBlockPosVos(blocks: system.blocks);

  List<GameActionData> tempActions = [];

  // for (var leftBlock in blocks) {
  var point = leftBlock.point;
  // 获取 block 射程范围内 是否有 对象
  var attackPoisiton = point.addPosition(leftBlock.position);

  var key = getBlockKey(attackPoisiton);
  var rightBlock = vos[key];
  if (rightBlock != null) {
    var canMerge = false;
    print("has block on ${key}");
    if (rightBlock.isDead) {
    } else if (checkBlockCanMerge(leftBlock, rightBlock)) {
      canMerge = true;
    }

    if (canMerge) {
      var level = min(rightBlock.level + 1, 3);
      if (level != rightBlock.level) {
        // turnAction
        leftBlock.isDead = true;
        var eatAction = GameActionData(
          target: leftBlock.id,
          type: GameActionType.absorbed,
        );
        tempActions.add(eatAction);
        //
        rightBlock.level = level;
        rightBlock.life += leftBlock.life;
        rightBlock.act += 1;
        var upgradeAction = GameActionData(
          target: rightBlock.id,
          type: GameActionType.upgrade,
          value: rightBlock.level,
          life: rightBlock.life,
        );
        tempActions.add(upgradeAction);
      }
    }
  }
  // }
  return tempActions;
}
