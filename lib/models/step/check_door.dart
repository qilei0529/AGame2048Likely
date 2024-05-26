import 'package:flutter_game_2048_fight/models/system/block.dart';
import 'package:flutter_game_2048_fight/models/system/board.dart';
import 'package:flutter_game_2048_fight/models/system/game.dart';
import 'package:flutter_game_2048_fight/models/util.dart';

List<GameActionData> checkDoorStep({
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
      var canElement = false;
      print("has block on ${key}");

      if (checkBlockCanDoor(leftBlock.type, rightBlock.type)) {
        canElement = true;
      }

      if (canElement) {
        // do element
        if (rightBlock.life > 0) {
          rightBlock.life -= 1;
          var lifeAction = GameActionData(
            target: rightBlock.id,
            type: GameActionType.injure,
          );
          tempActions.add(lifeAction);

          // turnAction
          var attackAction = GameActionData(
            target: leftBlock.id,
            type: GameActionType.attack,
            toTarget: rightBlock.id,
            value: 1,
          );

          tempActions.add(attackAction);
        }

        if (rightBlock.life == 1) {
          rightBlock.level = 2;
          var itemAction = GameActionData(
            target: rightBlock.id,
            type: GameActionType.upgrade,
            value: rightBlock.level,
          );
          tempActions.add(itemAction);
        } else if (rightBlock.life == 0) {
          rightBlock.isDead = true;
          var deadAction = GameActionData(
            target: rightBlock.id,
            type: GameActionType.dead,
          );
          tempActions.add(deadAction);

          // move forword
          var moveAction = GameActionData(
            target: leftBlock.id,
            type: GameActionType.move,
            point: point,
            position: rightBlock.position,
          );
          tempActions.add(moveAction);
          // move forword
          var enterAction = GameActionData(
            target: leftBlock.id,
            type: GameActionType.enter,
          );
          tempActions.add(enterAction);
        }
      }
    }
  }
  return tempActions;
}
