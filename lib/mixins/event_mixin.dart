import 'package:flutter_game_2048_fight/models/system/block.dart';
import 'package:flutter_game_2048_fight/models/system/game.dart';
import 'package:flutter_game_2048_fight/scenes/world_scene.dart';

import 'package:flutter_game_2048_fight/mixins/block_mixin.dart';

extension ActionMixin on WorldScene {
  runAction(GameActionData action, Function onEnd) {
    // no actions
    print(system.status);
    if (system.status != GameStatus.play) {
      onEnd();
      return;
    }

    var type = action.type;
    var item = system.getBlock(action.target);

    if (type == GameActionType.enter) {
      var block = vos[action.target];
      if (item != null && block != null) {
        // to play enter
        block.dead(end: () {
          block.removeFromParent();
          onEnd();
          if (item.type == BlockType.hero) {
            gameNextFloor();
          }
        });
      }
      return;
    }
    if (type == GameActionType.fade) {
      var block = vos[action.target];
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
      var block = vos[action.target];
      if (item != null && block != null) {
        block.dead(end: () {
          block.removeFromParent();
          system.removeBlock(item);
          onEnd();
          if (item.type == BlockType.hero) {
            gameOver();
          }
        });
      } else {
        onEnd();
      }
      return;
    }
    if (type == GameActionType.absorbed) {
      var block = vos[action.target];
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
        Future.delayed(const Duration(milliseconds: 300), () {
          var block = createBlock(item);
          board.add(block);
          vos[item.id] = block;
          if (block != null) {
            block.born(end: onEnd);
          } else {
            onEnd();
          }
        });
      } else {
        onEnd();
      }
      return;
    }

    if (item != null) {
      var block = vos[action.target];
      if (block != null) {
        // 处理 turn
        if (type == GameActionType.turn) {
          if (action.point != null) {
            block.point = action.point!;
          }
          onEnd();
          return;
        }
        if (type == GameActionType.move) {
          var pos = action.position!;
          block.moveTo(x: pos.x, y: pos.y, end: onEnd);
          return;
        }
        // attac
        if (type == GameActionType.attack) {
          // print("${item.id} attck: -> ");
          block.attack(end: onEnd);
          return;
        }
        if (type == GameActionType.injure) {
          // print("${item.id} injour: <- ");
          block.injure(num: item.life, end: onEnd);
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
