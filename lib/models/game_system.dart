// 游戏状态

// step
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

  // 当前 步骤
  int step = 1;

  int floor = 1;

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

  late BoardSize size = BoardSize(5, 5);

  // 初始化
  GameSystem() {
    print("world init");
  }

  // 更新 level
  loadLevel(String path) async {
    // this.level = level;
    // update size
    // size = level.size;
    var levelData = await loadLevelData(path: path);
    level = levelData;
    print("load level $level");
  }

  toFloor(int floor) {
    print("to floor $floor");
    this.floor = floor;
  }

  toStep(int step) {
    print("to step $step");
    var stepData = level.getStepData("${floor}_$step");
    if (stepData != null) {
      for (var block in stepData.blocks) {
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
    toFloor(1);
    toStep(1);
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

    toFloor(1);
    toStep(1);
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
    ] = checkCreateStep(
      blocks: blocks,
      size: size,
      level: level,
      step: step,
      floor: floor,
    );

    createBlocks.forEach((item) => addBlock(item));
    if (createActions.isNotEmpty) {
      actions.addAll(createActions);
    }
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
