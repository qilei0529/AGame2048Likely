import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'package:flutter_game_2048_fight/elements/blocks/block_base.dart';
import 'package:flutter_game_2048_fight/models/system/board.dart';
import 'package:flutter_game_2048_fight/models/util.dart';
import 'package:flutter_game_2048_fight/scenes/game_scene.dart';
import 'package:flutter_game_2048_fight/scenes/world_scene.dart';

class BlockEnemyItemWidget extends BoardItemWidget
    with HasGameReference<TheGameScene> {
  BlockEnemyItemWidget({BoardPosition? pos}) {
    // set position to -1 -1
    this.pos = pos ?? BoardPosition(-1, -1);
    size = globalBlockSize;
    position = getBoardPositionAt(this.pos.x, this.pos.y);
    anchor = Anchor.center;
  }
  // the block
  late final PositionComponent _block = PositionComponent(
    size: size,
  );
  // the cover
  late final SpriteComponent _cover = SpriteComponent(
    sprite: game.blocks.getSprite("cover_enemy"),
    size: size,
  );
  // the body
  late final SpriteComponent _body = SpriteComponent(
    sprite: game.elements.getSprite("element_enemy_1"),
    size: size,
    position: Vector2(30, 30),
    anchor: Anchor.center,
  );

  int life = 0;
  // ignore: non_constant_identifier_names
  late final SpriteComponent _life_cover = SpriteComponent(
    sprite: game.blocks.getSprite("bg_life"),
    size: Vector2(22, 22),
    position: Vector2(10, 46),
    anchor: Anchor.center,
  );

  late final TextComponent _life = TextComponent(
    text: "$life",
    textRenderer: TextPaint(
      style: const TextStyle(
        fontSize: 12,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
    ),
    anchor: Anchor.center,
    position: Vector2(11, 10),
  );

  @override
  void onMount() {
    super.onMount();

    _block.add(_cover);
    _block.add(_body);

    // life
    _life_cover.add(_life);
    _block.add(_life_cover);

    add(_block);
  }

  @override
  toBorn() {
    // TODO: implement toBorn
    throw UnimplementedError();
  }

  @override
  toDead() {
    // TODO: implement toDead
    throw UnimplementedError();
  }

  @override
  toTrigger() {
    // TODO: implement toTrigger
    throw UnimplementedError();
  }

  @override
  toWait() {
    // TODO: implement toWait
    throw UnimplementedError();
  }
}
