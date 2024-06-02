import 'dart:math';

import 'package:flutter_game_2048_fight/models/events/block_hero_step_hurt_event.dart';

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

    BoardPosition getRandomPos() {
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
      var random = Random();
      int index = random.nextInt(list.length);
      var pos = list[index];
      allTargets.remove(getBlockKey(pos));
      return pos;
    }

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
        BoardPosition pos;
        if (item.type == BlockType.door) {
          pos = getRandomEdge();
        } else {
          pos = getRandomPos();
        }
        // print("create block at: ${pos.x}, ${pos.y}");
        // remove new key from allTargets
        item.position = pos;

        var block = item.copy();
        // add hero event
        if (block.type == BlockType.hero) {
          block.events.add(BlockHeroStepHurtEvent(system: system));
        }
        createBlocks.add(block);
        addCreateAction(item);
      }
    } else if (step % 1 == 0) {
      print("create a random block --------------- ");

      // 每次 生成 随机 3个
      var random = Random();
      int num = random.nextInt(2) + 1;

      for (var i = 0; i < num; i++) {
        if (allTargets.isNotEmpty) {
          var pos = getRandomPos();

          List<BoardItem> list = [];
          list.addAll(blocks);
          list.addAll(createBlocks);
          print("create list length: ${list.length}");
          var item = getRandomBlock(list, size);
          item.position = pos;
          // allTargets.remove(key)
          createBlocks.add(item);
          // create
          addCreateAction(item);
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
  var code = BlockMergeCode.none;
  if (type == BlockType.hero) {
    code = BlockMergeCode.hero;
  }
  if (type == BlockType.enemy) {
    code = BlockMergeCode.enemy;
  }
  var random = Random();
  int life = random.nextInt(5) + 1;
  if (type == BlockType.block) {
    code = BlockMergeCode.rock;
    life = 6;
  }
  if (type == BlockType.element) {
    code = BlockMergeCode.element;
    life = 4;
  }
  if (type == BlockType.heal) {
    code = BlockMergeCode.heal;
    life = 3;
  }
  if (type == BlockType.weapon) {
    code = BlockMergeCode.weapon;
    life = 3;
  }
  item.life = life;
  item.level = 1;
  item.code = code;
  item.act = 1;
  // item.position = pos;
  return item;
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