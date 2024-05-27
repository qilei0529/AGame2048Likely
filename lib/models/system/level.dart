import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_game_2048_fight/models/system/block.dart';
import 'package:flutter_game_2048_fight/models/system/board.dart';
import 'package:flutter_game_2048_fight/models/system/game.dart';
import 'package:flutter_game_2048_fight/models/util.dart';

Future loadData(String path) async {
  String jsonString = await rootBundle.loadString("assets/levels/$path.json");
  return jsonDecode(jsonString);
}

Future<GameLevelData> loadLevelData({required String path}) async {
  print("load data $path");
  var data = await loadData(path);
  var name = data["name"];
  List<dynamic>? sections = data["sections"];
  // create level
  var level = GameLevelData(name: name);
  if (sections != null) {
    // reduce all section
    var floor = 0;
    for (var section in sections) {
      // reduce all step
      List<dynamic>? steps = section["steps"];
      if (steps != null) {
        // add floor
        floor += 1;
        var title = section["title"];

        // return
        var floorData = GameFloorData(title: title);
        level.levelFloorData["F_$floor"] = floorData;

        for (var item in steps) {
          var index = item["index"] as int;
          floorData.steps["${floor}_$index"] = item;
        }
      }
    }
  }

  return level;
}

GameStepData getGameStepData({
  required dynamic item,
  required BoardSize size,
  List<BoardItem>? leftBlocks,
}) {
  // create a step for level
  var step = GameStepData();
  // reduce blocks
  List<dynamic>? blocks = item["blocks"];

  if (blocks != null) {
    // all target
    var allTargets = getExtraBlocks(
      blocks: leftBlocks ?? [],
      size: size,
    );
    getRandomPos() {
      List<BoardPosition> list = allTargets.values.toList();
      var random = Random();
      int index = random.nextInt(list.length);
      var pos = list[index];
      allTargets.remove(getBlockKey(pos));
      return pos;
    }

    getRandomEdge() {
      List<BoardPosition> list = [];
      allTargets.values.forEach((pos) {
        if (pos.x == 1 || pos.y == 1) {
          list.add(pos);
        }
      });
      print("the edge list $list");
      var random = Random();
      int index = random.nextInt(list.length);
      var pos = list[index];
      allTargets.remove(getBlockKey(pos));
      return pos;
    }

    for (var data in blocks) {
      var id = data["id"];
      var name = data["name"];
      var type = BlockType.block.toType(data["type"]);
      var code = BlockMergeCode.none.toCode(data["code"] ?? "");

      var block = BoardItem(
        id: id,
        name: name,
        type: type,
      );

      block.code = code;

      if (type == BlockType.hero) {
        block.act = 1;
      } else if (type == BlockType.enemy) {
        block.act = 1;
      }

      List<dynamic>? pos = data["position"];
      if (pos != null) {
        var x = pos[0] as int;
        var y = pos[1] as int;
        block.position = BoardPosition(x, y);
        var key = getBlockKey(block.position);
        allTargets.remove(key);
      } else {
        BoardPosition pos;
        if (block.type == BlockType.door) {
          pos = getRandomEdge();
        } else {
          pos = getRandomPos();
        }
        block.position = pos;
        var key = getBlockKey(block.position);
        allTargets.remove(key);
      }

      int life = data["life"] ?? 1;
      block.life = life;

      int level = data["level"] ?? 1;
      block.level = level;

      // add block to step.blocks
      step.addBlock(block);
    }
  }
  return step;
}
