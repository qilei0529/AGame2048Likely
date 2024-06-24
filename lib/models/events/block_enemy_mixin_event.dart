import 'dart:math';

import '../game_system.dart';
import '../system/game.dart';
import '../util.dart';

class BlockEnemyMixinEvent extends GameBlockEvent {
  GameSystem system;

  // move
  BlockEnemyMixinEvent({required this.system});

  @override
  action(payload) {
    var leftBlock = payload.block;
    var vos = getBlockPosVos(blocks: system.blocks);

    List<GameActionData> tempActions = [];

    // for (var leftBlock in blocks) {
    var point = leftBlock.point;
    // 获取 block 射程范围内 是否有 对象
    var mergePoisiton = point.toBack().addPosition(leftBlock.position);

    var key = getBlockKey(mergePoisiton);
    var rightBlock = vos[key];
    if (rightBlock != null) {
      var canMerge = false;
      print("has block on ${key}");
      if (rightBlock.isDead) {
      } else if (checkBlockCanMerge(leftBlock, rightBlock)) {
        canMerge = true;
      }

      if (canMerge) {
        var level = min(leftBlock.level + 1, 3);
        if (level != leftBlock.level) {
          // turnAction
          rightBlock.isDead = true;
          var eatAction = GameActionData(
            target: rightBlock.id,
            type: GameActionType.absorbed,
          );
          tempActions.add(eatAction);
          //
          leftBlock.level = level;
          leftBlock.life += rightBlock.life;
          leftBlock.act += 1;
          print("333333333333 ------ ${leftBlock.level}");
          var upgradeAction = GameActionData(
            target: leftBlock.id,
            type: GameActionType.upgrade,
            value: leftBlock.level,
            life: leftBlock.life,
          );
          tempActions.add(upgradeAction);

          system.actions.addAll(tempActions);
          return true;
        }
      }
      return null;
    }
    return null;
  }

  @override
  void clear() {}
}
