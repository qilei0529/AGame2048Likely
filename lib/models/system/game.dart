import 'package:flutter_game_2048_fight/models/system/level.dart';
import 'package:flutter_game_2048_fight/models/util.dart';
import 'package:uuid/uuid.dart';

import 'board.dart';
import 'block.dart';

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
  late BoardSize size = globalGameSize;

  GameLevelData({
    String? id,
    String? name,
  }) {
    this.id = id ?? const Uuid().v4().toString();
    this.name = name ?? "";
  }

  // step data for level
  // Map<String, GameStepData> levelStepData = {};

  Map<String, GameFloorData> levelFloorData = {};

  GameFloorData? getFloorData(int floor) {
    print("get floor data $floor");
    return levelFloorData["F_$floor"];
  }

  // get step data
  GameStepData? getStepData(
      {required int step, required int floor, List<BoardItem>? blocks}) {
    // get static step data from map

    var floorData = getFloorData(floor);
    if (floorData != null) {
      var data = floorData.steps["${floor}_$step"];
      if (data != null) {
        return getGameStepData(
          item: floorData.steps["${floor}_$step"],
          leftBlocks: blocks,
          size: size,
        );
      }
    }
    return null;
  }
}

class GameFloorData {
  late String title;
  Map<String, dynamic> steps = {};

  GameFloorData({
    required this.title,
  });
}

// 每一步的数据
// 需要保存 board size
// 一共有多少物件
class GameStepData {
  late BoardSize size;
  late String id; // uuid

  // 所有物件
  late Map<String, BoardItem> vos;

  late GamePoint point;

  List<BoardItem> get blocks => vos.values.toList();

  GameStepData({
    String? id,
    BoardSize? size,
  }) {
    this.id = id ?? const Uuid().v4().toString();
    this.size = size ?? globalGameSize;

    vos = {};
  }

  addBlock(BoardItem block) {
    vos[block.id] = block;
  }
}

// 游戏场景
enum GameActionType {
  // 转身
  turn,
  // 移动
  move,
  // 移动
  moveIn,
  // 进入
  enter,

  // 攻击
  attack,

  // 受伤
  injure,

  // 死亡
  fade,

  // 死亡
  dead,

  // 恢复
  heal,

  // 新建
  create,

  // 升级
  upgrade,
  // 吸收
  absorbed,
}

class GameActionData {
  String target;
  GameActionType type;

  late int level;

  GamePoint? point;
  BoardPosition? position;

  int? value;
  int? life;

  String? toTarget;

  GameActionData({
    required this.target,
    required this.type,
    this.point,
    this.position,
    this.toTarget,
    this.value,
    this.life,
  }) {
    //
    level = 2;
  }
}

enum GameEventType {
  // 移动 事件
  move,
  // 块 事件
  block,
  // 冷却 事件
  cooling,

  // 回合 事件
  loop,
}

abstract class GameEvent<T> {
  GameEventType type;

  bool? action(T payload);
  void clear();

  GameEvent({required this.type});
}

class GameLoopPayload {
  GameLoopPayload();
}

class GameLoopEvent extends GameEvent<GameLoopPayload> {
  // move
  GameLoopEvent() : super(type: GameEventType.block);
  @override
  bool? action(payload) {
    return null;
  }

  @override
  void clear() {}
}

class GameBlockPayload {
  BoardItem block;
  GameBlockPayload(this.block);
}

class GameBlockEvent extends GameEvent<GameBlockPayload> {
  // move
  GameBlockEvent() : super(type: GameEventType.block);
  @override
  bool? action(payload) {
    return null;
  }

  @override
  void clear() {}
}

class GameMovePayload {
  BoardItem block;
  GamePoint point;
  GameMovePayload(this.block, this.point);
}

class GameMoveEvent extends GameEvent<GameMovePayload> {
  GameMoveEvent() : super(type: GameEventType.move);

  @override
  bool? action(payload) {
    return null;
  }

  @override
  void clear() {}
}
