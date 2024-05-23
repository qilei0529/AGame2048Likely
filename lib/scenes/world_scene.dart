import 'dart:async';

// frame
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game_2048_fight/models/system/block.dart';
import 'package:flutter_game_2048_fight/models/system/board.dart';

// scene
import 'package:flutter_game_2048_fight/scenes/game_scene.dart';

// elements
import 'package:flutter_game_2048_fight/models/system/game.dart';
import 'package:flutter_game_2048_fight/elements/button.dart';
import 'package:flutter_game_2048_fight/elements/block.dart';

// system
class WorldScene extends World with HasGameReference<TheGameScene> {
  late GameLevelData level;
  late BlockComponent board;

  // 当前 的 step
  late int step = 0;
  // 所有 的 step data
  late List<GameStepData> steps = [];
  // 当前 step
  late GameStepData currentStep;

  late Map<String, BlockComponent> vos = {};

  WorldScene({required this.level});

  renderStepBlock(GameStepData step) {
    for (var data in step.blocks) {
      var item = data as BoardItem;
      var pos = item.position;
      var position = getBoardPositionAt(pos.x, pos.y);
      BlockComponent block;
      if (item.type == BlockType.enmey) {
        block = BlockComponent(
          key: ComponentKey.named(item.id),
          position: position,
          color: Colors.red.shade400,
        );
      } else {
        block = BlockComponent(
          key: ComponentKey.named(item.id),
          position: position,
          color: Colors.blue.shade400,
        );
      }

      // item.body = block;
      vos[item.id] = block;

      block.debugMode = true;
      block.debugColor = Colors.black26;
      board.add(block);
    }
  }

  gameStart() {
    // 初始化 英雄
    var step = level.getStepData(0);
    if (step != null) {
      currentStep = GameStepData(size: step.size);
      for (var block in step.blocks) {
        currentStep.addBlock(
          (block as BoardItem).copy(),
        );
      }
      renderStepBlock(currentStep);
    }
  }

  gamePlay() {}

  gamePause() {}

  gameRestart() {}

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

  actionSlide(GamePoint point) {
    // system.

    // 获取 排序
    List<BoardItem> blocklist = [];
    for (var element in currentStep.blocks) {
      blocklist.add(element as BoardItem);
    }

    blocklist.sort((a, b) {
      var posA = a.position;
      var posB = b.position;
      switch (point) {
        case GamePoint.right:
          return posB.x - posA.x;
        case GamePoint.left:
          return posA.x - posB.x;
        case GamePoint.top:
          return posA.y - posB.y;
        case GamePoint.bottom:
          return posB.y - posA.y;
      }
    });

    Map<String, BoardItem> tempVos = {};
    var size = currentStep.size;

    checkBlockPoint(BoardItem block, GamePoint point) {
      // 获取 某一个方向上的位置。
      BoardPosition getPointPosition(BoardPosition pos) {
        // 获取 新位置
        var newPos = point.addPosition(pos);
        // 判断 新位置是否到边界
        var isEdge = checkSizeEdge(newPos, size);
        // 返回 当前 pos
        if (isEdge) {
          return pos;
        } else {
          // 判断 当前位置是否 有对象
          var key = getBlockKey(newPos);
          var item = tempVos[key];
          if (item != null) {
            // 处理 伤害
            print("need do impack with: ${item.name}");
            var isAlive = true;
            if (isAlive) {
              return pos;
            }
          }
          return getPointPosition(newPos);
        }
      }

      // get new pos by pos;
      var pos = getPointPosition(block.position);
      print("${block.name} ${block.life} ${pos.x} - ${pos.y}");

      var position = getBoardPositionAt(pos.x, pos.y);

      var body = vos[block.id];
      if (body != null) {
        body.position = position;
        print("move to ${position}");
      }
      // newBlock.moveTo(pos.x, pos.y, point);
      var key = getBlockKey(pos);
      tempVos[key] = block;
    }

    for (var block in blocklist) {
      checkBlockPoint(block, point);
    }

    currentStep.vos.clear();
    currentStep.vos.addAll(tempVos);
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

    add(block);
  }

  // get the position from int x y
  Vector2 getBoardPositionAt(int x, int y) {
    var width = 300;
    var height = 300;
    print("$width, $height");
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

    // wait for a moment
    gameStart();
    return super.onLoad();
  }
}

bool checkSizeEdge(BoardPosition pos, BoardSize size) {
  if (pos.x <= 0) {
    return true;
  }
  if (pos.x > size.width) {
    return true;
  }
  if (pos.y <= 0) {
    return true;
  }
  if (pos.y > size.height) {
    return true;
  }
  return false;
}

String getBlockKey(BoardPosition pos) {
  return "B_${pos.x}_${pos.y}";
}
