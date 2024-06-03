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
    for (var data in blocks) {
      // add block to step.blocks
      var block = createBlockWidthData(data);
      step.addBlock(block);

      List<dynamic>? pos = data["position"];
      if (pos != null) {
        var x = pos[0] as int;
        var y = pos[1] as int;
        block.position = BoardPosition(x, y);
      } else {
        BoardPosition pos;
        pos = BoardPosition(-1, -1);
        block.position = pos;
      }
    }
  }
  return step;
}

BoardItem createEffectBlock() {
  var block = BoardItem(
    type: BlockType.effect,
  );
  return block;
}

BoardItem createBlockWidthData(dynamic data) {
  var id = data["id"];
  var name = data["name"];
  var type = BlockType.block.toType(data["type"]);
  var code = data["code"] ?? "none";

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

  int life = data["life"] ?? 1;
  block.life = life;

  int level = data["level"] ?? 1;
  block.level = level;

  return block;
}
