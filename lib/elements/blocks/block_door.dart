import 'package:flame/components.dart';

import 'package:flutter_game_2048_fight/elements/blocks/block_base.dart';
import 'package:flutter_game_2048_fight/models/util.dart';
import 'package:flutter_game_2048_fight/scenes/game_scene.dart';

class BlockDoorItemWidget extends BlockItem
    with HasGameReference<TheGameScene> {
  BlockDoorItemWidget() {
    size = globalBlockSize;
    anchor = Anchor.center;
  }

  // ignore: non_constant_identifier_names
  String _body_code = "element_door";

  setBody({required String code}) {
    _body_code = code;
  }

  @override
  onLoad() {
    super.onLoad();
    // block
    block = PositionComponent(
      size: size,
    );
    body = SpriteComponent(
      sprite: game.elements.getSprite(_body_code),
      size: size,
      position: Vector2(30, 30),
      anchor: Anchor.center,
    );
    cover = SpriteComponent(
      sprite: game.blocks.getSprite("cover_hero"),
      size: size,
    );
  }

  @override
  void onMount() {
    super.onMount();

    block.add(cover);
    block.add(body);
    //
    add(block);
  }
}
