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

    block.move = 6;
    block.point = point;

    return null;
  }
}
