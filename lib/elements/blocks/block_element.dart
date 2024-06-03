import 'package:flame/components.dart';

import 'package:flutter/material.dart';

import 'package:flutter_game_2048_fight/elements/blocks/block_base.dart';
import 'package:flutter_game_2048_fight/models/system/board.dart';
import 'package:flutter_game_2048_fight/models/util.dart';
import 'package:flutter_game_2048_fight/scenes/game_scene.dart';
import 'package:flutter_game_2048_fight/scenes/world_scene.dart';

class BlockElementItemWidget extends BoardItemWidget
    with HasGameReference<TheGameScene> {
  BlockElementItemWidget({BoardPosition? pos}) {
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
    sprite: game.blocks.getSprite("cover_element"),
    size: size,
  );
  // the body
  late final SpriteComponent _body = SpriteComponent(
    sprite: game.elements.getSprite("element_hp"),
    size: size,
    position: Vector2(30, 30),
    anchor: Anchor.center,
  );

  // ignore: non_constant_identifier_names
  late final SpriteComponent _num_cover = SpriteComponent(
    sprite: game.blocks.getSprite("bg_element_2"),
    size: Vector2(20, 20),
    position: Vector2(44, 44),
    anchor: Anchor.center,
  );

  late final TextComponent _num = TextComponent(
    text: "0",
    textRenderer: TextPaint(
      style: const TextStyle(
        fontSize: 12,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
    ),
    position: Vector2(11, 9),
    anchor: Anchor.center,
  );

  setBody(Sprite body) {
    _body.sprite = body;
  }

  @override
  void onMount() {
    super.onMount();

    _block.add(_cover);
    _block.add(_body);

    _num_cover.add(_num);
    _block.add(_num_cover);

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
