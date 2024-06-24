// 游戏状态

// step

import 'package:flutter_game_2048_fight/models/events/loop_status_event.dart';

import 'util.dart';

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
  final Map<String, BoardItem> _blockVos = {};

  // 所有 地砖
  final Map<String, BoardItem> _floorVos = {};
  // 所有 效果块
  final Map<String, BoardItem> _effectVos = {};

  // 临时存当前 block 位置
  final Map<String, BoardItem> _posMap = {};

  // list block
  List<BoardItem> get blocks => _blockVos.values.toList();
  // list floors
  List<BoardItem> get floors => _floorVos.values.toList();
  // list effects
  List<BoardItem> get effects => _effectVos.values.toList();

  // pos vos
  Map<String, BoardItem> get blockPosVos => getBlockPosVos(blocks: blocks);
  Map<String, BoardItem> get floorPosVos => getBlockPosVos(blocks: floors);

  // action list
  final List<GameActionData> actions = [];

  // 事件
  List<GameEvent> loopEvents = [];
  List<GameEvent> moveEvents = [];

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
  int sta = 0;

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
      // BlockEnemyMixinEvent(system: this),
    ];
    eventMap[BlockType.element] = [
      // BlockEnemyMixinEvent(system: this),
    ];

    // 移动
    moveEvents = [
      MovePointEvent(system: this),
      MoveForwardEvent(system: this),
    ];

    // 回合事件
    loopEvents = [
      LoopStepEvent(system: this),
      LoopCreateEvent(system: this),
      LoopStatusEvent(system: this),
    ];
  }

  BoardItem? findBlockByType(BlockType targetType) {
    BoardItem? result;
    _blockVos.forEach((key, value) {
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
    print("step: $step");
    this.step = step;
    // 运行
    var event = LoopCreateEvent(system: this);
    event.action(GameLoopPayload());

    print("blocks: $blocks");
    print("floors: $floors");
  }

  BoardItem? getFloor(String id) {
    return _floorVos[id];
  }

  BoardItem? getBlock(String id) {
    return _blockVos[id];
  }

  BoardItem? getEffect(String id) {
    return _effectVos[id];
  }

  addFloor(BoardItem block) {
    if (_floorVos[block.id] != null) {
      // ignore: avoid_print
      print("has floor exist ${block.id}");
    }
    _floorVos[block.id] = block;
  }

  removeFloor(BoardItem block) {
    _floorVos.remove(block.id);
  }

  BoardItem? getFloorAt(BoardPosition position) {
    var key = getBlockKey(position);
    return floorPosVos[key];
  }

  BoardItem? getBlockAt(BoardPosition position) {
    var key = getBlockKey(position);
    return blockPosVos[key];
  }

  addEffect(BoardItem block) {
    if (_effectVos[block.id] != null) {
      // ignore: avoid_print
      print("has effect exist ${block.id}");
    }
    _effectVos[block.id] = block;
  }

  addBlock(BoardItem block) {
    if (_blockVos[block.id] != null) {
      // ignore: avoid_print
      print("has block exist ${block.id}");
    }
    _blockVos[block.id] = block;
  }

  removeBlock(BoardItem block) {
    _blockVos.remove(block.id);
  }

  removeEffect(BoardItem block) {
    _effectVos.remove(block.id);
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
    _blockVos.clear();
    _floorVos.clear();
    _effectVos.clear();

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
    status = GameStatus.next;
    // 过滤出 hero
    var hero =
        _blockVos.values.firstWhere((block) => block.type == BlockType.hero);

    // clear
    _blockVos.clear();
    // clear
    _floorVos.clear();

    // add the hero to next level
    if (hero != null) {
      addBlock(hero);

      var createAction = GameActionData(
        target: hero.id,
        type: GameActionType.create,
        position: hero.position,
      );
      // add create action
      actions.addAll([createAction]);
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

  runLoopEvents() {
    // 获取 所有 方向的 block
    // ignore: avoid_print
    var events = loopEvents;
    events.forEach((item) {
      var event = item as GameLoopEvent;
      var payload = GameLoopPayload();
      event.action(payload);
    });
    // ignore: avoid_print
    print("finish ");
  }

  runMoveEvents(GamePoint point) {
    // 获取 所有 方向的 block
    var blocklist = getRangeBlocks(blocks, point);
    // ignore: avoid_print
    var events = moveEvents;
    _posMap.clear();
    for (var block in blocklist) {
      // ignore: avoid_function_literals_in_foreach_calls
      events.forEach((item) {
        var event = item as GameMoveEvent;
        var payload = GameMovePayload(block, point);
        event.action(payload);
      });
    }
    // ignore: avoid_print
    print("finish move $point $actions");
  }

  runMove2Events(GamePoint point) {
    // 获取 所有 方向的 block
    _posMap.clear();
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

  // 执行 效果 事件。
  runEffectEvents() {
    // ignore: avoid_print
    print("start effect $effects");
    for (var effect in effects) {
      // 运行 所有 move Event
      var block = getBlockAt(effect.position);
      if (block != null) {
        var events = effect.events;
        if (events.isNotEmpty) {
          // ignore: avoid_function_literals_in_foreach_calls
          events.forEach((item) {
            var event = item as GameBlockEvent;
            var payload = GameBlockPayload(block);
            event.action(payload);
          });
        }
      }
    }
    // ignore: avoid_print
    print("finish effect");
  }

  runCoolBlockEvents(GamePoint point) {
    // 获取 所有 方向的 block
    var blocklist = getRangeBlocks(blocks, point);
    // ignore: avoid_print
    print("start $point");
    for (var block in blocklist) {
      // 运行 所有 block Event
      var events = block.events
          .where((event) => event.type == GameEventType.block)
          .toList();
      if (events.isNotEmpty) {
        // ignore: avoid_function_literals_in_foreach_calls
        events.forEach((item) {
          var event = item as GameBlockEvent;
          var payload = GameBlockPayload(block);
          event.action(payload);
        });
      }
    }
    // ignore: avoid_print
    print("finish $point");
  }

  runFloorEvents() {
    // 获取 所有 方向的 block
    // ignore: avoid_print
    print("start floor events");
    for (var block in floors) {
      // 运行 所有 block Event
      var events = block.events
          .where((event) => event.type == GameEventType.floor)
          .toList();
      // has
      if (events.isNotEmpty) {
        // ignore: avoid_function_literals_in_foreach_calls
        events.forEach((item) {
          var event = item as GameBlockEvent;
          var payload = GameBlockPayload(block);
          event.action(payload);
        });
      }
      // ignore: avoid_function_literals_in_foreach_calls
    }
    // ignore: avoid_print
    print("finish");
  }
}

List<BoardItem> getRangeBlocks(List<BoardItem> blocks, GamePoint point) {
  // 获取 排序
  List<BoardItem> blocklist = [];
  // 获取 位置 map 地图
  for (var block in blocks) {
    // not dead
    if (!block.isDead) {
      blocklist.add(block);
    }
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
