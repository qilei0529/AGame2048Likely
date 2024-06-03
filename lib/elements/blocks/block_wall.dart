import 'package:flame/components.dart';
import 'package:flutter_game_2048_fight/elements/blocks/block_base.dart';
import 'package:flutter_game_2048_fight/models/system/board.dart';
import 'package:flutter_game_2048_fight/models/util.dart';
import 'package:flutter_game_2048_fight/scenes/game_scene.dart';
import 'package:flutter_game_2048_fight/scenes/world_scene.dart';

class BlockWallItemWidget extends BoardItemWidget
    with HasGameReference<TheGameScene> {
  BlockWallItemWidget({BoardPosition? pos}) {
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
    sprite: game.blocks.getSprite("cover_rock"),
    size: size,
  );
  // the body
  late final SpriteComponent _body = SpriteComponent(
    sprite: game.elements.getSprite("element_rock"),
    size: size,
    position: Vector2(30, 30),
    anchor: Anchor.center,
  );

  @override
  void onMount() {
    super.onMount();

    _block.add(_cover);
    _block.add(_body);

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
