// 游戏状态
import 'dart:math';

import 'system/game.dart';
import 'system/block.dart';
import 'system/board.dart';

class GameSystem {
  late GameLevelData level;

  // 当前 步骤
  int step = 0;
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

  actionAdd() {}
  actionUpdate() {}
  actionConfig() {}
  actionNext() {}

  stepAdd() {}
  stepCheck() {}

  //
  Map<String, BoardItem> getBlockPosVos() {
    // 获取 位置 map 地图
    Map<String, BoardItem> posVos = {};
    for (var element in blocks) {
      var key = getBlockKey(element.position);
      posVos[key] = element;
    }
    return posVos;
  }

  Map<String, BoardPosition> getExtraBlocks() {
    Map<String, BoardPosition> allTargets = {};

    // 创建 5x5 格子
    for (int x = 1; x < 6; x++) {
      for (int y = 1; y < 6; y++) {
        var pos = BoardPosition(x, y);
        var key = getBlockKey(pos);
        allTargets[key] = pos;
      }
    }
    // remove existe block
    var posVos = getBlockPosVos();
    posVos.forEach((key, value) {
      allTargets.remove(key);
    });
    return allTargets;
  }

  checkStep() {
    // go next step
    step += 1;

    var allTargets = getExtraBlocks();

    getRandomPos() {
      List<BoardPosition> list = allTargets.values.toList();
      var random = Random();
      int index = random.nextInt(list.length);
      var pos = list[index];
      allTargets.remove(getBlockKey(pos));
      return pos;
    }

    List<GameActionData> createActions = [];
    addCreateAction(BoardItem block) {
      var createAction = GameActionData(
        target: block.id,
        type: GameActionType.create,
        position: block.position,
      );
      createActions.add(createAction);
    }

    // get step data
    var stepData = level.getStepData(step);

    if (stepData != null) {
      print("has new step data: $stepData");

      print(stepData.blocks);

      for (var item in stepData.blocks) {
        var pos = getRandomPos();
        print("create block at: ${pos.x}, ${pos.y}");
        // remove new key from allTargets
        item.position = pos;

        // add action
        addBlock(item.copy());
        addCreateAction(item);
      }
    } else if (step % 3 == 0) {
      print("create --------------- ");
      var random = Random();
      int index = random.nextInt(5) + 1;

      var type = index == 5 ? BlockType.block : BlockType.enemy;
      var item = BoardItem(
        name: "name",
        type: type,
      );
      item.life = index;
      item.level = 1;
      item.code = BlockMergeCode.enemy;
      item.act = 1;
      item.position = getRandomPos();
      // add block to system
      addBlock(item);
      // create
      addCreateAction(item);
    }

    actions.addAll(createActions);
  }

  // 融合
  checkMerge() {
    var vos = getBlockPosVos();

    List<GameActionData> tempActions = [];

    for (var leftBlock in blocks) {
      var point = leftBlock.point;
      // 获取 block 射程范围内 是否有 对象
      var attackPoisiton = point.addPosition(leftBlock.position);

      var key = getBlockKey(attackPoisiton);
      var rightBlock = vos[key];
      if (rightBlock != null) {
        var canMerge = false;
        print("has block on ${key}");

        if (checkBlockCanMove(leftBlock.type)) {
          if (leftBlock.code == rightBlock.code) {
            if (leftBlock.level == rightBlock.level) {
              canMerge = true;
            }
          }
        }

        if (canMerge) {
          // turnAction
          leftBlock.isDead = true;
          var eatAction = GameActionData(
            target: leftBlock.id,
            type: GameActionType.absorbed,
          );
          tempActions.add(eatAction);

          rightBlock.level += leftBlock.level;
          rightBlock.life += leftBlock.life;
          var upgradeAction = GameActionData(
            target: rightBlock.id,
            type: GameActionType.upgrade,
            value: rightBlock.level,
            life: rightBlock.life,
          );
          tempActions.add(upgradeAction);
        }
      }
    }

    actions.addAll(tempActions);
  }

