import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

// frame
import 'package:flame/components.dart';
import 'package:flutter_game_2048_fight/models/system/game.dart';
import 'package:flutter_game_2048_fight/models/system/task.dart';

// scene
import 'package:flutter_game_2048_fight/scenes/game_scene.dart';

class BoardItemComponent extends RectangleComponent
    with HasGameReference<TheGameScene> {
  late Color color;
  late GamePoint point;

  BoardItemComponent({
    super.key,
    super.position,
    Vector2? size,
    Color? color,
    int? life,
    GamePoint? point,
  }) {
    this.color = color ?? Colors.white60;
    super.size = size ?? Vector2(56, 56);
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

  late TextComponent level = TextComponent(
    text: "",
    textRenderer: TextPaint(
      style: TextStyle(
        fontSize: 24,
        color: Colors.black45,
      ),
    ),
    position: Vector2(35, 25),
  );
  late TextComponent code = TextComponent(
    text: "code",
    textRenderer: TextPaint(
      style: TextStyle(
        fontSize: 12,
        color: Colors.black45,
      ),
    ),
    position: Vector2(0, 35),
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
            OpacityEffect.to(1, duration(0.2)),
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

  setLevel(int level) {
    this.level.text = "$level";
  }

  setCode(String code) {
    this.code.text = code;
  }

  @override
  void onMount() {
    setColor(color);
    add(life);
    add(level);
    add(code);
    super.onMount();
  }
}
