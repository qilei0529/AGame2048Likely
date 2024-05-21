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
  late int level;

  BoardComponent? body;
  BoardPosition position;

  int get life => _life;

  set life(int value) {
    _life = value;

    body?.life.text = "$value";
  }

  BlockTarget(this.name, this.position, this.type) {
    _life = 1;
    level = 1;
  }

  BlockTarget copy() {
    var item = BlockTarget(name, position, type);
    item.life = life;
    item.body = body;
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

  late Map<String, BlockTarget> vos = {};

  addBlock(BlockTarget block) {
    vos[getBlockKey(block.position)] = block;
  }

  removeBlock(BlockTarget block) {}

  getBlockKey(BoardPosition pos) {
    return "B_${pos.x}_${pos.y}";
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

    // Array = {};

    checkBlockPoint(BlockTarget block, PointType point) {
      bool reduceBlockImpact(BlockTarget target) {
        // TODO get the act from block
        var act = 1;
        target.life -= act;
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
            // 判断是否死亡
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
      var newBlock = block.copy();
      newBlock.moveTo(pos.x, pos.y, point);
      var key = getBlockKey(pos);
      print(key);
      tempVos[key] = newBlock;
    }

    for (var block in blocklist) {
      checkBlockPoint(block, point);
    }

    vos.clear();

    // 更新

    vos = tempVos;

    tempVos.forEach((key, value) {
      print("temp $key");
      vos[key] = value;
    });

    print(vos);

    // 对所有 block 进行遍历
    // 收集 需要的 action
    //     move
    //     impact

    // 更新 block 新的位置
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
