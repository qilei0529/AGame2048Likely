import 'package:flutter_game_2048_fight/models/game_system.dart';
import 'package:flutter_game_2048_fight/models/system/block.dart';
import 'package:flutter_game_2048_fight/models/system/game.dart';

checkGameStep({
  required GameSystem system,
}) {
  system.step += 1;

  var sta = system.sta;

  var leftBlock = system.hero;

  List<GameActionData> tempActions = [];

  if (leftBlock != null && !leftBlock.isDead) {
    var leftLife = leftBlock.life;
    // check sta 体力
    sta -= 1;
    if (sta <= 0) {
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
    }

    // update sta;
    system.sta = sta;

    return tempActions;
  }
  //
}
