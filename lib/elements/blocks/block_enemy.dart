import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import 'package:flutter_game_2048_fight/elements/blocks/block_base.dart';
import 'package:flutter_game_2048_fight/models/util.dart';
import 'package:flutter_game_2048_fight/scenes/game_scene.dart';

class BlockEnemyItemWidget extends BlockActiveItem
    with HasGameReference<TheGameScene> {
  BlockEnemyItemWidget() {
    size = globalBlockSize;
    anchor = Anchor.center;
  }

  // ignore: non_constant_identifier_names
  late final SpriteComponent _life_cover;
  late final TextComponent _life;

  late SpriteComponent _level;

  @override
  onLoad() {
    super.onLoad();
    // block
    block = PositionComponent(
      size: size,
    );
    body = SpriteComponent(
      sprite: game.elements.getSprite("element_enemy_v1"),
      size: size,
      position: Vector2(30, 30),
      anchor: Anchor.center,
    );
    cover = SpriteComponent(
      sprite: game.blocks.getSprite("cover_enemy"),
      size: size,
    );

    _level = SpriteComponent(
      sprite: game.blocks.getSprite("bg_level_v1"),
      size: Vector2(20, 20),
      position: Vector2(30, 10),
      anchor: Anchor.center,
    );

    _level.opacity = 0;

    _life_cover = SpriteComponent(
      sprite: game.blocks.getSprite("bg_life"),
      size: Vector2(22, 22),
      position: Vector2(10, 46),
      anchor: Anchor.center,
    );

    _life = TextComponent(
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
  }

  setLevel(int level) {
    if (level > 1) {
      var num = min(level, 3);
      _level.sprite = game.blocks.getSprite("bg_level_v$num");
      _level.opacity = 1;

      // change de sprite
      var item = body as SpriteComponent;
      item.sprite = game.elements.getSprite("element_enemy_v$num");
    }
  }

  @override
  toLife(int life) {
    super.toLife(life);
    _life.text = life.toString();
    _life_cover.add(
      SequenceEffect(
        [
          ScaleEffect.to(Vector2.all(1.5), dur(0.1)),
          ScaleEffect.to(Vector2.all(1), dur(0.1)),
        ],
      ),
    );
  }

  @override
  toGrow({int? life, int? level, Function? onComplete}) {
    if (level != null) {
      setLevel(level);
    }
    super.toGrow(life: life, level: level, onComplete: onComplete);
  }

  @override
  toInjure({Function? onComplete}) {
    super.toInjure(
      onComplete: () {
        onComplete != null ? onComplete() : null;
      },
    );
  }

  @override
  void onMount() {
    super.onMount();

    block.add(cover);
    block.add(body);
    // life
    _life_cover.add(_life);
    block.add(_life_cover);
    block.add(_level);

    add(block);
  }
}
