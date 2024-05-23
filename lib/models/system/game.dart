import 'package:flutter_game_2048_fight/models/system/block.dart';
import 'package:flutter_game_2048_fight/scenes/game_scene.dart';
import 'package:uuid/uuid.dart';

import 'board.dart';

enum GameStatus {
  start,
  play,
  pause,
  end,
}

// 游戏场景
enum GameScene {
  home,
  world,
}

enum GamePoint { left, right, top, bottom }

extension PointTypeExtension on GamePoint {
  BoardPosition toPosition() {
    switch (this) {
      case GamePoint.left:
        return BoardPosition(-1, 0);
      case GamePoint.right:
        return BoardPosition(1, 0);
      case GamePoint.top:
        return BoardPosition(0, -1);
      case GamePoint.bottom:
        return BoardPosition(0, 1);
    }
  }

  BoardPosition addPosition(BoardPosition pos) {
    switch (this) {
      case GamePoint.left:
        return BoardPosition(-1 + pos.x, 0 + pos.y);
      case GamePoint.right:
        return BoardPosition(1 + pos.x, 0 + pos.y);
      case GamePoint.top:
        return BoardPosition(0 + pos.x, -1 + pos.y);
      case GamePoint.bottom:
        return BoardPosition(0 + pos.x, 1 + pos.y);
    }
  }
}

// 每一关的数据
class GameLevelData {
  late String id; // uuid
  late String name;
  // size
  late BoardSize size;
  GameLevelData({
    String? id,
    String? name,
  }) {
    this.id = id ?? const Uuid().v4().toString();
    this.name = name ?? "";
  }

  // step data for level
  Map<int, GameStepData> levelStepData = {};

  // get step data
  GameStepData? getStepData(int step) {
    // get static step data from map
    var data = levelStepData[step];
    if (data != null) {
      return data;
    }
    return null;
    // create a empty step
    // var uuid = const Uuid().v4();
    // return GameStepData(uuid.toString(), size);
  }
}

// 每一步的数据
// 需要保存 board size
// 一共有多少物件
class GameStepData {
  late BoardSize size;
  late String id; // uuid

  // 所有物件
  late List<BlockData> blocks;

  late GamePoint point;

  // 所有行为
  late List<GameActionData> actions;

  GameStepData({
    String? id,
    BoardSize? size,
  }) {
    this.id = id ?? const Uuid().v4().toString();
    this.size = size ?? BoardSize(5, 5);

    blocks = [];
    actions = [];
  }
}

class GameActionData {}
