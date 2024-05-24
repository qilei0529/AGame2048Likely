import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

// frame
import 'package:flame/components.dart';
import 'package:flutter_game_2048_fight/models/system/block.dart';
import 'package:flutter_game_2048_fight/models/system/game.dart';
import 'package:flutter_game_2048_fight/models/system/task.dart';

// scene
import 'package:flutter_game_2048_fight/scenes/game_scene.dart';

class BlockComponent extends RectangleComponent
    with HasGameReference<TheGameScene> {
  late Color color;

  late GamePoint point;

  BlockComponent({
    super.key,
    super.position,
    Vector2? size,
    Color? color,
    int? life,
    GamePoint? point,
  }) {
    this.color = color ?? Colors.white60;
    super.size = size ?? Vector2(60, 60);
    super.anchor = Anchor.center;
  }

  late TextComponent life = TextComponent(
    text: "",
    textRenderer: TextPaint(
      style: const TextStyle(
        fontSize: 24,
        color: Colors.black54,
      ),
    ),
  );

  TaskSystem taskSystem = TaskSystem(maxQueue: 1);

  lifeTo({required int num, Function? end}) {
    taskSystem.add((next) {
      // var pos = getGroundPositionAt(p.x, p.y);
      EffectController duration(double x) => EffectController(duration: x);
      add(
        SequenceEffect(
          [OpacityEffect.to(1, duration(0.1))],
          onComplete: () {
            // change life;
            life.text = "$num";
            if (end != null) {
              end();
            }
            next();
          },
        ),
      );
    });
  }

  born({Function? end}) {
    taskSystem.add((next) {
      // var pos = getGroundPositionAt(p.x, p.y);
      EffectController duration(double x) => EffectController(duration: x);
      add(
        SequenceEffect(
          [
            OpacityEffect.to(0, duration(0)),
            OpacityEffect.to(1, duration(0.1)),
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
      add(
        SequenceEffect(
          [
            OpacityEffect.to(0, duration(0)),
            OpacityEffect.to(1, duration(0.1)),
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

  attack({Function? end}) {
    taskSystem.add((next) {
      EffectController duration(double x) => EffectController(duration: x);
      // this.add()
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
    var width = 300;
    var height = 300;
    print("$width, $height");
    var dx = 60.0 * x.toDouble() - 30;
    var dy = 60.0 * y.toDouble() - 30;
    return Vector2(dx, dy);
  }

  setLife(int life) {
    this.life.text = "$life";
  }

  @override
  void onMount() {
    setColor(color);
    add(life);
    super.onMount();
  }
}

mixin HasBoardReference on BlockComponent {
  RectangleComponent get board => parent! as RectangleComponent;

  Vector2 getBoardSize() {
    return Vector2(300, 300);
  }
}

class BoardItemComponent extends BlockComponent with HasBoardReference {
  late BoardItem data;

  setPositionAt({required int x, required int y}) {
    var size = getBoardSize();
  }

  @override
  void onMount() {
    setColor(color);
    super.onMount();
  }
}
