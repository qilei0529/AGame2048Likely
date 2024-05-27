import 'package:uuid/uuid.dart';

import 'game.dart';
import 'board.dart';

enum BlockType {
  // 英雄
  hero,
  // 敌人
  enemy,
  // sta
  element,
  // 生命
  heal,
  // 武器
  weapon,
  // 云
  cloud,
  // 宝箱
  chest,
  // 石头
  block,
  // door
  door,
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
      case "Weapon":
        return BlockType.weapon;
      case "Heal":
        return BlockType.heal;
      case "Door":
        return BlockType.door;
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
  heal,
  weapon,
  door,
  rock,
  none,
}

extension BlockMergeCodeExtension on BlockMergeCode {
  BlockMergeCode toCode(String code) {
    switch (code) {
      case "enemy":
        return BlockMergeCode.enemy;
      case "hero":
        return BlockMergeCode.hero;
      case "element":
        return BlockMergeCode.element;
      case "weapon":
        return BlockMergeCode.weapon;
      case "heal":
        return BlockMergeCode.heal;
      case "door":
        return BlockMergeCode.door;
      case "rock":
        return BlockMergeCode.rock;
    }
    return BlockMergeCode.none;
  }

  String toCodeString() {
    switch (this) {
      case BlockMergeCode.enemy:
        return "enemy";
      case BlockMergeCode.hero:
        return "hero";
      case BlockMergeCode.element:
        return "sp";
      case BlockMergeCode.heal:
        return "hp";
      case BlockMergeCode.weapon:
        return "act";
      case BlockMergeCode.door:
        return "door";
      case BlockMergeCode.rock:
        return "rock";
      case BlockMergeCode.none:
        return "none";
    }
  }
}

class BoardItem<T> extends BlockData with WithPosition, WithLevel {
  late T? body;

  late int life;
  late GamePoint point;

  // 攻击力
  int act = 0;
  // 耐力值
  int sta = 0;

  bool isDead = false;

  BlockMergeCode code = BlockMergeCode.none;

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
