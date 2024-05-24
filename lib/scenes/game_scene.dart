import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

// frame
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game_2048_fight/models/system/block.dart';
import 'package:flutter_game_2048_fight/models/system/board.dart';

// scene
import 'start_scene.dart';
import 'world_scene.dart';

// elements
import 'package:flutter_game_2048_fight/models/system/game.dart';
import 'package:flutter_game_2048_fight/elements/background.dart';

// system

// component
class TheGameScene extends FlameGame {
  TheGameScene();
  late Background ground;

  late Background mask;

  Future loadData() async {
    String jsonString = await rootBundle.loadString('assets/data.json');
    return jsonDecode(jsonString);
  }

  Future<GameLevelData> loadLevel() async {
    var data = await loadData();
    var name = data["name"];
    List<dynamic>? steps = data["steps"];
    var level = GameLevelData(name: name);
    if (steps != null) {
      for (var item in steps) {
        var index = item["index"] as int;
        // create a step for level

        var step = GameStepData();
        level.levelStepData[index] = step;

        // reduce blocks
        List<dynamic>? blocks = item["blocks"];
        if (blocks != null) {
          for (var data in blocks) {
            var id = data["id"];
            var name = data["name"];
            var type = BlockType.block.toType(data["type"]);

            var block = BoardItem(
              id: id,
              name: name,
              type: type,
            );

            if (type == BlockType.hero) {
              block.code = BlockMergeCode.hero;
              block.act = 1;
            } else if (type == BlockType.enemy) {
              block.code = BlockMergeCode.none;
              block.act = 1;
            }

            List<dynamic>? pos = data["position"];
            if (pos != null) {
              var x = pos[0] as int;
              var y = pos[1] as int;
              block.position = BoardPosition(x, y);
            }

            int? life = data["life"];
            if (life != null) {
              block.life = life;
            }

            int? level = data["level"];
            if (level != null) {
              block.level = level;
            }

            // add block to step.blocks
            step.addBlock(block);
          }
        }
      }
    }

    return level;
  }

  goHome() async {
    world = StartScene();
  }

  gameStart() async {
    print('start');
    // get level data
    var level = await loadLevel();
    print(level);
    // show black ground
    // showMask();
    // wait for the data ready
    world = WorldScene(level: level);
    // show game
  }

  showMask() {
    mask = Background(color: Colors.red.shade300);
    final viewport = camera.viewport;
    viewport.add(mask);
  }

  void initBackgound() {
    ground = Background();
    add(ground);
  }

  @override
  FutureOr<void> onLoad() async {
    initBackgound();

    gameStart();

    return super.onLoad();
  }
}