  // check if need attack
  checkAttack() {
    var vos = getBlockPosVos();

    List<GameActionData> tempActions = [];

    for (var leftBlock in blocks) {
      var point = leftBlock.point;
      // 获取 block 射程范围内 是否有 对象
      var attackPoisiton = point.addPosition(leftBlock.position);

      var key = getBlockKey(attackPoisiton);
      var rightBlock = vos[key];
      if (rightBlock != null) {
        var canAttack = false;
        print("has block on ${key}");

        if (checkBlockCanAttack(leftBlock.type, rightBlock.type)) {
          canAttack = true;
        }

        if (canAttack) {
          // act from leftBlock
          print("leftBlock act ---- ${leftBlock.act}");
          var act = leftBlock.act;

          // turnAction
          var attackAction = GameActionData(
            target: leftBlock.id,
            type: GameActionType.attack,
            toTarget: rightBlock.id,
            value: act,
          );

          tempActions.add(attackAction);

          var rightLife = max(0, rightBlock.life - act);
          rightBlock.life = rightLife;

          var injureAction = GameActionData(
            target: rightBlock.id,
            type: GameActionType.injure,
            value: act,
            life: rightLife,
          );
          tempActions.add(injureAction);

          if (rightLife == 0) {
            rightBlock.isDead = true;
            var deadAction = GameActionData(
              target: rightBlock.id,
              type: GameActionType.dead,
            );
            tempActions.add(deadAction);

            var heal = 1;
            leftBlock.life += heal;
            var healAction = GameActionData(
              target: leftBlock.id,
              type: GameActionType.heal,
              life: leftBlock.life,
              value: heal,
            );
            tempActions.add(healAction);
          }
        }
      }
    }

    actions.addAll(tempActions);
  }

  checkMovePoint(GamePoint point) {
    List<GameActionData> turnActions = [];
    List<GameActionData> moveActions = [];

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

    Map<String, BoardItem> tempVos = {};

    checkBlockPoint(BoardItem leftBlock, GamePoint point) {
      // 获取 某一个方向上的位置。
      BoardPosition getPointPosition(BoardPosition pos) {
        // 判断是否可以移动
        if (!checkBlockCanMove(leftBlock.type)) {
          return pos;
        }
        // 获取 新位置
        var newPos = point.addPosition(pos);
        // 判断 新位置是否到边界
        var isEdge = checkSizeEdge(newPos, size);
        // 返回 当前 pos
        if (isEdge) {
          return pos;
        } else {
          // 判断 当前位置是否 有对象
          var key = getBlockKey(newPos);
          var rightBlock = tempVos[key];
          if (rightBlock != null) {
            return pos;
          }
          return getPointPosition(newPos);
        }
      }

      // get new pos by pos;
      var pos = getPointPosition(leftBlock.position);

      if (point != leftBlock.point) {
        // change the data
        leftBlock.point = point;
        // turnAction
        var turnAction = GameActionData(
          target: leftBlock.id,
          type: GameActionType.turn,
          point: point,
        );
        turnActions.add(turnAction);
      }
      // is dif pos; need to move;
      if (!isEqualPosition(pos, leftBlock.position)) {
        // change the pos
        leftBlock.position = pos;
        // moveActions
        var moveAction = GameActionData(
          target: leftBlock.id,
          type: GameActionType.move,
          point: point,
          position: pos,
        );
        moveActions.add(moveAction);
      }

      var key = getBlockKey(pos);
      tempVos[key] = leftBlock;
    }

    for (var block in blocklist) {
      checkBlockPoint(block, point);
    }
    actions.addAll(turnActions);
    actions.addAll(moveActions);
  }
}

String getBlockKey(BoardPosition pos) {
  return "B_${pos.x}_${pos.y}";
}

bool checkBlockCanMove(BlockType type) {
  if (type == BlockType.hero || type == BlockType.enemy) {
    return true;
  }
  return false;
}

bool checkBlockCanAttack(BlockType typeA, BlockType typeB) {
  if (typeA == BlockType.hero || typeA == BlockType.enemy) {
    if (typeA != typeB) {
      return true;
    }
  }

  return false;
}

bool checkBlockCanMerge(BlockType typeA, BlockType typeB) {
  if (typeA == BlockType.hero || typeA == BlockType.enemy) {
    if (typeA != typeB) {
      return true;
    }
  }

  return false;
}

bool checkSizeEdge(BoardPosition pos, BoardSize size) {
  if (pos.x <= 0) {
    return true;
  }
  if (pos.x > size.width) {
    return true;
  }
  if (pos.y <= 0) {
    return true;
  }
  if (pos.y > size.height) {
    return true;
  }
  return false;
}

bool isEqualPosition(BoardPosition left, BoardPosition right) {
  return left.x == right.x && left.y == right.y;
}
