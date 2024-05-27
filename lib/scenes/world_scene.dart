import 'dart:async';
// frame
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game_2048_fight/models/game_system.dart';
import 'package:flutter_game_2048_fight/models/system/block.dart';

// scene
import 'package:flutter_game_2048_fight/scenes/game_scene.dart';

// elements
import 'package:flutter_game_2048_fight/models/system/task.dart';
import 'package:flutter_game_2048_fight/models/system/game.dart';
import 'package:flutter_game_2048_fight/elements/button.dart';
import 'package:flutter_game_2048_fight/elements/block.dart';
import 'package:flutter_game_2048_fight/elements/block_item.dart';

// system
class WorldScene extends World with HasGameReference<TheGameScene> {
  late BlockComponent board;
  late BlockComponent popup;
  late TextComponent floorLabel;
  late TextComponent stepLabel;
  late TextComponent actLabel;
  late TextComponent staLabel;

  Map<String, BoardItemComponent> vos = {};

  GameSystem system;

  WorldScene({
    required this.system,
  });

  bool isSliding = false;

  initBlocks() {
    print("init blocks ${system.blocks}");
    for (var item in system.blocks) {
      addBlock(item);
    }
  }

  BoardItemComponent addBlock(BoardItem item) {
    var pos = item.position;
    var position = getBoardPositionAt(pos.x, pos.y);

    var color = Colors.blueGrey.shade300;
    if (item.type == BlockType.enemy) {
      color = Colors.red.shade400;
    }
    if (item.type == BlockType.hero) {
      color = Colors.blue.shade400;
    }
    if (item.type == BlockType.element) {
      color = Colors.orange.shade200;
    }
    if (item.type == BlockType.heal) {
      color = Colors.green.shade400;
    }
    if (item.type == BlockType.weapon) {
      color = Colors.blueGrey.shade500;
    }
    if (item.type == BlockType.door) {
      color = Colors.orange.shade400;
    }
    var block = BoardItemComponent(
      // key: ComponentKey.named(item.id),
      position: position,
      color: color,
    );
    // block.debugMode = true;
    block.debugColor = Colors.black26;
    block.point = item.point;
    if (item.life > 0) {
      block.setLife(item.life);
    }
    block.setLevel(item.level);
    block.setCode(item.code.toCodeString());
    board.add(block);

    // link vos with block ref
    vos[item.id] = block;
    return block;
  }

  gameStart() async {
    print("game start");
    // 初始化 英雄
    gameRestart();
  }

  gameRestart() {
    system.gameRestart();
    popup.removeFromParent();

    vos.forEach((key, value) {
      value.removeFromParent();
    });
    vos.clear();

    system.gameStart();
    initBlocks();
    updateStep();
    updateFloor();
    updateAct();
    updateSta();
  }

  gameNextFloor() {
    system.actionNextFloor();

    // clean blocks
    vos.forEach((key, value) {
      value.removeFromParent();
    });
    vos.clear();

    initBlocks();
    updateStep();
    updateFloor();
    updateAct();
    updateSta();
  }

  gameOver() {
    system.gameOver();
    initPopup();
    add(popup);
  }

  initHeader() {
    var size = game.camera.viewport.size;

    var button = Button(
      text: "Back To Home",
      size: Vector2(180, 40),
      position: Vector2(-90, -size.y / 2 + 60),
      onPressed: () {
        // trigger start
        game.goHome();
      },
    );
    add(button);
  }

  initBoard() {
    board = BlockComponent(
      size: Vector2(300, 300),
      color: Colors.white60,
      position: Vector2(0, -80),
    );

    for (var x = 1; x < 6; x += 1) {
      for (var y = 1; y < 6; y += 1) {
        var pos = getBoardPositionAt(x, y);
        var block = BlockComponent(
          size: Vector2(60, 60),
          color: Colors.green.shade100,
          position: pos,
        );
        board.add(block);
      }
    }

    add(board);
  }

  actionSlide(GamePoint point) async {
    if (system.status == GameStatus.start) {
      system.status = GameStatus.play;
    }
    if (system.status != GameStatus.play) {
      return;
    }
    if (isSliding) {
      return;
    }
    isSliding = true;
    system.actionSlide(point);

    // update step display
    updateStep();
    updateAct();
    updateSta();
    await runActions();
    isSliding = false;
  }

