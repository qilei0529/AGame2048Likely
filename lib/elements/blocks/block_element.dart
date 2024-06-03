import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import 'package:flutter_game_2048_fight/elements/blocks/block_base.dart';
import 'package:flutter_game_2048_fight/models/util.dart';
import 'package:flutter_game_2048_fight/scenes/game_scene.dart';

class BlockElementItemWidget extends BlockItem
    with HasGameReference<TheGameScene> {
  BlockElementItemWidget() {
    size = globalBlockSize;
    anchor = Anchor.center;
  }

  // ignore: non_constant_identifier_names
  String _body_code = "element_hp";

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
      sprite: game.blocks.getSprite("cover_element"),
      size: size,
    );
  }

  @override
  toTrigger({Function? onComplete}) {
    task.add((next) {
      cover.add(
        OpacityEffect.to(0, dur(0.1)),
      );

      body.add(
        SequenceEffect(
          [
            ScaleEffect.to(Vector2.all(1.3), dur(0.1)),
            ScaleEffect.to(Vector2.all(1), dur(0.08)),
          ],
          onComplete: () {
            next();
            onComplete != null ? onComplete() : null;
          },
        ),
      );
    });
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
