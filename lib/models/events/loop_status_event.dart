import '../game_system.dart';
import '../system/game.dart';

class LoopStepEvent extends GameLoopEvent {
  GameSystem system;

  // move
  LoopStepEvent({required this.system});

  @override
  action(payload) {
    system.step += 1;

    return null;
  }
}
