import '../game_system.dart';
import '../system/game.dart';

class MovePointEvent extends GameMoveEvent {
  GameSystem system;

  // move
  MovePointEvent({required this.system});

  @override
  bool? action(payload) {
    var block = payload.block;
    var point = payload.point;

    // 初始化 行动力 通常 跟敏捷有关
    block.move = block.agi;
    block.point = point;

    return null;
  }
}
