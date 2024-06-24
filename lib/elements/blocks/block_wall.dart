import 'package:flame/components.dart';
import 'package:flutter_game_2048_fight/elements/blocks/block_base.dart';
import 'package:flutter_game_2048_fight/models/system/board.dart';
import 'package:flutter_game_2048_fight/models/util.dart';
import 'package:flutter_game_2048_fight/scenes/game_scene.dart';
import 'package:flutter_game_2048_fight/scenes/world_scene.dart';

class BlockWallItemWidget extends BlockItem
    with HasGameReference<TheGameScene> {
  BlockWallItemWidget() {
    // set position to -1 -1
    size = globalBlockSize;
    anchor = Anchor.center;
  }

  @override
  onLoad() {
    super.onLoad();
    // block
    block = PositionComponent(
      size: size,
    );
    body = SpriteComponent(
      sprite: game.elements.getSprite("element_rock"),
      size: size,
      position: Vector2(30, 30),
      anchor: Anchor.center,
    );
    cover = SpriteComponent(
      sprite: game.blocks.getSprite("cover_rock"),
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
