import 'package:flutter_game_2048_fight/models/game_system.dart';
import 'package:flutter_game_2048_fight/models/system/board.dart';
import 'package:flutter_game_2048_fight/models/system/game.dart';
import 'package:flutter_game_2048_fight/models/util.dart';

class MovePointEvent extends GameMoveEvent {
  GameSystem system;

  // move
  MovePointEvent({required this.system});

  @override
  bool? action(payload) {
    var block = payload.block;
    var point = payload.point;

    block.move = 6;
    block.point = point;

    return null;
  }
}
