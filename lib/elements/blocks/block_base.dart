import 'package:flame/components.dart';
import 'package:flutter_game_2048_fight/models/system/board.dart';
import 'package:flutter_game_2048_fight/models/system/game.dart';

abstract class BoardItemWidget extends PositionComponent {
  late GamePoint point;
  late BoardPosition pos;

  // 出生
  toBorn();

  // 等待
  toWait();

  // 触发
  toTrigger();

  // 死亡 / 消失
  toDead();
}
