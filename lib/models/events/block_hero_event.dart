import '../util.dart';

import '../game_system.dart';
import '../system/block.dart';
import '../system/game.dart';

class BlockHeroEvent extends GameBlockEvent {
  GameSystem system;

  // move
  BlockHeroEvent({required this.system});

  @override
  action(payload) {
    var leftBlock = payload.block;
    if (leftBlock.type != BlockType.hero) {
      return false;
    }
    var point = leftBlock.point;
    // 获取 block 射程范围内 是否有 对象
    var attackPoisiton = point.addPosition(leftBlock.position);

    var vos = getBlockPosVos(blocks: system.blocks);
    var key = getBlockKey(attackPoisiton);

    BoardItem? rightBlock = vos[key];
    if (rightBlock != null) {
      // only check eneny
      if (rightBlock.type != BlockType.enemy) {
        return false;
      }

      var canAttack = false;
      // ignore: avoid_print
      print("has block on $key");
      if (rightBlock.isDead) {
        // oh it is dead
        // only reduce hero check
      } else if (checkBlockCanAttack(leftBlock.type, rightBlock.type)) {
        // move must above 0 then can attack
        if (leftBlock.move > 0) {
          canAttack = true;
        }
      }

      if (canAttack) {
        // reduce attact
        // 判断 当前 游戏还有多少 act
        reduceAttackEffect(block: leftBlock, system: system);
        // reduceInjourAction(
        //   block: rightBlock,
        //   act: act,
        //   system: system,
        // );

        return true;
      }
    }
    return null;
  }
}

reduceAttackEffect({
  required BoardItem block,
  required GameSystem system,
  int? act,
}) {
  var events =
      block.events.where((event) => event.type == GameEventType.attack);
  // 获取 当前 block 的attack event
  if (events.isNotEmpty) {
    for (var event in events) {
      event.action(GameBlockPayload(block));
    }
  }
  // 处理 attack event
}
