import '../game_system.dart';
import '../system/game.dart';

class FloorGreenEvent extends GameBlockEvent {
  GameSystem system;

  // move
  FloorGreenEvent({required this.system});

  @override
  action(payload) {
    print("event floor greeeen ------->");

    // stop move
    var leftBlock = payload.block;
    leftBlock.move = 0;

    var floor = system.getFloorAt(leftBlock.position);

    if (floor != null) {
      var deadAction = GameActionData(
        target: floor.id,
        type: GameActionType.removeFloor,
      );
      system.removeFloor(floor);
      system.actions.add(deadAction);
    }

    return null;
  }
}
