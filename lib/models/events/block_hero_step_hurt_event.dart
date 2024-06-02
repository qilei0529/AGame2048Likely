import '../game_system.dart';
import '../system/game.dart';
import '../system/block.dart';

class BlockHeroStepHurtEvent extends GameBlockEvent {
  GameSystem system;

  // move
  BlockHeroStepHurtEvent({required this.system});

  @override
  action(payload) {
    // print
    // 每回合都受伤
    var block = payload.block;
    if (block.type == BlockType.hero) {
      print("hero hurt ---------- >");

      List<GameActionData> tempActions = [];

      var sta = system.sta;

      var leftBlock = block;

      if (leftBlock != null && !leftBlock.isDead) {
        var leftLife = leftBlock.life;
        // check sta 体力
        sta -= 1;
        if (sta < 0) {
          leftLife -= 1;
          sta = 0;
          // do not below zero
          if (leftLife <= 0) {
            leftLife = 0;
          }
        }

        if (leftLife != leftBlock.life) {
          leftBlock.life = leftLife;
          var injureAction = GameActionData(
            target: leftBlock.id,
            type: GameActionType.injure,
            value: 1,
            life: leftLife,
          );
          tempActions.add(injureAction);

          // hero dead
          if (leftLife == 0) {
            leftBlock.isDead = true;
            var deadAction = GameActionData(
              target: leftBlock.id,
              type: GameActionType.dead,
            );
            tempActions.add(deadAction);
          }
          system.actions.addAll(tempActions);
        }
      }

      print("hero hurt ---------- > $sta");
      // update sta;
      system.sta = sta;
    }
    return null;
  }
}
