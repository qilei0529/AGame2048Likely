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

    // 有块事件是 move 事件
    var events = block.events
        .where((event) => event.type == GameEventType.move)
        .toList();

    // count need move
    int needMove = 0;

    var leftBlock = block;
    // 获取 某一个方向上的位置。
    BoardPosition getPointPosition(BoardPosition pos) {
      // ignore: avoid_print

      // 判断 当前块是否 有 block.move事件
      if (events.isNotEmpty) {
        events.forEach((event) {
          event.action(payload);
        });
      }

      // 判断 当前块 是否有 floor 事件
      var floor = system.getFloorAt(pos);
      if (floor != null && floor.events.isNotEmpty) {
        var events = floor.events
            .where((event) => event.type == GameEventType.move)
            .toList();
        if (events.isNotEmpty) {
          events.forEach((event) {
            event.action(GameBlockPayload(leftBlock));
          });
        }
      }

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
      }

      // 判断 当前位置是否 有对象
      var key = getBlockKey(newPos);
      var rightBlock = system.getPosMap(key);
      if (rightBlock != null) {
        return pos;
      }
      if (leftBlock.move <= 0) {
        return pos;
      }
      leftBlock.move -= 1;
      // need move
      needMove += 1;
      return getPointPosition(newPos);
    }

    List<GameActionData> moveActions = [];

    // get new pos by pos;
    var pos = getPointPosition(leftBlock.position);

    // is dif pos; need to move;
    if (!isEqualPosition(pos, leftBlock.position)) {
      // change the pos
      leftBlock.position = pos;
      // moveActions
      var moveAction = GameActionData(
        target: leftBlock.id,
        type: GameActionType.move,
        point: leftBlock.point,
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
