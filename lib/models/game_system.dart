// 游戏状态

import 'package:flutter_game_2048_fight/models/step/check_attack.dart';
import 'package:flutter_game_2048_fight/models/step/check_create.dart';
import 'package:flutter_game_2048_fight/models/step/check_door.dart';
import 'package:flutter_game_2048_fight/models/step/check_element.dart';
import 'package:flutter_game_2048_fight/models/step/check_merge.dart';
import 'package:flutter_game_2048_fight/models/step/check_move.dart';

import 'system/game.dart';
import 'system/block.dart';
import 'system/board.dart';

class GameSystem {
  late GameLevelData level;

  // 当前 步骤
  int step = 0;

  // 体力值
  int stamina = 0;

  // 游戏状态
  GameStatus status = GameStatus.start;
  // 所有 block
  final Map<String, BoardItem> _vos = {};
  // list block
  List<BoardItem> get blocks => _vos.values.toList();
  // 记录行为
  final List<GameActionData> actions = [];

  late BoardSize size;

  // 初始化
  GameSystem() {
    print("world init");
  }

  // 更新 level
  setLevel(GameLevelData level) {
    this.level = level;
    // update size
    size = level.size;

    jumpToStep(0);
  }

  jumpToStep(int step) {
    var step = level.getStepData(0);
    if (step != null) {
      for (var block in step.blocks) {
        addBlock(block.copy());
      }
    }
  }

  addBlock(BoardItem block) {
    if (_vos[block.id] != null) {
      print("has block exist ${block.id}");
    }
    _vos[block.id] = block;
  }

  BoardItem? getBlock(String id) {
    return _vos[id];
  }

  removeBlock(BoardItem block) {
    _vos.remove(block.id);
  }

  addAction(GameActionData action) {
    actions.add(action);
  }

  gameStart() {
    status = GameStatus.play;
  }

  gamePause() {
    status = GameStatus.pause;
  }

  gameOver() {
    status = GameStatus.end;
  }

  gameRestart() {
    status = GameStatus.start;
    step = 0;
    actions.clear();
    _vos.clear();

    jumpToStep(0);
  }

  actionSlide(GamePoint point) {
    checkMovePoint(point);
  }

  checkStep() {
    // go next step
    step += 1;
    var [
      createActions,
      createBlocks,
    ] = checkCreateStep(blocks: blocks, size: size, level: level, step: step);

    createBlocks.forEach((item) => addBlock(item));
    actions.addAll(createActions);
  }

  // 融合
  checkMerge() {
    var tempActions = checkMergeStep(blocks: blocks, size: size);
    if (tempActions.isNotEmpty) {
      actions.addAll(tempActions);
    }
  }

  // check if need attack
  checkElement() {
    var tempActions = checkElementStep(
      blocks: blocks,
      size: size,
    );
    if (tempActions.isNotEmpty) {
      actions.addAll(tempActions);
    }
  }

  checkDoor() {
    var tempActions = checkDoorStep(
      blocks: blocks,
      size: size,
    );
    if (tempActions.isNotEmpty) {
      actions.addAll(tempActions);
    }
  }

  // check if need attack
  checkAttack() {
    var tempActions = checkAttackStep(
      blocks: blocks,
      size: size,
    );
    if (tempActions.isNotEmpty) {
      actions.addAll(tempActions);
    }
  }

  checkMovePoint(GamePoint point) {
    var tempActions = checkMoveStep(
      point: point,
      blocks: blocks,
      size: size,
    );
    if (tempActions.isNotEmpty) {
      actions.addAll(tempActions);
    }
  }
}
