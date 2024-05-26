import 'dart:math';

import 'package:flutter_game_2048_fight/models/system/block.dart';
import 'package:flutter_game_2048_fight/models/system/board.dart';
import 'package:flutter_game_2048_fight/models/system/game.dart';
import 'package:flutter_game_2048_fight/models/util.dart';

List<GameActionData> checkAttackStep({
  // required GamePoint point,
  required List<BoardItem> blocks,
  required BoardSize size,
}) {
  var vos = getBlockPosVos(blocks: blocks);

  List<GameActionData> tempActions = [];

  for (var leftBlock in blocks) {
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
        );

        tempActions.add(attackAction);

        var rightLife = max(0, rightBlock.life - act);
        rightBlock.life = rightLife;

        var injureAction = GameActionData(
          target: rightBlock.id,
          type: GameActionType.injure,
          value: act,
          life: rightLife,
        );
        tempActions.add(injureAction);

        if (rightLife == 0) {
          rightBlock.isDead = true;
          var deadAction = GameActionData(
            target: rightBlock.id,
            type: GameActionType.dead,
          );
          tempActions.add(deadAction);

          var heal = 1;
          leftBlock.life += heal;
          var healAction = GameActionData(
            target: leftBlock.id,
            type: GameActionType.heal,
            life: leftBlock.life,
            value: heal,
          );
          tempActions.add(healAction);

          // move to target
          leftBlock.position = rightBlock.position;
          var moveAction = GameActionData(
            target: leftBlock.id,
            type: GameActionType.move,
            position: rightBlock.position,
            point: point,
          );
          tempActions.add(moveAction);
        }
      }
    }
  }
  return tempActions;
}
