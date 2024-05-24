import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

// frame
import 'package:flame/components.dart';
import 'package:flutter_game_2048_fight/models/system/block.dart';
import 'package:flutter_game_2048_fight/models/system/game.dart';

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

  dead() {
    // var pos = getGroundPositionAt(p.x, p.y);
    EffectController duration(double x) => EffectController(duration: x);

    _tasks.add(
      SequenceEffect(
        [
          OpacityEffect.to(1, duration(0)),
          RemoveEffect(delay: 0.5),
        ],
        onComplete: () {
          // change life;
          _onEffect = false;
          checkTask();
        },
      ),
    );
    checkTask();
  }

  attack() {
    EffectController duration(double x) => EffectController(duration: x);
    // this.add()
    var p = point.toPosition();
    _tasks.add(
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
          _onEffect = false;
          checkTask();
        },
      ),
    );

    checkTask();
  }

  moveTo(int x, int y) {
    var pos = getGroundPositionAt(x, y);
    EffectController duration(double x) => EffectController(duration: x);

    var p = point.toPosition();
    _tasks.add(
      SequenceEffect(
        [
          MoveEffect.to(
            pos,
            duration(0.16),
          ),
          // MoveEffect.by(
          //   Vector2(-8 * p.x.toDouble(), -8 * p.y.toDouble()),
          //   EffectController(
          //     duration: 0.16,
          //     reverseDuration: 0.16,
          //     // startDelay: 0.2,
          //     atMinDuration: 0.2,
          //     curve: Curves.ease,
          //     infinite: false,
          //   ),
          // ),
        ],
        onComplete: () {
          _onEffect = false;
          checkTask();
        },
      ),
    );

    checkTask();
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
