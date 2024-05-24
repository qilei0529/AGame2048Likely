import 'package:uuid/uuid.dart';

import 'game.dart';
import 'board.dart';

enum BlockType {
  // 英雄
  hero,
  // 敌人
  enemy,
  // 物件
  element,
  // 云
  cloud,
  // 宝箱
  chest,
  // 石头
  block,
}

extension BlockTypeExtension on BlockType {
  BlockType toType(String type) {
    switch (type) {
      case "Hero":
        return BlockType.hero;
      case "Enemy":
        return BlockType.enemy;
      case "Element":
        return BlockType.element;
    }
    return BlockType.block;
  }
}

class BlockData {
  late String id;
  late BlockType type;
  late String name;

  BlockData({
    String? id,
    String? name,
    BlockType? type,
  }) {
    this.id = id ?? const Uuid().v4().toString();
    this.name = name ?? "";
    this.type = type ?? BlockType.block;
  }
}

mixin WithPosition on BlockData {
  late BoardPosition _position;
  BoardPosition get position => _position;
  set position(BoardPosition pos) {
    _position = pos;
  }
}

mixin WithLevel on BlockData {
  late int _level;
  int get level => _level;
  set level(int level) {
    _level = level;
  }
}

enum BlockMergeCode {
  // 英雄
  hero,
  enemy,
  element,
  none,
}

extension BlockMergeCodeExtension on BlockMergeCode {
  String toCode() {
    switch (this) {
      case BlockMergeCode.enemy:
        return "enemy";
      case BlockMergeCode.hero:
        return "hero";
      case BlockMergeCode.element:
        return "elem";
      case BlockMergeCode.none:
        return "none";
    }
  }
}

class BoardItem<T> extends BlockData with WithPosition, WithLevel {
  late T? body;

  late int life;
  late GamePoint point;

  bool isDead = false;

  BlockMergeCode code = BlockMergeCode.none;

  int act = 0;

  BoardItem({
    String? id,
    String? name,
    BlockType? type,
    GamePoint? point,
  }) {
    this.id = id ?? const Uuid().v4().toString();
    this.name = name ?? "";
    this.type = type ?? BlockType.block;
    this.point = point ?? GamePoint.bottom;
  }

  BoardItem copy() {
    var item = BoardItem(id: id, name: name, type: type);
    item.position = position;
    item.life = life;
    item.level = level;
    item.code = code;
    item.act = act;
    return item;
  }
}
