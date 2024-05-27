import 'dart:math';

import 'package:flutter_game_2048_fight/models/game_system.dart';
import 'package:flutter_game_2048_fight/models/system/block.dart';
import 'package:flutter_game_2048_fight/models/system/game.dart';
import 'package:flutter_game_2048_fight/models/util.dart';

List<GameActionData> checkHeroStep({
  required BoardItem leftBlock,
  required GameSystem system,
}) {
  List<GameActionData> tempActions = [];

  // check is hero
  if (leftBlock.type != BlockType.hero) {
    return tempActions;
  }
  // for (var leftBlock in blocks) {
  var point = leftBlock.point;
  // 获取 block 射程范围内 是否有 对象
  var attackPoisiton = point.addPosition(leftBlock.position);

  var vos = getBlockPosVos(blocks: system.blocks);

  var key = getBlockKey(attackPoisiton);
  BoardItem? rightBlock = vos[key];
  if (rightBlock != null) {
    // only check eneny
    if (rightBlock.type != BlockType.enemy) {
      return tempActions;
    }

    var canAttack = false;
    print("has block on ${key}");
    if (rightBlock.isDead) {
      // oh it is dead
      // only reduce hero check
    } else if (checkBlockCanAttack(leftBlock.type, rightBlock.type)) {
      canAttack = true;
    }

    if (canAttack) {
      // act from leftBlock
      print("leftBlock act ---- ${leftBlock.act}");

      // 判断 当前 游戏还有多少 act
      var act = system.act;
      var leftLife = leftBlock.life;
      var rightLife = rightBlock.life;

      // the
      var acttackLeft = act - rightLife;

      if (acttackLeft >= 0) {
        // ok need not to give blood
        // win win
        // update act to blood left
        system.act = acttackLeft;
        // only to do attack

        // right injure
        rightLife = 0;
        // right dead
      } else {
        // update act to zero
        system.act = 0;
        // need to lose life
        if (acttackLeft + leftLife > 0) {
          // ops act out
          // and you need to blood
          // you alive
          // left injure
          leftLife = leftLife + acttackLeft;

          // right injure
          rightLife = 0;
          // right dead
        } else {
          // no ~~
          rightLife = rightLife - act;
          // you are dead
          leftLife = 0;
          // need to play hero dead
        }
      }

      // turnAction
      var attackAction = GameActionData(
        target: leftBlock.id,
        type: GameActionType.attack,
        toTarget: rightBlock.id,
        value: act,
      );

      tempActions.add(attackAction);

      // do right block
      if (rightLife != rightBlock.life) {
        rightBlock.life = rightLife;
        var injureAction = GameActionData(
          target: rightBlock.id,
          type: GameActionType.injure,
          value: act,
          life: rightLife,
        );
        tempActions.add(injureAction);

        // dead
        if (rightLife == 0) {
          rightBlock.isDead = true;
          var deadAction = GameActionData(
            target: rightBlock.id,
            type: GameActionType.dead,
          );
          tempActions.add(deadAction);
        }
      }

      // 主角 受伤了。
      if (leftLife != leftBlock.life) {
        leftBlock.life = leftLife;
        var injureAction = GameActionData(
          target: leftBlock.id,
          type: GameActionType.injure,
          value: acttackLeft,
          life: leftLife,
        );
        tempActions.add(injureAction);

        // left dead
        if (leftLife == 0) {
          leftBlock.isDead = true;
          var deadAction = GameActionData(
            target: leftBlock.id,
            type: GameActionType.dead,
          );
          tempActions.add(deadAction);
        }
      }

      // move level 3 forword
      if (rightLife == 0) {
        // move to target
        // leftBlock.position = rightBlock.position;
        var moveAction = GameActionData(
          target: leftBlock.id,
          type: GameActionType.moveIn,
          position: rightBlock.position,
          point: point,
        );
        moveAction.level = 3;
        tempActions.add(moveAction);
      }
    }
  }
  // }
  return tempActions;
}
