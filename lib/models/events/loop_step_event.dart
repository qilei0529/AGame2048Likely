import '../game_system.dart';
import '../system/game.dart';

class LoopStepEvent extends GameLoopEvent {
  GameSystem system;

  // move
  LoopStepEvent({required this.system});

  @override
  action(payload) {
    system.step += 1;

    // clean dean ones
    system.blocks.forEach((block) {
      if (block.isDead) {
        system.removeBlock(block);
      }
    });

    return null;
  }
}
