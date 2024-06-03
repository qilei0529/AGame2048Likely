import 'package:flame/components.dart';
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

  @override
  onLoad() {
    super.onLoad();
    // block
    block = PositionComponent(
      size: size,
    );
    body = SpriteComponent(
      sprite: game.elements.getSprite("element_enemy_1"),
      size: size,
      position: Vector2(30, 30),
      anchor: Anchor.center,
    );
    cover = SpriteComponent(
      sprite: game.blocks.getSprite("cover_enemy"),
      size: size,
    );

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

  @override
  toInjure({int? life, Function? onComplete}) {
    super.toInjure(
      life: life,
      onComplete: () {
        _life.text = life.toString();
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

    add(block);
  }
}
