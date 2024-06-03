import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game_2048_fight/elements/block.dart';
import 'package:flutter_game_2048_fight/models/system/block.dart';
import 'package:flutter_game_2048_fight/models/system/game.dart';
import 'package:flutter_game_2048_fight/scenes/world_scene.dart';

import 'package:flutter_game_2048_fight/mixins/block_mixin.dart';

extension ActionMixin on WorldScene {
  runAction(GameActionData action, Function onEnd) {
    // no actions
    if (system.status != GameStatus.play) {
      onEnd();
      return;
    }

    var type = action.type;
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

    if (type == GameActionType.removeFloor) {
      var block = floorVos[action.target];
      if (block != null) {
        block.removeFromParent();
      }
      onEnd();
      return;
    }

    if (type == GameActionType.removeEffect) {
      var block = effectVos[action.target];
      if (block != null) {
        block.removeFromParent();
      }
      onEnd();
      return;
    }

    var item = system.getBlock(action.target);

    if (type == GameActionType.enter) {
      var block = blockVos[action.target];
      if (item != null && block != null) {
        // to play enter
        block.dead(end: () {
          block.removeFromParent();
          onEnd();
          if (item.type == BlockType.hero) {
            // gameNextFloor();
            system.status = GameStatus.next;
          }
        });
      }
      return;
    }

    if (type == GameActionType.fade) {
      var block = blockVos[action.target];
      if (item != null && block != null) {
        block.fadeTo(end: () {
          block.removeFromParent();
          system.removeBlock(item);
          onEnd();
        });
      } else {
        onEnd();
      }
      return;
    }
    if (type == GameActionType.dead) {
      var block = blockVos[action.target];
      if (item != null && block != null) {
        block.dead(end: () {
          block.removeFromParent();
          system.removeBlock(item);
          onEnd();
          if (item.type == BlockType.hero) {
            // gameOver();
            system.status = GameStatus.end;
          }
        });
      } else {
        onEnd();
      }
      return;
    }
    if (type == GameActionType.absorbed) {
      var block = blockVos[action.target];
      if (item != null && block != null) {
        block.dead(end: () {
          block.removeFromParent();
          onEnd();
        });
        system.removeBlock(item);
      } else {
        onEnd();
      }
      return;
    }
    // do create
    if (type == GameActionType.create) {
      if (item != null) {
        var block = createBlock(item);
        boardLayer.add(block);
        blockVos[item.id] = block;
        if (block != null) {
          block.born(end: onEnd);
        } else {
          onEnd();
        }
      } else {
        onEnd();
      }
      return;
    }
    // do create
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
    // do create
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
        onEnd();
      }
      return;
    }

    if (item != null) {
      var block = blockVos[action.target];
      if (block != null) {
        // 处理 turn
        if (type == GameActionType.turn) {
          // ignore: avoid_print
          print("${item.id} turen: ------ > ${action.point}");
          block.point = action.point!;
          block.turnTo(
            point: action.point!,
            end: onEnd,
            needTurn:
                block.type == BlockType.hero || block.type == BlockType.enemy,
          );
          return;
        }
        if (type == GameActionType.move) {
          var pos = action.position!;
          block.moveTo(x: pos.x, y: pos.y, end: onEnd);
          return;
        }
        // attac
        if (type == GameActionType.attack) {
          // ignore: avoid_print
          print("${item.id} attck: ------ > ${item.point}");
          block.attack(end: onEnd);
          return;
        }

        if (type == GameActionType.injure) {
          // print("${item.id} injour: <- ");
          block.injure(num: item.life, end: onEnd);
          return;
        }
        if (type == GameActionType.count) {
          print("set Count ${action.value}");
          var count = action.value ?? 0;
          block.countTo(count: count, end: onEnd);
          return;
        }
        if (type == GameActionType.heal) {
          // print("${item.id} heal: <- ");
          block.lifeTo(num: item.life, end: onEnd);
          return;
        }
        if (type == GameActionType.upgrade) {
          // print("${item.id} upgrade: <- ");
          block.setLevel(item.level);
          block.upgrade(num: item.life, end: onEnd);
          // block.lifeTo(num: item.life, end: onEnd);
          return;
        }
      }
    }
    onEnd();
  }
}
