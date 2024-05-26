import 'package:flutter_game_2048_fight/models/system/block.dart';
import 'package:flutter_game_2048_fight/models/system/board.dart';
import 'package:flutter_game_2048_fight/models/system/game.dart';
import 'package:flutter_game_2048_fight/models/util.dart';

checkMergeStep({
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
      var canMerge = false;
      print("has block on ${key}");
      if (rightBlock.isDead) {
      } else if (checkBlockCanMerge(leftBlock, rightBlock)) {
        canMerge = true;
      }

      if (canMerge) {
        // turnAction
        leftBlock.isDead = true;
        var eatAction = GameActionData(
          target: leftBlock.id,
          type: GameActionType.absorbed,
        );
        tempActions.add(eatAction);

        rightBlock.level += 1;
        rightBlock.life += leftBlock.life;
        rightBlock.act = rightBlock.level;
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
  return tempActions;
}
