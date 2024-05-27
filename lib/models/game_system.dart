// 游戏状态

// step

import 'package:flutter_game_2048_fight/models/step/check_game.dart';

import 'step/check_hero.dart';
import 'step/check_attack.dart';
import 'step/check_create.dart';
import 'step/check_door.dart';
import 'step/check_element.dart';
import 'step/check_merge.dart';
import 'step/check_move.dart';

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
  // list block
  List<BoardItem> get blocks => _vos.values.toList();
  // 记录行为
  final List<GameActionData> actions = [];

  BoardItem? get hero => findBlockByType(BlockType.hero);

  // the step
  int step = 1;
  // the floor
  int floor = 1;

  // 武力值
  int act = 10;

  // 体力值
  int sta = 10;

  // 初始化
  GameSystem() {
    print("world init");
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

    print("load level $level");
  }

  toFloor(int nextFloor) {
    print("to floor $nextFloor");
    floor = nextFloor;

    this.act = 10;
    this.sta = 10;
  }

  toStep(int step) {
    print("to step $step");
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

  addBlock(BoardItem block) {
    if (_vos[block.id] != null) {
      print("has block exist ${block.id}");
    }
    _vos[block.id] = block;
  }

  removeBlock(BoardItem block) {
    _vos.remove(block.id);
  }

  gameStart() {
    status = GameStatus.start;
  }

  gamePause() {
    status = GameStatus.pause;
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

  actionSlide(GamePoint point) {
    checkMovePoint(
      point: point,
      onStep: (block) {
        checkBlockStep(block);
      },
    );
  }

  checkBlockStep(BoardItem block) {
    List<GameActionData> tempActions;
    // 融合
    tempActions = checkMergeStep(
      leftBlock: block,
      system: this,
    );
    if (tempActions.isNotEmpty) {
      print("has merge step $tempActions");
      actions.addAll(tempActions);
      return;
    }

    // 道具
    tempActions = checkElementStep(
      leftBlock: block,
      system: this,
    );
    if (tempActions.isNotEmpty) {
      print("has element step $tempActions");
      actions.addAll(tempActions);
      return;
    }

    // 门
    tempActions = checkDoorStep(
      leftBlock: block,
      system: this,
    );
    if (tempActions.isNotEmpty) {
      print("has door step $tempActions");
      actions.addAll(tempActions);
      return;
    }

    // 主角 攻击
    tempActions = checkHeroStep(
      leftBlock: block,
      system: this,
    );
    if (tempActions.isNotEmpty) {
      print("has attack step $tempActions");
      actions.addAll(tempActions);
      return;
    }

    // 攻击
    tempActions = checkAttackStep(
      leftBlock: block,
      system: this,
    );
    if (tempActions.isNotEmpty) {
      print("has attack step $tempActions");
      actions.addAll(tempActions);
      return;
    }
  }

  checkStepForNext() {
    // go next step
    var tempActions = checkGameStep(system: this);
    if (tempActions.isNotEmpty) {
      print("has game step $tempActions");
      actions.addAll(tempActions);
    }

    var [createActions, createBlocks] = checkCreateStep(
      blocks: blocks,
      size: size,
      level: level,
      step: step,
      floor: floor,
    );

    // create Block
    createBlocks.forEach((item) => addBlock(item));
    if (createActions.isNotEmpty) {
      actions.addAll(createActions);
    }
  }

  checkMovePoint({
    required GamePoint point,
    int? actionLevel,
    Function? onStep,
  }) {
    var tempActions = checkMoveStep(
      point: point,
      blocks: blocks,
      size: size,
      actionLevel: actionLevel,
      onStep: onStep,
    );
    if (tempActions.isNotEmpty) {
      actions.addAll(tempActions);
    }
  }
}
