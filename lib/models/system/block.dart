import 'package:uuid/uuid.dart';

import 'board.dart';

enum BlockType {
  // 英雄
  hero,
  // 敌人
  enmey,
  // 石头
  rock,
  // 物件
  element,
  // 云
  cloud,
  // 宝箱
  chest
}

extension BlockTypeExtension on BlockType {
  BlockType toType(String type) {
    switch (type) {
      case "Hero":
        return BlockType.hero;
      case "Enemy":
        return BlockType.enmey;
    }
    return BlockType.rock;
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
    this.type = type ?? BlockType.rock;
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

class BoardItem<T> extends BlockData with WithPosition, WithLevel {
  late T? body;

  late int life;

  BoardItem({
    String? id,
    String? name,
    BlockType? type,
  }) {
    this.id = id ?? const Uuid().v4().toString();
    this.name = name ?? "";
    this.type = type ?? BlockType.rock;
  }

  moveTo() {
    // body.moveTo()
  }

  BoardItem copy() {
    var item = BoardItem(id: id, name: name, type: type);
    item.position = position;
    item.life = life;
    item.level = level;
    return item;
  }
}
