import 'package:flame/extensions.dart';

import 'system/block.dart';
import 'system/board.dart';

final globalGameSize = BoardSize(6, 6);
final globalBlockSize = Vector2(60, 60);
final globalBoardSize = Vector2(360, 360);

String getBlockKey(BoardPosition pos) {
  return "B_${pos.x}_${pos.y}";
}

bool checkBlockCanMove(BlockType type) {
  if (type == BlockType.hero ||
      type == BlockType.enemy ||
      type == BlockType.element ||
      type == BlockType.weapon ||
      type == BlockType.heal) {
    return true;
  }
  return false;
}

bool checkBlockCanMerge(BoardItem leftBlock, BoardItem rightBlock) {
  if (leftBlock.isDead || rightBlock.isDead) {
    return false;
  }
  if (leftBlock.type == BlockType.enemy || leftBlock.type == BlockType.weapon) {
    if (leftBlock.code == rightBlock.code) {
      if (leftBlock.level == rightBlock.level) {
        return true;
      }
    }
  }

  return false;
}

bool checkBlockCanElement(BlockType typeA, BlockType typeB) {
  if (typeA == BlockType.hero) {
    if (typeB == BlockType.element ||
        typeB == BlockType.weapon ||
        typeB == BlockType.heal) {
      return true;
    }
  }
  return false;
}

bool checkBlockCanDoor(BlockType typeA, BlockType typeB) {
  if (typeA == BlockType.hero) {
    if (typeB == BlockType.door) {
      return true;
    }
  }
  return false;
}

bool checkBlockCanAttack(BlockType typeA, BlockType typeB) {
  var left = [BlockType.hero, BlockType.enemy];
  var right = [BlockType.hero, BlockType.enemy, BlockType.block];
  if (right.contains(typeB) && left.contains(typeA)) {
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

//
Map<String, BoardItem> getBlockPosVos({
  required List<BoardItem> blocks,
}) {
  // 获取 位置 map 地图
  Map<String, BoardItem> posVos = {};
  for (var element in blocks) {
    var key = getBlockKey(element.position);
    posVos[key] = element;
  }
  return posVos;
}

Map<String, BoardPosition> getExtraBlocks({
  required List<BoardItem> blocks,
  required BoardSize size,
}) {
  Map<String, BoardPosition> allTargets = {};

  // 创建 5x5 格子
  for (int x = 1; x < size.width + 1; x++) {
    for (int y = 1; y < size.height + 1; y++) {
      var pos = BoardPosition(x, y);
      var key = getBlockKey(pos);
      allTargets[key] = pos;
    }
  }
  // remove existe block
  var posVos = getBlockPosVos(blocks: blocks);
  posVos.forEach((key, value) {
    allTargets.remove(key);
  });
  return allTargets;
}
