import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game_2048_fight/elements/block_item.dart';
import 'package:flutter_game_2048_fight/models/system/block.dart';
import 'package:flutter_game_2048_fight/scenes/world_scene.dart';

extension BlockMixin on WorldScene {
  BoardItemComponent createBlock(BoardItem item) {
    var pos = item.position;
    var position = getBoardPositionAt(pos.x, pos.y);

    var color = Colors.blueGrey.shade300;

    var cover = "cover_element";
    var body = "element_hp";
    var act;

    var count;

    if (item.type == BlockType.enemy) {
      color = Colors.red.shade400;
      cover = "cover_enemy";
      body = "element_enemy_1";

      count = item.count;
    }
    if (item.type == BlockType.hero) {
      color = Colors.blue.shade400;
      cover = "cover_hero";
      body = "element_hero";
      act = "4";
    }
    if (item.type == BlockType.element) {
      color = Colors.orange.shade200;
      body = "element_sp";
    }
    if (item.type == BlockType.heal) {
      color = Colors.green.shade400;
      body = "element_hp";
    }
    if (item.type == BlockType.weapon) {
      color = Colors.blueGrey.shade500;
      body = "element_weapon";
    }
    if (item.type == BlockType.door) {
      color = Colors.orange.shade400;
      body = "element_door";
    }
    if (item.type == BlockType.block) {
      color = Colors.red.shade400;
      cover = "cover_rock";
      body = "element_rock";
    }
    var block = BoardItemComponent(
      position: position,
      color: color,
      size: Vector2(60, 60),
      cover: cover,
      body: body,
      act: act,
      type: item.type,
      count: item.count,
    );
    // block.debugMode = true;
    block.debugColor = Colors.black26;
    block.point = item.point;
    if (item.life > 0) {
      block.setLife(item.life);
    }
    block.setLevel(item.level);
    return block;
  }
}
