import '../game_system.dart';
import '../system/block.dart';
import '../system/game.dart';
import '../util.dart';

class BlockElementEvent extends GameBlockEvent {
  GameSystem system;

  // move
  BlockElementEvent({required this.system});

  @override
  action(payload) {
    var leftBlock = payload.block;
    var vos = getBlockPosVos(blocks: system.blocks);

    List<GameActionData> tempActions = [];

    // for (var leftBlock in blocks) {
    var point = leftBlock.point;
    // 获取 block 射程范围内 是否有 对象
    var attackPoisiton = point.addPosition(leftBlock.position);

    var key = getBlockKey(attackPoisiton);
    var rightBlock = vos[key];
    if (rightBlock != null) {
      var canElement = false;
      print("has block on ${key}");

      if (checkBlockCanElement(leftBlock.type, rightBlock.type)) {
        canElement = true;
      }

      if (canElement) {
        var code = rightBlock.code;
        if (code == "element") {
          // heal ad sp
          var heal = rightBlock.life;
          system.sta += heal;
          var healAction = GameActionData(
            target: leftBlock.id,
            type: GameActionType.heal,
            life: leftBlock.life,
            value: heal,
          );
          tempActions.add(healAction);
        } else if (code == "heal") {
          // heal
          var heal = rightBlock.life;
          leftBlock.life += heal;
          var healAction = GameActionData(
            target: leftBlock.id,
            type: GameActionType.heal,
            life: leftBlock.life,
            value: heal,
          );
          tempActions.add(healAction);
        } else if (code == "weapon") {
          // heal
          // weapon update
          system.act += rightBlock.life;
          var healAction = GameActionData(
            target: leftBlock.id,
            type: GameActionType.heal,
            life: leftBlock.life,
            value: 0,
          );
          tempActions.add(healAction);
        }

        // do element
        rightBlock.isDead = true;
        var deadAction = GameActionData(
          target: rightBlock.id,
          type: GameActionType.fade,
        );
        tempActions.add(deadAction);

        system.actions.addAll(tempActions);
        return true;
      }
    }
    return null;
  }

  @override
  void clear() {}
}
