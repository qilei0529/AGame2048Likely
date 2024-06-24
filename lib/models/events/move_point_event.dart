import '../game_system.dart';
import '../system/game.dart';

class MovePointEvent extends GameMoveEvent {
  GameSystem system;

  // move
  MovePointEvent({required this.system});

  @override
  bool? action(payload) {
    var leftBlock = payload.block;
    var point = payload.point;

    // 初始化 行动力 通常 跟敏捷有关
    leftBlock.move = leftBlock.agi;

    if (point != leftBlock.point) {
      // change the data
      leftBlock.point = point;
      // turnAction
      var turnAction = GameActionData(
        target: leftBlock.id,
        type: GameActionType.turn,
        point: leftBlock.point,
      );

      turnAction.level = 1;

      system.actions.addAll([turnAction]);
    }
    // todo add point action

    return null;
  }
}
