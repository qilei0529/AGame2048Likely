import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game_2048_fight/models/system/board.dart';
import 'package:flutter_game_2048_fight/models/system/game.dart';
import 'package:flutter_game_2048_fight/models/system/task.dart';
import 'package:flutter_game_2048_fight/scenes/world_scene.dart';

abstract class BoardItemWidget extends PositionComponent {
  late GamePoint point = GamePoint.bottom;

  // 出生
  toBorn({Function? onComplete});

  // 等待
  toWait();

  // 触发
  toTrigger();

  // 死亡 / 消失
  toDead({Function? onComplete});
}

class BlockItem extends BoardItemWidget {
  final TaskSystem task = TaskSystem(maxQueue: 1);

  late final Component block;
  late final Component cover;
  late final Component body;

  late Vector2 _face = Vector2(1, 1);

  @override
  toBorn({Function? onComplete}) {
    // var position = getBoardPositionAt(pos.x, pos.y);
    // this.position = position;
    task.add((next) {
      // move self
      block.add(
        createBornEffect(
          onComplete: () {
            next();
            onComplete != null ? onComplete() : null;
          },
        ),
      );
    });
  }

  @override
  toDead({Function? onComplete}) {
    task.add((next) {
      // add run
      block.add(
        SequenceEffect(
          [ScaleEffect.to(Vector2(1, 1), dur(0.1))],
          onComplete: () {
            next();
            onComplete != null ? onComplete() : null;
          },
        ),
      );
    });
  }

  @override
  toTrigger({Function? onComplete}) {
    onComplete != null ? onComplete() : null;
  }

  @override
  toWait() {
    // TODO: implement toWait
    throw UnimplementedError();
  }

  toTurn(
      {required GamePoint point,
      bool? needTurn = false,
      Function? onComplete}) {
    this.point = point;

    if (needTurn == true) {
      if (point == GamePoint.right) {
        _face = Vector2(-1, 1);
      } else if (point == GamePoint.left) {
        _face = Vector2(1, 1);
      }
    }

    task.add((next) {
      body.add(
        SequenceEffect(
          [ScaleEffect.to(_face, dur(0.04))],
          onComplete: () {
            next();
            onComplete != null ? onComplete() : null;
          },
        ),
      );
    });
  }

  toMove({required BoardPosition pos, Function? onComplete}) {
    task.add((next) {
      var position = getBoardPositionAt(pos.x, pos.y);
      // move self
      add(
        createMoveEffect(
          position: position,
          onComplete: () {
            next();
            onComplete != null ? onComplete() : null;
          },
        ),
      );
    });
  }
}

class BlockActiveItem extends BlockItem {
  int life = 0;
  int act = 0;

  toInjure({int? life, Function? onComplete}) {
    task.add((next) {
      var box = RectangleComponent(
        size: size,
      );
      box.setColor(Colors.red);
      box.add(
        SequenceEffect(
          [
            OpacityEffect.to(0, dur(0)),
            OpacityEffect.to(1, dur(0.05)),
            OpacityEffect.to(0, dur(0.05)),
          ],
          onComplete: () {
            box.removeFromParent();
          },
        ),
      );
      block.add(box);

      block.add(
        SequenceEffect(
          [MoveToEffect(Vector2(0, 0), dur(0.2))],
          onComplete: () {
            next();
            onComplete != null ? onComplete() : null;
          },
        ),
      );
    });
  }

  toAttack({Function? onComplete}) {
    task.add((next) {
      // move self
      add(
        createAttackEffect(
          point: point,
          onComplete: () {
            next();
            onComplete != null ? onComplete() : null;
          },
        ),
      );
    });
  }
}

EffectController dur(double x) => EffectController(duration: x);

SequenceEffect createMoveEffect({
  required Vector2 position,
  Function? onComplete,
}) {
  return SequenceEffect(
    [MoveEffect.to(position, dur(0.16))],
    onComplete: () => onComplete != null ? onComplete() : null,
  );
}

SequenceEffect createBornEffect({Function? onComplete}) {
  return SequenceEffect(
    [
      MoveToEffect(Vector2(0, -80), dur(0)),
      MoveToEffect(Vector2(0, 0), dur(0.2)),
      MoveToEffect(Vector2(0, -8), dur(0.08)),
      MoveToEffect(Vector2(0, 0), dur(0.04)),
    ],
    onComplete: () => onComplete != null ? onComplete() : null,
  );
}

SequenceEffect createAttackEffect({
  required GamePoint point,
  Function? onComplete,
}) {
  var p = point.toPosition();
  return SequenceEffect(
    [
      MoveEffect.by(
        Vector2(-8 * p.x.toDouble(), -8 * p.y.toDouble()),
        EffectController(
          duration: 0.16,
          reverseDuration: 0.16,
          atMinDuration: 0.2,
          curve: Curves.ease,
          infinite: false,
        ),
      ),
    ],
    onComplete: () => onComplete != null ? onComplete() : null,
  );
}
