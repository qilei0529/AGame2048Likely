import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game_2048_fight/models/board_system.dart';
import 'package:flutter_game_2048_fight/scenes/main_scene.dart';

class BoardComponent extends ShapeComponent with HasGameReference<MainScene> {
  BoardComponent({
    required ComponentKey key,
    required Vector2 position,
  }) : super(
          // key: key,
          anchor: Anchor.center,
          position: position,
        );

  late TextComponent life = TextComponent(
    text: "0",
    textRenderer: TextPaint(
      style: TextStyle(
        fontSize: 32,
        color: BasicPalette.red.color,
      ),
    ),
  );
  late TextComponent level = TextComponent(
    text: "1",
    textRenderer: TextPaint(
      style: TextStyle(
        fontSize: 20,
        color: BasicPalette.yellow.color,
      ),
    ),
    position: Vector2(50, 10),
  );

  @override
  void onMount() {
    super.onMount();
    size = Vector2(60, 60);
    debugMode = true;
    add(life);
    add(level);
  }

  List<SequenceEffect> _tasks = [];
  bool _onEffect = false;

  checkTask() {
    if (_onEffect) {
      return;
    }
    if (_tasks.isNotEmpty) {
      var first = _tasks.first;
      // start
      _onEffect = true;
      add(first);
      _tasks.removeAt(0);
    } else {
      _onEffect = false;
    }
  }

  lifeTo(int num) {
    // var pos = getGroundPositionAt(p.x, p.y);
    EffectController duration(double x) => EffectController(duration: x);

    _tasks.add(
      SequenceEffect(
        [
          OpacityEffect.to(1, duration(0)),
        ],
        onComplete: () {
          // change life;
          life.text = "$num";
          _onEffect = false;
          checkTask();
        },
      ),
    );
    checkTask();
  }

  levelTo(int num) {
    // var pos = getGroundPositionAt(p.x, p.y);
    EffectController duration(double x) => EffectController(duration: x);

    _tasks.add(
      SequenceEffect(
        [
          OpacityEffect.to(1, duration(0)),
        ],
        onComplete: () {
          // change life;
          level.text = "$num";
          _onEffect = false;
          checkTask();
        },
      ),
    );
    checkTask();
  }

  moveTo(int x, int y, PointType point) {
    var pos = getGroundPositionAt(x, y);
    EffectController duration(double x) => EffectController(duration: x);
    // this.add()
    var p = point.toPosition();
    _tasks.add(
      SequenceEffect(
        [
          MoveEffect.to(
            pos,
            duration(0.2),
          ),
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
          _onEffect = false;
          checkTask();
        },
      ),
    );

    checkTask();
  }

  dead() {
    add(RemoveEffect(delay: 0.5));
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

  // get the position from int x y
  getGridPositionAt(int x, int y) {
    var width = game.camera.visibleWorldRect.width;
    var height = game.camera.visibleWorldRect.height;
    Vector2 offset = Vector2(width / 2 - 15, height / 2 - 5);
    var dx = 40.0 * x.toDouble() - 5 - offset.x;
    var dy = 40.0 * y.toDouble() - 5 - offset.y;
    return Vector2(dx, dy);
  }
}
