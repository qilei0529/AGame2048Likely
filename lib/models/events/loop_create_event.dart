import 'dart:math';

import 'package:flutter_game_2048_fight/models/events/effect_enemy_attack_event.dart';

import '../events/effect_hero_attack_event.dart';

import '../events/block_hero_step_hurt_event.dart';
import '../events/floor_green_event.dart';
import '../events/floor_red_event.dart';

import '../util.dart';
import '../game_system.dart';
import '../system/block.dart';
import '../system/board.dart';
import '../system/game.dart';

class LoopCreateEvent extends GameLoopEvent {
  GameSystem system;

  // move
  LoopCreateEvent({required this.system});

  @override
  action(payload) {
    var size = system.size;
    var blocks = system.blocks;
    var level = system.level;
    var step = system.step;
    var floor = system.floor;
    var allTargets = getExtraBlocks(blocks: blocks, size: size);

    List<GameActionData> createActions = [];
    List<BoardItem> createBlocks = [];
    addCreateAction(BoardItem block) {
      var createAction = GameActionData(
        target: block.id,
        type: GameActionType.create,
        position: block.position,
      );
      createAction.level = 3;
      createActions.add(createAction);
    }

    // get step data
    var stepData = level.getStepData(step: step, floor: floor);

    if (stepData != null) {
      print("has new step data: $stepData");

      print(stepData.blocks);

      for (var item in stepData.blocks) {
        var block = item.copy();
        BoardPosition pos;
        if (item.position.x == -1) {
          if (block.type == BlockType.door) {
            pos = getRandomEdge(allTargets.values.toList());
          } else {
            pos = getRandomPos(allTargets.values.toList());
          }
          // remove key vos
          // print("create block at: ${pos.x}, ${pos.y}");
          // remove new key from allTargets
          block.position = pos;
        }
        // remove the pos
        allTargets.remove(getBlockKey(block.position));

        createBlockEvent(block: block, system: system);
        createBlocks.add(block);
        addCreateAction(item);
      }
    } else if (step % 1 == 0) {
      print("create a random block --------------- ");

      // 每次 生成 随机 2个  floor
      var random = Random();
      int num = random.nextInt(2) + 1;

      for (var i = 0; i < num; i++) {
        if (allTargets.isNotEmpty) {
          var pos = getRandomPos(allTargets.values.toList());

          List<BoardItem> list = [];
          list.addAll(blocks);
          list.addAll(createBlocks);
          print("create list length: ${list.length}");
          var item = getRandomBlock(list, size);
          item.position = pos;
          createBlockEvent(block: item, system: system);
          createBlocks.add(item);
          // create
          addCreateAction(item);
        }
      }

      // 每次 生成 随机 个
      var allFloors = getExtraBlocks(blocks: system.floors, size: size);
      int count = Random().nextInt(3);
      print("create floor list length: ${count}");
      if (count > 0) {
        for (var i = 0; i < count; i++) {
          if (allFloors.isNotEmpty) {
            var pos = getRandomPos(allFloors.values.toList());
            var block = BoardItem(
              name: "name",
              type: BlockType.floor,
            );
            block.position = pos;
            allFloors.remove(getBlockKey(pos));
            // 添加事件
            createFloorEvent(block: block, system: system);
            system.addFloor(block);

            var createAction = GameActionData(
              target: block.id,
              type: GameActionType.createFloor,
              position: block.position,
            );
            system.actions.add(createAction);
          }
        }
      }
    }

    createBlocks.forEach((item) => system.addBlock(item));
    if (createActions.isNotEmpty) {
      system.actions.addAll(createActions);
    }
    return null;
  }
}

// var

