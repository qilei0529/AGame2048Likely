import '../game_system.dart';
import '../system/board.dart';
import '../system/game.dart';
import '../util.dart';

class MoveForwardEvent extends GameMoveEvent {
  GameSystem system;

  // move
  MoveForwardEvent({required this.system});

  @override
  bool? action(payload) {
    var block = payload.block;
    var point = payload.point;
    var size = system.size;

    int move = block.move;

    int needMove = 0;

    var leftBlock = block;
    // 获取 某一个方向上的位置。
    BoardPosition getPointPosition(BoardPosition pos) {
      // ignore: avoid_print
      print("leftBlock ${block.id} $move");
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
        var rightBlock = system.getPosMap(key);
        if (rightBlock != null) {
          return pos;
        }
        if (move <= 0) {
          return pos;
        }
        // move
        move -= 1;
        // need move
        needMove += 1;
        return getPointPosition(newPos);
      }
    }

    List<GameActionData> moveActions = [];

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
      leftBlock.move -= needMove;
      // moveActions
      var moveAction = GameActionData(
        target: leftBlock.id,
        type: GameActionType.move,
        point: point,
        position: pos,
      );
      moveAction.level = 1;
      moveActions.add(moveAction);
    }

    var key = getBlockKey(pos);
    system.setPosMap(key, leftBlock);

    // add action to system action
    // ignore: avoid_print
    print("move Actions $moveActions ${leftBlock.position}");
    system.actions.addAll(moveActions);
    return null;
  }
}
