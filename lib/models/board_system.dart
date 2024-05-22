import 'dart:math';

import 'package:flutter_game_2048_fight/elements/board_component.dart';

class BoardSize {
  int width;
  int height;
  BoardSize(this.width, this.height);
}

class BoardPosition {
  int x;
  int y;
  BoardPosition(this.x, this.y);
}

class BlockTarget {
  // late String key;
  String name;
  String type;

  late int _life;
  late int _level;

  BoardComponent? body;
  BoardPosition position;

  int get life => _life;
  set life(int value) {
    _life = value;
    body?.lifeTo(value);
  }

  int get level => _level;
  set level(int value) {
    _level = value;
    body?.levelTo(value);
  }

  BlockTarget(this.name, this.position, this.type) {
    _life = 1;
    _level = 1;
  }

  BlockTarget copy() {
    var item = BlockTarget(name, position, type);
    item.life = life;
    item.body = body;
    item.level = level;
    return item;
  }

  moveTo(int x, int y, PointType point) {
    position = BoardPosition(x, y);
    body?.moveTo(x, y, point);
  }

  dead() {
    body?.dead();
  }
}

class BoardSystem {
  BoardSize size;
  BoardSystem(this.size);

  int step = 0;

  bool openMerge = false;
  bool openInner = false;

  late Map<String, BlockTarget> vos = {};

  addBlock(BlockTarget block) {
    vos[getBlockKey(block.position)] = block;
  }

  removeBlock(BlockTarget block) {}

  getBlockKey(BoardPosition pos) {
    return "B_${pos.x}_${pos.y}";
  }

  BlockTarget? createRandomTarget() {
    // 从当前所占领的 5x5 格子中
    // 去除掉 已经占用的 格子，
    // 随机返回一个 没被占用的格子
    Map<String, BoardPosition> allTargets = {};

    // 创建 5x5 格子
    for (int x = 1; x < 6; x++) {
      for (int y = 1; y < 6; y++) {
        var pos = BoardPosition(x, y);
        var key = getBlockKey(pos);
        allTargets[key] = pos;
      }
    }
    print(allTargets.length);

    vos.forEach((key, value) {
      allTargets.remove(key);
    });

    print(allTargets.length);

    // // 随机选择一个未被占用的格子
    List<BoardPosition> list = allTargets.values.toList();

    if (list.isNotEmpty) {
      var random = Random();
      int index = random.nextInt(list.length);
      print(index);
      var life = index % 3 + 1;
      step += 1;
      var name = "Enemy_$step";
      var pos = list[index];
      var type = "ENEMY";
      var block = BlockTarget(name, pos, type);
      block.life = life;
      return block;
    }
    return null;
  }

  slideTo(PointType point) {
    // 获取 排序
    List<BlockTarget> blocklist = [];
    vos.forEach((key, block) {
      blocklist.add(block);
    });

    blocklist.sort((a, b) {
      var posA = a.position;
      var posB = b.position;
      switch (point) {
        case PointType.right:
          return posB.x - posA.x;
        case PointType.left:
          return posA.x - posB.x;
        case PointType.top:
          return posA.y - posB.y;
        case PointType.bottom:
          return posB.y - posA.y;
      }
    });

    Map<String, BlockTarget> tempVos = {};

    checkBlockPoint(BlockTarget block, PointType point) {
      bool reduceBlockImpact(BlockTarget target) {
        if (block.type != target.type) {
          var act = 1;
          target.life -= act;
        }
        return target.life > 0;
      }

      // 获取 某一个方向上的位置。
      BoardPosition getPointPosition(BoardPosition pos) {
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
          var item = tempVos[key];
          if (item != null) {
            // 处理 伤害
            print("need do impack with: ${item.name}");

            // check grow
            if (openMerge &&
                item.type == block.type &&
                item.level == block.level) {
              block.life += item.life;
              block.level += item.level;
              item.dead();
              tempVos.remove(key);
              if (openInner) {
                return getPointPosition(newPos);
              } else {
                return pos;
              }
              // continue move
            }
            var isAlive = reduceBlockImpact(item);
            if (isAlive) {
              return pos;
            } else {
              // isDead
              item.dead();
              tempVos.remove(key);
              return pos;
            }
          }
          return getPointPosition(newPos);
        }
      }

      // get new pos by pos;
      var pos = getPointPosition(block.position);
      print("${block.name} ${block.life} ${pos.x} - ${pos.y}");

      // copy block
      var newBlock = block;

      newBlock.moveTo(pos.x, pos.y, point);
      var key = getBlockKey(pos);
      tempVos[key] = newBlock;
    }

    for (var block in blocklist) {
      checkBlockPoint(block, point);
    }

    vos.clear();

    // 更新
    vos = tempVos;
  }
}

enum PointType { left, right, top, bottom }

extension PointTypeExtension on PointType {
  BoardPosition toPosition() {
    switch (this) {
      case PointType.left:
        return BoardPosition(-1, 0);
      case PointType.right:
        return BoardPosition(1, 0);
      case PointType.top:
        return BoardPosition(0, -1);
      case PointType.bottom:
        return BoardPosition(0, 1);
    }
  }

  BoardPosition addPosition(BoardPosition pos) {
    switch (this) {
      case PointType.left:
        return BoardPosition(-1 + pos.x, 0 + pos.y);
      case PointType.right:
        return BoardPosition(1 + pos.x, 0 + pos.y);
      case PointType.top:
        return BoardPosition(0 + pos.x, -1 + pos.y);
      case PointType.bottom:
        return BoardPosition(0 + pos.x, 1 + pos.y);
    }
  }
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
