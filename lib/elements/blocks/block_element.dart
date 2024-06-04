import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import 'package:flutter_game_2048_fight/elements/blocks/block_base.dart';
import 'package:flutter_game_2048_fight/models/system/block.dart';
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

  late SpriteComponent _level;

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

    _level = SpriteComponent(
      sprite: game.blocks.getSprite("bg_level_m1"),
      size: Vector2(20, 20),
      position: Vector2(30, 10),
      anchor: Anchor.center,
    );

    _level.opacity = 0;
  }

  setLevel(int level) {
    if (level > 1) {
      var num = min(level, 3);
      _level.sprite = game.blocks.getSprite("bg_level_m$num");
      _level.opacity = 1;
      // change de sprite
      if (type == BlockType.weapon) {
        var item = body as SpriteComponent;
        item.sprite = game.elements.getSprite("element_weapon_v$num");
      }
    }
  }

  @override
  toGrow({int? life, int? level, Function? onComplete}) {
    if (level != null) {
      setLevel(level);
    }
    super.toGrow(life: life, level: level, onComplete: onComplete);
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
    body.add(_level);
    //
    add(block);
  }
}
