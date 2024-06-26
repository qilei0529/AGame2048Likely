import 'package:flutter_game_2048_fight/models/events/block_door_down_stair_event.dart';
import 'package:flutter_game_2048_fight/models/system/block.dart';

import '../game_system.dart';
import '../system/game.dart';
import '../util.dart';

class BlockDoorEvent extends GameBlockEvent {
  GameSystem system;

  // move
  BlockDoorEvent({required this.system});

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

          // add a floor on the system
          var block = BoardItem(type: BlockType.floor);
          block.position = rightBlock.position;
          // 添加 去下一层的事件。
          var event = BlockDownStireEvent(system: system);
          event.type = GameEventType.floor;
          block.events.add(event);
          system.addFloor(block);

          var showAction = GameActionData(
            target: block.id,
            type: GameActionType.showStair,
            position: block.position,
          );
          tempActions.add(showAction);
        } else if (rightBlock.life == 0) {
          // 修改 主角移动 变为 1  方便刚好落在 门的位置上
          leftBlock.move = 1;

          rightBlock.isDead = true;
          var deadAction = GameActionData(
            target: rightBlock.id,
            type: GameActionType.dead,
          );
          tempActions.add(deadAction);
        }
        system.actions.addAll(tempActions);
        return true;
      }
    }
    return null;
  }
}
