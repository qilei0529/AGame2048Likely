import '../game_system.dart';
import '../system/game.dart';

class LoopStatusEvent extends GameLoopEvent {
  GameSystem system;

  // move
  LoopStatusEvent({required this.system});

  @override
  action(payload) {
    // clean dead blocks
    system.blocks.forEach((block) {
      if (block.isDead) {
        system.removeBlock(block);
      }
    });

    // check game is over
    var hero = system.hero;
    if (hero == null) {
      system.status = GameStatus.end;
    }

    return null;
  }
}
