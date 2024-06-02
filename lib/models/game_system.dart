// 游戏状态

// step

import 'events/loop_create_event.dart';
import 'events/loop_step_event.dart';
//
import 'events/block_door_event.dart';
import 'events/block_hero_event.dart';
import 'events/block_element_event.dart';
import 'events/block_enemy_event.dart';
import 'events/block_enemy_mixin_event.dart';
//
import 'events/move_forward_event.dart';
import 'events/move_point_event.dart';

// system
import 'system/level.dart';

import 'system/game.dart';
import 'system/block.dart';
import 'system/board.dart';

class GameSystem {
  GameLevelData level = GameLevelData();

  // the size will sync by level;
  late BoardSize size;

  // 游戏状态
  GameStatus status = GameStatus.start;
  // 所有 block
  final Map<String, BoardItem> _vos = {};
  // 所有 block
  final Map<String, BoardItem> _ground = {};

  // 临时存当前 block 位置
  final Map<String, BoardItem> _posMap = {};

  // list block
  List<BoardItem> get blocks => _vos.values.toList();

  // action list
  final List<GameActionData> actions = [];

  // 事件
  List<GameEvent> loopEvents = [];
  List<GameEvent> moveEvents = [];
  List<GameEvent> floorEvents = [];

  // block eventMap
  final Map<BlockType, List<GameEvent>> eventMap = {};

  BoardItem? get hero => findBlockByType(BlockType.hero);

  // the step
  int step = 1;
  // the floor
  int floor = 1;

  // 武力值
  int act = 0;

  // 体力值
  int sta = 10;

  // 初始化
  GameSystem() {
    // ignore: avoid_print
    print("world init");
    initEventMap();
  }

  initEventMap() {
    eventMap[BlockType.hero] = [
      BlockElementEvent(system: this),
      BlockHeroEvent(system: this),
      BlockEnemyEvent(system: this),
      BlockDoorEvent(system: this),
    ];
    eventMap[BlockType.enemy] = [
      BlockEnemyMixinEvent(system: this),
      BlockEnemyEvent(system: this),
    ];
    eventMap[BlockType.weapon] = [
      BlockEnemyMixinEvent(system: this),
    ];
    eventMap[BlockType.heal] = [
      BlockEnemyMixinEvent(system: this),
    ];
    eventMap[BlockType.element] = [
      BlockEnemyMixinEvent(system: this),
    ];

    // 移动
    moveEvents = [
      MovePointEvent(system: this),
      MoveForwardEvent(system: this),
    ];
    loopEvents = [
      LoopStepEvent(system: this),
      LoopCreateEvent(system: this),
    ];
  }

  BoardItem? findBlockByType(BlockType targetType) {
    BoardItem? result;
    _vos.forEach((key, value) {
      if (value.type == targetType) {
        result = value;
      }
    });
    return result;
  }

  // 更新 level
  loadLevel(String path) async {
    // this.level = level;
    // update size
    // size = level.size;
    var levelData = await loadLevelData(path: path);
    level = levelData;

    // sync the size
    size = level.size;
  }

  toFloor(int nextFloor) {
    floor = nextFloor;
  }

  toStep(int step) {
    this.step = step;
    var stepData = level.getStepData(
      step: step,
      floor: floor,
      blocks: blocks,
    );
    if (stepData != null) {
      for (var block in stepData.blocks) {
        addBlock(block.copy());
      }
    }
  }

  BoardItem? getBlock(String id) {
    return _vos[id];
  }

  createBlock() {}

  addBlock(BoardItem block) {
    if (_vos[block.id] != null) {
      // ignore: avoid_print
      print("has block exist ${block.id}");
    }
    _vos[block.id] = block;
  }

  removeBlock(BoardItem block) {
    _vos.remove(block.id);
  }

  addAction(GameActionData action) {
    actions.add(action);
  }

  gameStart() {
    status = GameStatus.start;
  }

  gameOver() {
    status = GameStatus.end;
  }

  gameRestart() {
    status = GameStatus.start;
    // clean blocks
    _vos.clear();
    // clean actions
    actions.clear();

    toFloor(1);
    toStep(1);

    // 携带攻击力
    act = 0;
    // 携带体力
    sta = 10;
  }

  BoardItem? getPosMap(String key) {
    return _posMap[key];
  }

  setPosMap(String key, BoardItem block) {
    _posMap[key] = block;
  }

  actionNextFloor() {
    status = GameStatus.start;

    // 过滤出 hero
    var hero = _vos.values.firstWhere((block) => block.type == BlockType.hero);
    _vos.clear();
    // add the hero to next level
    if (hero != null) {
      addBlock(hero);
    }

    toFloor(floor + 1);
    toStep(1);
  }

  List<GameEvent> getEventsByType(BlockType type, GameEventType eventType) {
    var events = eventMap[type];
    if (events != null) {
      var list = events.where((event) => event.type == eventType).toList();
      if (list.isNotEmpty) {
        return list;
      }
    }
    return [];
  }

  runLoopEvents(GamePoint point) {
    // 获取 所有 方向的 block
    // ignore: avoid_print
    var events = loopEvents;
    events.forEach((item) {
      var event = item as GameLoopEvent;
      var payload = GameLoopPayload();
      event.action(payload);
    });
    // ignore: avoid_print
    print("finish $point");
  }

  runMoveEvents(GamePoint point) {
    // 获取 所有 方向的 block
    var blocklist = getRangeBlocks(blocks, point);
    // ignore: avoid_print
    var events = moveEvents;
    for (var block in blocklist) {
      // ignore: avoid_function_literals_in_foreach_calls
      events.forEach((item) {
        var event = item as GameMoveEvent;
        var payload = GameMovePayload(block, point);
        event.action(payload);
      });
    }
    _posMap.clear();
    // ignore: avoid_print
    print("finish $point");
  }

  runMove2Events(GamePoint point) {
    // 获取 所有 方向的 block
    var blocklist = getRangeBlocks(blocks, point);
    // ignore: avoid_print
    var events = [
      MoveForwardEvent(system: this),
    ];
    for (var block in blocklist) {
      // ignore: avoid_function_literals_in_foreach_calls
      events.forEach((item) {
        var event = item as GameMoveEvent;
        var payload = GameMovePayload(block, point);
        event.action(payload);
      });
    }
    _posMap.clear();
    // ignore: avoid_print
    print("finish $point");
  }

  runBlockEvents(GamePoint point) {
    // 获取 所有 方向的 block
    var blocklist = getRangeBlocks(blocks, point);
    // ignore: avoid_print
    print("start $point");
    for (var block in blocklist) {
      // 运行 所有 move Event
      bool? flag;
      var events = getEventsByType(block.type, GameEventType.block);
      // ignore: avoid_function_literals_in_foreach_calls
      events.forEach((item) {
        var event = item as GameBlockEvent;
        var payload = GameBlockPayload(block);
        // 只要命中一个就跳出 类似 switch
        if (flag != true) {
          flag = event.action(payload);
        }
      });
    }
    // ignore: avoid_print
    print("finish $point");
  }
}

List<BoardItem> getRangeBlocks(List<BoardItem> blocks, GamePoint point) {
  // 获取 排序
  List<BoardItem> blocklist = [];
  // 获取 位置 map 地图
  for (var element in blocks) {
    blocklist.add(element);
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
  return blocklist;
}
