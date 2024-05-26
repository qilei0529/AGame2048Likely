import 'dart:math';

import 'package:flutter_game_2048_fight/models/system/block.dart';
import 'package:flutter_game_2048_fight/models/system/board.dart';
import 'package:flutter_game_2048_fight/models/system/game.dart';
import 'package:flutter_game_2048_fight/models/util.dart';

checkCreateStep({
  // required GamePoint point,
  required List<BoardItem> blocks,
  required BoardSize size,
  required GameLevelData level,
  required int step,
  required int floor,
}) {
  var allTargets = getExtraBlocks(blocks: blocks);

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
    var random = Random();
    int index = random.nextInt(list.length);
    var pos = list[index];
    allTargets.remove(getBlockKey(pos));
    return pos;
  }

  getRandomType() {
    var random = Random();
    int index = random.nextInt(10) + 1;
    if (index > 8) {
      return BlockType.block;
    }
    if (index > 4) {
      return BlockType.element;
    }

    return BlockType.enemy;
  }

  List<GameActionData> createActions = [];
  List<BoardItem> createBlocks = [];
  addCreateAction(BoardItem block) {
    var createAction = GameActionData(
      target: block.id,
      type: GameActionType.create,
      position: block.position,
    );
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
      print("create block at: ${pos.x}, ${pos.y}");
      // remove new key from allTargets
      item.position = pos;

      createBlocks.add(item.copy());
      addCreateAction(item);
    }
  } else if (step % 2 == 0) {
    print("create --------------- ");

    var type = getRandomType();
    var code = BlockMergeCode.none;
    if (type == BlockType.hero) {
      code = BlockMergeCode.hero;
    }
    if (type == BlockType.enemy) {
      code = BlockMergeCode.enemy;
    }
    var pos = getRandomPos();

    var item = BoardItem(
      name: "name",
      type: type,
    );
    var random = Random();
    int life = random.nextInt(6) + 1;
    if (type == BlockType.block) {
      life = 5;
    }
    if (type == BlockType.door) {
      life = 5;
    }
    if (type == BlockType.element) {
      if (life == 1) {
        code = BlockMergeCode.weapon;
      } else {
        code = BlockMergeCode.element;
      }
    }
    item.life = life;
    item.level = 1;
    item.code = code;

    item.act = 1;
    item.position = pos;
    // add block to system
    // addBlock(item);
    createBlocks.add(item);
    // create
    addCreateAction(item);
  }

  return [createActions, createBlocks];
}
