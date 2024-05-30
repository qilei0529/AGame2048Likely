import 'dart:math';

import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

// frame
import 'package:flame/components.dart';
import 'package:flutter_game_2048_fight/models/system/block.dart';
import 'package:flutter_game_2048_fight/models/system/game.dart';
import 'package:flutter_game_2048_fight/models/system/task.dart';
import 'package:flutter_game_2048_fight/models/util.dart';

// scene
import 'package:flutter_game_2048_fight/scenes/game_scene.dart';

class BoardItemComponent extends PositionComponent
    with HasGameReference<TheGameScene> {
  late Color color;
  late GamePoint point;

  late BlockType type;

  late final PositionComponent _block = PositionComponent(
    size: size,
    // anchor: Anchor.center,
  );

  late String cover;
  late final SpriteComponent _cover = SpriteComponent(
    sprite: game.blocks.getSprite(cover),
    size: size,
  );
  late String body;
  late final SpriteComponent _body = SpriteComponent(
    sprite: game.elements.getSprite(body),
    size: size,
    position: Vector2(30, 30),
    anchor: Anchor.center,
  );
  late String? act = "";
  late int? level = 0;

  BoardItemComponent({
    super.key,
    super.position,
    Vector2? size,
    Color? color,
    int? life,
    GamePoint? point,
    String? cover,
    String? body,
    String? act,
    required this.type,
  }) {
    this.color = color ?? Colors.white60;
    this.cover = cover ?? "cover_element";
    this.body = body ?? "element_hp";
    this.act = act ?? "";
    super.size = size ?? globalBlockSize;
    super.anchor = Anchor.center;
  }

  late TextComponent life = TextComponent(
    text: "",
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

  late final SpriteComponent _lifeBg = SpriteComponent(
    sprite: game.blocks.getSprite("bg_life"),
    size: Vector2(22, 22),
    position: Vector2(10, 46),
    anchor: Anchor.center,
  );

  late final SpriteComponent _actBg;

  late SpriteComponent _level;
  late final TextComponent _act = TextComponent(
    text: "4",
    textRenderer: TextPaint(
      style: const TextStyle(
        fontSize: 12,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
    ),
    position: Vector2(7, 2),
  );

  TaskSystem taskSystem = TaskSystem(maxQueue: 1);

  lifeTo({required int num, Function? end}) {
    taskSystem.add((next) {
      // var pos = getGroundPositionAt(p.x, p.y);
      EffectController duration(double x) => EffectController(duration: x);

      _lifeBg.add(
        SequenceEffect(
          [
            ScaleEffect.to(Vector2.all(1.5), duration(0.08)),
            ScaleEffect.to(Vector2.all(1), duration(0.08))
          ],
          onComplete: () {
            life.text = "$num";
            // change life;
            if (end != null) {
              end();
            }
            next();
          },
        ),
      );
    });
  }

  actTo({required int num, Function? end}) {
    taskSystem.add((next) {
      // var pos = getGroundPositionAt(p.x, p.y);
      EffectController duration(double x) => EffectController(duration: x);

      _actBg.add(
        SequenceEffect(
          [
            ScaleEffect.to(Vector2.all(1.5), duration(0.08), onComplete: () {
              _act.text = "$act";
            }),
            ScaleEffect.to(Vector2.all(1), duration(0.08))
          ],
          onComplete: () {
            if (end != null) {
              end();
            }
            next();
          },
        ),
      );
    });
  }

  fadeTo({Function? end}) {
    taskSystem.add((next) {
      // var pos = getGroundPositionAt(p.x, p.y);
      EffectController duration(double x) => EffectController(duration: x);

      _cover.add(
        SequenceEffect(
          [
            OpacityEffect.to(0, duration(0.1)),
          ],
        ),
      );
      _body.add(
        SequenceEffect(
          [
            // big
            ScaleEffect.to(Vector2.all(1.3), duration(0.1)),
            SequenceEffect(
              [
                // big
                ScaleEffect.to(Vector2.all(1), duration(0.08)),
                OpacityEffect.fadeOut(duration(0.1)),
              ],
            ),
          ],
          onComplete: () {
            next();
            if (end != null) {
              end();
            }
          },
        ),
      );
    });
  }

  upgrade({Function? end}) {
    taskSystem.add((next) {
      // var pos = getGroundPositionAt(p.x, p.y);
      EffectController duration(double x) => EffectController(duration: x);
      _body.add(
        SequenceEffect(
          [
            ScaleEffect.to(Vector2.all(1.5), duration(0.1)),
            ScaleEffect.to(Vector2.all(1), duration(0.1)),
          ],
          onComplete: () {
            next();
            if (end != null) {
              end();
            }
          },
        ),
      );
    });
  }

  injure({required int num, Function? end}) {
    taskSystem.add((next) {
      // var pos = getGroundPositionAt(p.x, p.y);
      EffectController duration(double x) => EffectController(duration: x);

      var box = RectangleComponent(
        size: size,
      );
      box.setColor(Colors.red);
      box.add(
        SequenceEffect(
          [
            OpacityEffect.to(0, duration(0)),
            OpacityEffect.to(1, duration(0.05)),
            OpacityEffect.to(0, duration(0.05)),
          ],
          onComplete: () {
            box.removeFromParent();
          },
        ),
      );
      _block.add(box);

      _block.add(
        SequenceEffect(
          [
            MoveToEffect(Vector2(0, 0), duration(0.2)),
          ],
          onComplete: () {
            next();
            // change life;
            life.text = "$num";
            if (end != null) {
              end();
            }
          },
        ),
      );
    });
  }

  born({Function? end}) {
    taskSystem.add((next) {
      EffectController duration(double x) => EffectController(duration: x);

      _cover.add(SequenceEffect(
        [
          OpacityEffect.fadeIn(duration(0.3)),
        ],
      ));
      _block.add(
        SequenceEffect(
          [
            SequenceEffect([
              MoveToEffect(Vector2(0, -80), duration(0)),
            ]),
            SequenceEffect([
              MoveToEffect(Vector2(0, 0), duration(0.1)),
            ]),
            MoveToEffect(Vector2(0, -8), duration(0.08)),
            MoveToEffect(Vector2(0, 0), duration(0.08)),
          ],
          onComplete: () {
            if (end != null) {
              end();
            }
            next();
          },
        ),
      );
    });
  }

  dead({Function? end}) {
    taskSystem.add((next) {
      EffectController duration(double x) => EffectController(duration: x);
      // add run
      _block.add(
        SequenceEffect(
          [
            MoveToEffect(Vector2(0, 0), duration(0.1)),
          ],
          onComplete: () {
            next();
            if (end != null) {
              end();
            }
          },
        ),
      );
    });
  }

  attack({Function? end}) {
    taskSystem.add((next) {
      EffectController duration(double x) => EffectController(duration: x);
      var p = point.toPosition();
      add(
        SequenceEffect(
          [
            MoveEffect.by(
              Vector2(-8 * p.x.toDouble(), -8 * p.y.toDouble()),
              EffectController(
                duration: 0.16,
                reverseDuration: 0.16,
                // startDelay: 0.2,
                atMinDuration: 0.2,
                curve: Curves.ease,
                infinite: false,
              ),
            ),
          ],
          onComplete: () {
            if (end != null) {
              end();
            }
            next();
          },
        ),
      );
    });
  }

  moveTo({required int x, required int y, Function? end}) {
    taskSystem.add((next) {
      var pos = getGroundPositionAt(x, y);
      EffectController duration(double x) => EffectController(duration: x);
      add(
        SequenceEffect(
          [
            MoveEffect.to(
              pos,
              duration(0.16),
            ),
          ],
          onComplete: () {
            if (end != null) {
              end();
            }
            next();
          },
        ),
      );
    });
  }

  // get the position from int x y
  getGroundPositionAt(int x, int y) {
    var width = globalBlockSize.x;
    var height = globalBlockSize.y;
    var dx = width * x.toDouble() - width / 2;
    var dy = height * y.toDouble() - height / 2;
    return Vector2(dx, dy);
  }

  setLife(int life) {
    this.life.text = "$life";
  }

  setAct(int act) {
    _act.text = "$act";
  }

  initAct() {
    if (act != null && act!.isNotEmpty) {
      _actBg = SpriteComponent(
        sprite: game.blocks.getSprite("bg_act"),
        size: Vector2(22, 22),
        position: Vector2(38, 34),
        // anchor: Anchor.center,
      );
      _act.text = "1";
      _actBg.add(_act);
      _block.add(_actBg);
    } else if (type == BlockType.element ||
        type == BlockType.heal ||
        type == BlockType.weapon ||
        type == BlockType.block) {
      _actBg = SpriteComponent(
        sprite: game.blocks.getSprite("bg_element_2"),
        size: Vector2(20, 20),
        position: Vector2(34, 34),
        // anchor: Anchor.center,
      );
      _actBg.add(life);
      _block.add(_actBg);
    }
  }

  setLevel(int level) {
    if (level > 1) {
      _level.removeFromParent();
      var num = min(level, 3);
      _level = SpriteComponent(
        sprite: game.blocks.getSprite("bg_level_$num"),
        size: Vector2(20, 20),
        position: Vector2(20, 0),
        // anchor: Anchor.center,
      );
      _block.add(_level);
    }
  }

  initLevel() {
    _level = SpriteComponent(
      sprite: game.blocks.getSprite("bg_level_2"),
      size: Vector2(20, 20),
      position: Vector2(20, 0),
      // anchor: Anchor.center,
    );
    _level.opacity = 0;
    // bg.opacity = 0;
    _block.add(_level);
    // _block.add(level);
  }

  @override
  void onMount() {
    _block.add(_cover);
    _block.add(_body);
    if (type == BlockType.hero || type == BlockType.enemy) {
      _lifeBg.add(life);
      _block.add(_lifeBg);
    }

    initAct();
    initLevel();
    add(_block);
    super.onMount();
  }
}
