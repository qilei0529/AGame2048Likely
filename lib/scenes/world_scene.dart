import 'dart:async';
import 'dart:math';
// frame
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

// minxins
import 'package:flutter_game_2048_fight/mixins/block_mixin.dart';
import 'package:flutter_game_2048_fight/mixins/event_mixin.dart';

// models
import 'package:flutter_game_2048_fight/models/util.dart';
import 'package:flutter_game_2048_fight/models/game_system.dart';
import 'package:flutter_game_2048_fight/models/system/task.dart';
import 'package:flutter_game_2048_fight/models/system/game.dart';

// scene
import 'package:flutter_game_2048_fight/scenes/game_scene.dart';

// elements
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

  bool isPending = false;

  initBlocks() {
    print("init blocks ${system.blocks}");
    for (var item in system.blocks) {
      var block = createBlock(item);
      // block.setCode(item.code.toCodeString());
      board.add(block);

      // link vos with block ref
      vos[item.id] = block;
    }
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
    updateAct();
    updateSta();
    updateStep();
    updateFloor();
  }

  gameNextFloor() {
    isPending = true;
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

    Future.delayed(const Duration(milliseconds: 1000), () {
      isPending = false;
    });
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
      size: globalBoardSize,
      color: Colors.black87,
      position: Vector2(0, -60),
    );

    var size = system.size;
    var count = 0;
    for (var x = 1; x < size.width + 1; x++) {
      for (var y = 1; y < size.height + 1; y++) {
        count++;
        var hasColor = count % 2 == 0;
        var pos = getBoardPositionAt(x, y);
        var block = BlockComponent(
          size: Vector2(60, 60),
          color:
              hasColor ? Color.fromARGB(10, 255, 255, 255) : Colors.transparent,
          position: pos,
        );
        board.add(block);
      }
      count++;
    }
    // board.debugMode = true;
    add(board);
  }

  updateStep() {
    stepLabel.text = "step: ${system.step}";
  }

  updateFloor() {
    floorLabel.text = "floor: ${system.floor}";
  }

  updateAct() {
    var hero = system.hero;
    if (hero != null) {
      var block = vos[system.hero!.id];
      if (block != null) {
        var act = max(hero.act, system.act);
        block.setAct(act);
      }
    }
    actLabel.text = "act: ${system.act}";
  }

  updateSta() {
    staLabel.text = "sp: ${system.sta}";
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
      position: Vector2(0, 240),
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
    system.runMoveEvents(point);
    await runActions();
    system.runBlockEvents(point);
    await runActions();
    // update act and sta
    updateAct();
    updateSta();

    system.runMove2Events(point);
    await runActions();
    system.runLoopEvents(point);
    await runActions();

    // update step display
    updateStep();
    // system.checkStepForNext();
    // await runActions();

    isSliding = false;
  }

  runActions() async {
    var actions = system.actions;
    runAcitonList(List<GameActionData> list) async {
      var innerTaskSystem = TaskSystem(maxQueue: 30);
      for (var action in list) {
        print("action ${action.type} action ${action.target}");
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

// get the position from int x y
Vector2 getBoardPositionAt(int x, int y) {
  var width = globalBlockSize.x;
  var height = globalBlockSize.y;
  var dx = width * x.toDouble() - width / 2;
  var dy = height * y.toDouble() - height / 2;
  return Vector2(dx, dy);
}
