import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game_2048_fight/elements/block.dart';
import 'package:flutter_game_2048_fight/elements/blocks/block_base.dart';
import 'package:flutter_game_2048_fight/models/system/block.dart';
import 'package:flutter_game_2048_fight/models/system/game.dart';
import 'package:flutter_game_2048_fight/scenes/world_scene.dart';

import 'package:flutter_game_2048_fight/mixins/block_mixin.dart';

extension ActionMixin on WorldScene {
  runAction(GameActionData action, Function onEnd) {
    if (system.status != GameStatus.play) {
      onEnd();
      return;
    }
    var type = action.type;

    // normal
    if (type == GameActionType.create) {
      var item = system.getBlock(action.target);
      if (item != null) {
        var block = createBlockItem(item);
        if (block != null) {
          boardLayer.add(block);
          blockVos[item.id] = block;
          block.toBorn(onComplete: onEnd);
        } else {
          onEnd();
        }
      } else {
        onEnd();
      }
      return;
    }

    if (type == GameActionType.dead) {
      var block = blockVos[action.target];
      if (block != null) {
        block.toDead(onComplete: () {
          block.removeFromParent();
          blockVos.remove(action.target);
          onEnd();
        });
      } else {
        onEnd();
      }
      return;
    }

    if (type == GameActionType.move) {
      var block = blockVos[action.target];
      if (block != null) {
        block.toMove(pos: action.position!, onComplete: onEnd);
      } else {
        onEnd();
      }
      return;
    }
    // hero

    if (type == GameActionType.healHP) {
      var block = blockVos[action.target];
      if (block != null && block is BlockActiveItem) {
        block.toLife(action.value!);
        onEnd();
      } else {
        onEnd();
      }
      return;
    }

    if (type == GameActionType.healACT) {
      var block = blockVos[action.target];
      if (block != null && block is BlockActiveItem) {
        block.toAct(action.value!);
        updateAct();
        onEnd();
      } else {
        onEnd();
      }
      return;
    }

    if (type == GameActionType.healSP) {
      var block = blockVos[action.target];
      if (block != null && block is BlockActiveItem) {
        updateSta();
        onEnd();
      } else {
        onEnd();
      }
      return;
    }

    // enemy
    if (type == GameActionType.absorbed) {
      var block = blockVos[action.target];
      if (block != null) {
        if (block is BlockActiveItem) {
          // block.fa
          block.toAbsorb(onComplete: () {
            block.removeFromParent();
            blockVos.remove(action.target);
            onEnd();
          });
        } else {
          block.removeFromParent();
          blockVos.remove(action.target);
          onEnd();
        }
      } else {
        onEnd();
      }
      return;
    }

    // attac
    if (type == GameActionType.turn) {
      var block = blockVos[action.target];
      var item = system.getBlock(action.target);
      if (block != null && item != null) {
        block.toTurn(
          point: action.point!,
          onComplete: onEnd,
          needTurn: item.type == BlockType.hero || item.type == BlockType.enemy,
        );
      } else {
        onEnd();
      }
      return;
    }
    if (type == GameActionType.attack) {
      var block = blockVos[action.target];
      if (block != null && block is BlockActiveItem) {
        block.toAttack(onComplete: onEnd);
      } else {
        onEnd();
      }
      return;
    }

    if (type == GameActionType.injure) {
      var block = blockVos[action.target];
      if (block != null && block is BlockActiveItem) {
        block.toInjure(life: action.life, onComplete: onEnd);
      } else {
        onEnd();
      }
      return;
    }

    // element
    if (type == GameActionType.fade) {
      var block = blockVos[action.target];
      if (block != null) {
        block.toTrigger(onComplete: () {
          block.removeFromParent();
          blockVos.remove(action.target);
          onEnd();
        });
      } else {
        onEnd();
      }
      return;
    }

    // floor
    if (type == GameActionType.createFloor) {
      // 新建一个 地板 样式 楼梯
      var item = system.getFloor(action.target);
      if (item != null) {
        var p = item.position;
        var pos = getBoardPositionAt(p.x, p.y);
        var block = BlockComponent(
          size: Vector2(58, 58),
          color: item.code == "green"
              ? Colors.green.shade100
              : Colors.red.shade100,
          position: pos,
        );
        groundLayer.add(block);
        // set ref
        floorVos[item.id] = block;
        onEnd();
      }
      return;
    }

    if (type == GameActionType.removeFloor) {
      var block = floorVos[action.target];
      if (block != null) {
        block.removeFromParent();
        floorVos.remove(action.target);

        var item = system.getFloor(action.target);
        if (item != null) {
          system.removeFloor(item);
        }
      }
      onEnd();
      return;
    }

    // door
    // 出现 楼梯
    if (type == GameActionType.showStair) {
      // 新建一个 地板 样式 楼梯
      var item = system.getFloor(action.target);
      if (item != null) {
        var p = item.position;
        var pos = getBoardPositionAt(p.x, p.y);
        var block = BlockComponent(
          size: Vector2(60, 60),
          color: Colors.yellow.shade100,
          position: pos,
        );
        groundLayer.add(block);
        // set ref
        floorVos[item.id] = block;
      }
      onEnd();
      return;
    }

    if (type == GameActionType.enter) {
      var block = blockVos[action.target];
      var item = system.getBlock(action.target);
      if (item != null && block != null) {
        // to play enter
        if (item.type == BlockType.hero) {
          // gameNextFloor();
          system.status = GameStatus.next;
        }
      }
      onEnd();
      return;
    }

    if (type == GameActionType.upgrade) {
      var block = blockVos[action.target];
      if (block != null) {
        print("block level upgrade --------------> ${action.value}");
        block.toGrow(
          life: action.life,
          level: action.value,
          onComplete: onEnd,
        );
        if (action.life != null && block is BlockActiveItem) {
          block.toLife(action.life!);
        }
      } else {
        onEnd();
      }
      return;
    }

    // effect
    if (type == GameActionType.createEffect) {
      // 新建一个 效果
      var item = system.getEffect(action.target);
      if (item != null) {
        var p = item.position;
        var pos = getBoardPositionAt(p.x, p.y);
        // TODO 后续 效果 的 UI
        var block = BlockComponent(
          size: Vector2(58, 58),
          color: const Color.fromARGB(0, 255, 255, 255),
          position: pos,
        );
        effectLayer.add(block);
        // set ref
        effectVos[item.id] = block;
      }
      onEnd();
      return;
    }
    print(type);
    onEnd();
  }
}
