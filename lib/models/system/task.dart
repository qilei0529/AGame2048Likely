// 游戏状态
import 'package:collection/collection.dart';
import 'dart:async';

class TaskItem {
  late int status = 0;
  Function action;
  TaskItem(this.action);
}

class TaskSystem {
  List<TaskItem> tasks = [];

  int max = 2;

  int queue = 0;

  bool get isTasking => queue != 0;

  TaskSystem({List<Function>? tasks, int? maxQueue}) {
    max = maxQueue ?? 2;
    this
        .tasks
        .addAll((tasks ?? []).map<TaskItem>((action) => TaskItem(action)));
  }

  Completer<bool> callback = Completer<bool>();

  Future run() async {
    if (tasks.isNotEmpty) {
      findOneAndRunTask();
    } else {
      callback.complete(true);
    }
    await callback.future;
  }

  findOneAndRunTask() {
    bool checkFinish() {
      TaskItem? task = tasks.firstWhereOrNull((task) => task.status != 2);
      return task == null;
    }

    TaskItem? findTask() {
      TaskItem? task = tasks.firstWhereOrNull((task) => task.status == 0);
      return task;
    }

    Future runTask(TaskItem task) async {
      Completer<bool> completer = Completer<bool>();
      queue += 1;
      task.action(
        () => {
          if (!completer.isCompleted) {completer.complete(true)}
        },
      );
      task.status = 1;
      var flag = await completer.future;
      if (flag) {
        task.status = 2;
        queue -= 1;
        var isFinish = checkFinish();
        if (isFinish) {
          if (!callback.isCompleted) {
            callback.complete(true);
          }
          tasks.clear();
        } else {
          findOneAndRunTask();
        }
      }
    }

    if (queue < max) {
      var task = findTask();
      if (task != null) {
        runTask(task);
        findOneAndRunTask();
      }
    }
  }

  add(Function action) {
    tasks.add(TaskItem(action));
    findOneAndRunTask();
  }
}
