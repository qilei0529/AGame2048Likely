// 游戏状态

import 'system/game.dart';

class GameSystem {
  // 游戏状态
  GameStatus status = GameStatus.start;

  late GameLevelData level;

  // 记录 每一步的信息
  List<GameStepData> steps = [];

  // 当前 步骤
  int currentStepIndex = 0;
  // 当前 步骤的数据
  GameStepData get currentStep => steps[currentStepIndex];

  // 初始化
  GameSystem() {
    print("world init");
  }

  // 更新 level
  setLevel(GameLevelData level) {
    this.level = level;
  }

  gameStart() {}
  gamePause() {}
  gameOver() {}
  gameRestart() {}

  actionSlide() {}
  actionAdd() {}
  actionUpdate() {}
  actionConfig() {}
  actionNext() {}

  stepAdd() {}
  stepCheck() {}
}