  updateStep() {
    stepLabel.text = "step: ${system.step}";
  }

  updateFloor() {
    floorLabel.text = "floor: ${system.floor}";
  }

  updateAct() {
    actLabel.text = "act: ${system.act}";
  }

  updateSta() {
    staLabel.text = "sp: ${system.sta}";
  }

  runActions() async {
    var actions = system.actions;
    runAcitonList(List<GameActionData> list) async {
      var innerTaskSystem = TaskSystem(maxQueue: 20);
      for (var action in list) {
        // ignore: prefer_function_declarations_over_variables
        var task = (Function next) => runAction(action, next);
        innerTaskSystem.add(task);
      }
      await innerTaskSystem.run();
    }

    var taskSystem = TaskSystem(maxQueue: 1);
    for (var index in [1, 2, 3]) {
      var list = actions.where((action) => action.level == index).toList();
      if (list.isNotEmpty) {
        taskSystem.add((next) async {
          await runAcitonList(list);
          next();
        });
      }
    }
    system.actions.clear();
    await taskSystem.run();
  }

  runAction(GameActionData action, Function onEnd) {
    // no actions
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
    if (type == GameActionType.dead) {
      var block = vos[action.target];
      if (item != null && block != null) {
        block.dead(end: () {
          block.removeFromParent();
          onEnd();
        });
        system.removeBlock(item);
        if (item.type == BlockType.hero) {
          gameOver();
        }
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
          addBlock(item);
          var block = vos[item.id];
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
          block.lifeTo(num: item.life, end: onEnd);
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
          block.lifeTo(num: item.life, end: onEnd);
          return;
        }
      }
    }
    onEnd();
  }

  initPopup() {
    popup = BlockComponent(
      size: Vector2(200, 160),
      color: Colors.black38,
      position: Vector2(0, -40),
    );
    var text = TextComponent(
      text: "GameOver",
      position: Vector2(50, 20),
    );
    var button = Button(
        text: "Restart",
        position: Vector2(100, 80),
        size: Vector2(120, 40),
        onPressed: () {
          gameRestart();
        });
    popup.add(text);
    popup.add(button);
  }

  initControl() {
    var block = BlockComponent(
      size: Vector2(320, 160),
      color: Colors.yellow.shade700,
      position: Vector2(0, 180),
    );

    var list = [
      {"text": "L", "top": -160, "left": 0, "point": GamePoint.left},
      {"text": "R", "top": -40, "left": 0, "point": GamePoint.right},
      {"text": "T", "top": -100, "left": -60, "point": GamePoint.top},
      {"text": "B", "top": -100, "left": 60, "point": GamePoint.bottom},
    ];

    for (var item in list) {
      var text = item["text"];
      var point = item["point"] as GamePoint;
      var top = item["top"] as int;
      var left = item["left"] as int;
      var button = Button(
          text: text as String,
          position: Vector2(200 + top.toDouble(), 80 + left.toDouble()),
          size: Vector2(60, 60),
          onPressed: () {
            print('on pressed $text $point');
            actionSlide(point);
          });
      block.add(button);
    }

    stepLabel = TextComponent(text: "step: 0", position: Vector2(200, 0));
    floorLabel = TextComponent(text: "floor: 0", position: Vector2(200, 30));
    staLabel = TextComponent(text: "体力: 0", position: Vector2(200, 60));
    actLabel = TextComponent(text: "武器: 0", position: Vector2(200, 90));
    block.add(stepLabel);
    block.add(floorLabel);
    block.add(staLabel);
    block.add(actLabel);

    add(block);
  }

  // get the position from int x y
  Vector2 getBoardPositionAt(int x, int y) {
    var dx = 60.0 * x.toDouble() - 30;
    var dy = 60.0 * y.toDouble() - 30;
    return Vector2(dx, dy);
  }

  @override
  FutureOr<void> onLoad() {
    // init header
    initHeader();

    // init Board
    initBoard();

    initControl();

    initPopup();

    // wait for a moment
    gameStart();
    return super.onLoad();
  }
}
