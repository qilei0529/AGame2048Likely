import 'dart:math';

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
        }
      }
    }
    system.actions.addAll(tempActions);
    return null;
  }
}
