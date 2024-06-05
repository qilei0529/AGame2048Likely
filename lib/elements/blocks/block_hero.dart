import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

//
import 'package:flutter_game_2048_fight/elements/blocks/block_base.dart';
import 'package:flutter_game_2048_fight/models/util.dart';
import 'package:flutter_game_2048_fight/scenes/game_scene.dart';

class BlockHeroItemWidget extends BlockActiveItem
    with HasGameReference<TheGameScene> {
  BlockHeroItemWidget() {
    size = globalBlockSize;
    anchor = Anchor.center;
  }

  // ignore: non_constant_identifier_names
  late final SpriteComponent _life_cover;
  late final TextComponent _life;

  // ignore: non_constant_identifier_names
  late final SpriteComponent _act_cover;

  late final TextComponent _act;

  @override
  onLoad() {
    super.onLoad();
    // block
    block = PositionComponent(
      size: size,
    );
    body = SpriteComponent(
      sprite: game.elements.getSprite("element_hero"),
      size: size,
      position: Vector2(30, 30),
      anchor: Anchor.center,
    );
    cover = SpriteComponent(
      sprite: game.blocks.getSprite("cover_hero"),
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

    _act_cover = SpriteComponent(
      sprite: game.blocks.getSprite("bg_act"),
      size: Vector2(22, 22),
      position: Vector2(50, 46),
      anchor: Anchor.center,
    );
    _act = TextComponent(
      text: "$act",
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      position: Vector2(9, 2),
    );
  }

  @override
  toLife({required int life, Function? onComplete}) {
    super.toLife(life: life);
    _life.text = life.toString();
    _life_cover.add(
      SequenceEffect(
        [
          ScaleEffect.to(Vector2.all(1.5), dur(0.06)),
          ScaleEffect.to(Vector2.all(1), dur(0.4)),
        ],
        onComplete: () {
          onComplete != null ? onComplete() : null;
        },
      ),
    );
    // task.add((next) {});
  }

  @override
  toAct({required int act, Function? onComplete}) {
    super.toAct(act: act);
    _act.text = act.toString();
    _act_cover.add(
      SequenceEffect(
        [
          ScaleEffect.to(Vector2.all(1.5), dur(0.1)),
          ScaleEffect.to(Vector2.all(1), dur(0.1)),
        ],
        onComplete: () {
          onComplete != null ? onComplete() : null;
        },
      ),
    );
    // task.add((next) {});
  }

  @override
  toInjure({int? life, Function? onComplete}) {
    super.toInjure(
      onComplete: () {
        onComplete != null ? onComplete() : null;
      },
    );
    if (life != null) {
      _life.text = life.toString();
    }
  }

  @override
  void onMount() {
    super.onMount();

    block.add(cover);
    block.add(body);

    // life
    _life_cover.add(_life);
    block.add(_life_cover);
    // // act
    _act_cover.add(_act);
    block.add(_act_cover);
    add(block);
  }
}
