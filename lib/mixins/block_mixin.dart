//
import 'package:flutter_game_2048_fight/elements/blocks/block_base.dart';
import 'package:flutter_game_2048_fight/elements/blocks/block_door.dart';
import 'package:flutter_game_2048_fight/elements/blocks/block_element.dart';
import 'package:flutter_game_2048_fight/elements/blocks/block_enemy.dart';
import 'package:flutter_game_2048_fight/elements/blocks/block_hero.dart';
import 'package:flutter_game_2048_fight/elements/blocks/block_wall.dart';
import 'package:flutter_game_2048_fight/models/system/block.dart';
import 'package:flutter_game_2048_fight/scenes/world_scene.dart';

extension BlockMixin on WorldScene {
  BlockItem? createBlockItem(BoardItem item) {
    BlockItem block;
    var pos = item.position;
    var position = getBoardPositionAt(pos.x, pos.y);

    if (item.type == BlockType.hero) {
      block = BlockHeroItemWidget();
      block as BlockHeroItemWidget;
      block.position = position;
      block.life = item.life;
      block.act = 1;
      return block;
    }

    if (item.type == BlockType.enemy) {
      block = BlockEnemyItemWidget();
      block as BlockEnemyItemWidget;
      block.position = position;
      block.life = item.life;

      return block;
    }

    if (item.type == BlockType.block) {
      block = BlockWallItemWidget();
      block.position = position;
      return block;
    }

    if (item.type == BlockType.door) {
      block = BlockDoorItemWidget();
      block.position = position;
      return block;
    }

    if (item.type == BlockType.element) {
      block = BlockElementItemWidget();
      block as BlockElementItemWidget;
      block.position = position;
      block.setBody(code: "element_sp");
      return block;
    }

    if (item.type == BlockType.heal) {
      block = BlockElementItemWidget();
      block as BlockElementItemWidget;
      block.position = position;
      block.setBody(code: "element_hp");
      return block;
    }

    if (item.type == BlockType.weapon) {
      block = BlockElementItemWidget();
      block as BlockElementItemWidget;
      block.position = position;
      block.setBody(code: "element_weapon");
      return block;
    }

    return null;
  }
}
