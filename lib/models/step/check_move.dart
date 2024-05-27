import 'package:flutter_game_2048_fight/models/system/block.dart';
import 'package:flutter_game_2048_fight/models/system/board.dart';
import 'package:flutter_game_2048_fight/models/system/game.dart';
import 'package:flutter_game_2048_fight/models/util.dart';

List<GameActionData> checkMoveStep({
  required GamePoint point,
  required List<BoardItem> blocks,
  required BoardSize size,
  int? actionLevel,
  Function? onStep,
}) {
  List<GameActionData> moveActions = [];

  // 获取 排序
  List<BoardItem> blocklist = [];
  // 获取 位置 map 地图
  for (var element in blocks) {
    blocklist.add(element);
  }
  blocklist.sort((a, b) {
    var posA = a.position;
    var posB = b.position;
    switch (point) {
      case GamePoint.right:
        return posB.x - posA.x;
      case GamePoint.left:
        return posA.x - posB.x;
      case GamePoint.top:
        return posA.y - posB.y;
      case GamePoint.bottom:
        return posB.y - posA.y;
    }
  });

  Map<String, BoardItem> tempVos = {};

  checkBlockPoint(BoardItem leftBlock, GamePoint point) {
    // 获取 某一个方向上的位置。
    BoardPosition getPointPosition(BoardPosition pos) {
      // 判断是否可以移动
      if (!checkBlockCanMove(leftBlock.type)) {
        return pos;
      }
      // 获取 新位置
      var newPos = point.addPosition(pos);
      // 判断 新位置是否到边界
      var isEdge = checkSizeEdge(newPos, size);
      // 返回 当前 pos
      if (isEdge) {
        return pos;
      } else {
        // 判断 当前位置是否 有对象
        var key = getBlockKey(newPos);
        var rightBlock = tempVos[key];
        if (rightBlock != null) {
          return pos;
        }
        return getPointPosition(newPos);
      }
    }

    // get new pos by pos;
    var pos = getPointPosition(leftBlock.position);

    if (point != leftBlock.point) {
      // change the data
      leftBlock.point = point;
      // turnAction
      var turnAction = GameActionData(
        target: leftBlock.id,
        type: GameActionType.turn,
        point: point,
      );
      turnAction.level = 1;
      moveActions.add(turnAction);
    }
    // is dif pos; need to move;
    if (!isEqualPosition(pos, leftBlock.position)) {
      // change the pos
      leftBlock.position = pos;
      // moveActions
      var moveAction = GameActionData(
        target: leftBlock.id,
        type: GameActionType.move,
        point: point,
        position: pos,
      );
      moveAction.level = actionLevel ?? 1;
      moveActions.add(moveAction);
    }

    var key = getBlockKey(pos);
    tempVos[key] = leftBlock;

    if (onStep != null) {
      onStep(leftBlock);
    }
  }

  for (var block in blocklist) {
    checkBlockPoint(block, point);
  }

  return moveActions;
}
