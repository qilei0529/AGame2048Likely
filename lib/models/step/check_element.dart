import 'package:flutter_game_2048_fight/models/game_system.dart';
import 'package:flutter_game_2048_fight/models/system/block.dart';
import 'package:flutter_game_2048_fight/models/system/game.dart';
import 'package:flutter_game_2048_fight/models/util.dart';

List<GameActionData> checkElementStep({
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
    var canElement = false;
    print("has block on ${key}");

    if (checkBlockCanElement(leftBlock.type, rightBlock.type)) {
      canElement = true;
    }

    if (canElement) {
      // do element
      rightBlock.isDead = true;
      var deadAction = GameActionData(
        target: rightBlock.id,
        type: GameActionType.dead,
      );
      tempActions.add(deadAction);

      // upgrade
      if (rightBlock.level >= leftBlock.level) {
        leftBlock.level = rightBlock.level;
        leftBlock.act = rightBlock.level;
        var upgradeAction = GameActionData(
          target: leftBlock.id,
          type: GameActionType.upgrade,
          life: rightBlock.life,
          value: rightBlock.level,
        );
        tempActions.add(upgradeAction);
      }

      var heal = rightBlock.life;
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
      moveAction.level = 3;
      tempActions.add(moveAction);
    }
  }
  // }
  return tempActions;
}