getRandomBlock(
  List<BoardItem> blocks,
  BoardSize size,
) {
  var type = getRandomTypeSuper(blocks: blocks, size: size);

  var item = BoardItem(
    name: "name",
    type: type,
  );
  var code = "none";
  if (type == BlockType.hero) {
    code = "hero";
  }
  if (type == BlockType.enemy) {
    code = "enemy";
  }
  var random = Random();
  int life = random.nextInt(5) + 1;
  if (type == BlockType.block) {
    code = "rock";
    life = 6;
  }
  if (type == BlockType.element) {
    code = "element";
    life = 4;
  }
  if (type == BlockType.heal) {
    code = "heal";
    life = 3;
  }
  if (type == BlockType.weapon) {
    code = "weapon";
    life = 3;
  }
  item.life = life;
  item.level = 1;
  item.code = code;
  item.act = 1;
  // item.position = pos;
  return item;
}

createFloorEvent({
  required BoardItem block,
  required GameSystem system,
}) {
  // 随机
  var num = Random().nextInt(2);
  if (num == 1) {
    block.code = "red";
    var event = FloorRedEvent(system: system);
    event.type = GameEventType.floor;
    block.events.add(event);
  } else if (num == 0) {
    block.code = "green";
    var event = FloorGreenEvent(system: system);
    event.type = GameEventType.move;
    block.events.add(event);
  }
}

createBlockEvent({
  required BoardItem block,
  required GameSystem system,
}) {
  // 根据 block 的 type
  // 以及 code
  // 添加

  // add hero event
  if (block.type == BlockType.hero) {
    // hero step hurt event
    block.events.add(BlockHeroStepHurtEvent(system: system));
    // hero attack event
    block.events.add(EffectHeroAttackEvent(system: system));
  }
  if (block.type == BlockType.enemy) {
    block.events.add(EffectEnemyAttackEvent(system: system));
    // var event = BlockEnemyExprollEvent(system: system);
    // var random = Random();
    // int maxCount = random.nextInt(3) + 2;
    // event.maxCount = maxCount;
    // event.count = maxCount;
    // block.count = event.count;
    // block.events.add(event);
  }
}

BlockType getRandomTypeSuper({
  required List<BoardItem> blocks,
  required BoardSize size,
}) {
  var list = getBlockTypes(blocks, size);

  if (list.isNotEmpty) {
    var random = Random();
    int index = random.nextInt(list.length);

    return list[index];
  }
  return BlockType.enemy;
}

Map<BlockType, int> defaultMap = {
  BlockType.element: 20,
  BlockType.weapon: 20,
  BlockType.heal: 20,
  BlockType.block: 10,
  BlockType.enemy: 30,
};

List<BlockType> getBlockTypes(List<BoardItem> blocks, BoardSize size) {
  // 获取 每个 type
  Map<BlockType, int> vos = {};

  for (var block in blocks) {
    var item = vos[block.type];
    if (item == null) {
      vos[block.type] = 0;
      item = 0;
    }
    vos[block.type] = item + 1;
  }

  var maxSize = size.width * size.height;
  var total = maxSize;
  List<BlockType> res = [];
  defaultMap.forEach((key, value) {
    if (key != BlockType.enemy) {
      var num = (value / 100 * maxSize).toInt();
      var has = vos[key] ?? 0;
      num = max(0, num - has);
      total -= num;
      for (var i = 0; i < num; i++) {
        res.add(key);
      }
    }
  });
  var enemy = vos[BlockType.enemy] ?? 0;
  total -= enemy;
  print("enemy $total");
  for (var i = 0; i < total; i++) {
    res.add(BlockType.enemy);
  }

  return res;
}

BoardPosition getRandomPos(List<BoardPosition> list) {
  var random = Random();
  int index = random.nextInt(list.length);
  var pos = list[index];
  return pos;
}

BoardPosition getRandomEdge(List<BoardPosition> lists) {
  List<BoardPosition> edgelist = [];
  // ignore: avoid_function_literals_in_foreach_calls
  lists.forEach((pos) {
    if (pos.x == 1 || pos.y == 1) {
      edgelist.add(pos);
    }
  });
  print("edgelist ${edgelist}");
  edgelist.forEach((e) {
    print("${e.x}, ${e.y}");
  });
  var random = Random();
  int index = random.nextInt(edgelist.length);
  var pos = edgelist[index];
  return pos;
}
