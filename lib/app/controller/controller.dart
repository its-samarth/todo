import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:listsbysam/app/data/schema.dart';
import 'package:listsbysam/app/services/notification.dart';
import 'package:listsbysam/main.dart';

class TodoController extends GetxController {
  final tasks = <Tasks>[].obs;
  final todos = <Todos>[].obs;

  @override
  void onInit() {
    super.onInit();
    tasks.assignAll(isar.tasks.where().sortByIndex().findAllSync());
    todos.assignAll(isar.todos.where().findAllSync());
  }

  // Tasks
  Future<void> addTask(String title, String desc, Color myColor) async {
    List<Tasks> searchTask;
    final taskCollection = isar.tasks;
    searchTask = await taskCollection.filter().titleEqualTo(title).findAll();

    final taskCreate = Tasks(
      title: title,
      description: desc,
      taskColor: myColor.value,
    );

    if (searchTask.isEmpty) {
      await isar.writeTxn(() async {
        tasks.add(taskCreate);
        await isar.tasks.put(taskCreate);
      });
      EasyLoading.showSuccess('createCategory'.tr,
          duration: const Duration(milliseconds: 500));
    } else {
      EasyLoading.showError('duplicateCategory'.tr,
          duration: const Duration(milliseconds: 500));
    }
  }

  Future<void> updateTask(
      Tasks task, String title, String desc, Color myColor) async {
    await isar.writeTxn(() async {
      task.title = title;
      task.description = desc;
      task.taskColor = myColor.value;
      await isar.tasks.put(task);

      var newTask = task;
      int oldIdx = tasks.indexOf(task);
      tasks[oldIdx] = newTask;
      tasks.refresh();
      todos.refresh();
    });
    EasyLoading.showSuccess('editCategory'.tr,
        duration: const Duration(milliseconds: 500));
  }

  Future<void> deleteTask(Tasks task) async {
    // Delete Notification
    List<Todos> getTodo;
    final taskCollection = isar.todos;
    getTodo = await taskCollection
        .filter()
        .task((q) => q.idEqualTo(task.id))
        .findAll();

    for (var element in getTodo) {
      if (element.todoCompletedTime != null) {
        await flutterLocalNotificationsPlugin.cancel(element.id);
      }
    }
    // Delete Todos
    await isar.writeTxn(() async {
      todos.removeWhere((todo) => todo.task.value == task);
      await isar.todos.filter().task((q) => q.idEqualTo(task.id)).deleteAll();
    });
    // Delete Task
    await isar.writeTxn(() async {
      tasks.remove(task);
      await isar.tasks.delete(task.id);
    });
    EasyLoading.showSuccess('categoryDelete'.tr,
        duration: const Duration(milliseconds: 500));
  }

  Future<void> archiveTask(Tasks task) async {
    // Delete Notification
    List<Todos> getTodo;
    final taskCollection = isar.todos;
    getTodo = await taskCollection
        .filter()
        .task((q) => q.idEqualTo(task.id))
        .findAll();

    for (var element in getTodo) {
      if (element.todoCompletedTime != null) {
        await flutterLocalNotificationsPlugin.cancel(element.id);
      }
    }
    // Archive Task
    await isar.writeTxn(() async {
      task.archive = true;
      await isar.tasks.put(task);

      tasks.refresh();
      todos.refresh();
    });
    EasyLoading.showSuccess('taskArchive'.tr,
        duration: const Duration(milliseconds: 500));
  }

  Future<void> noArchiveTask(Tasks task) async {
    // Create Notification
    List<Todos> getTodo;
    final taskCollection = isar.todos;
    getTodo = await taskCollection
        .filter()
        .task((q) => q.idEqualTo(task.id))
        .findAll();

    for (var element in getTodo) {
      if (element.todoCompletedTime != null) {
        NotificationShow().showNotification(
          element.id,
          element.name,
          element.description,
          element.todoCompletedTime,
        );
      }
    }
    // No archive Task
    await isar.writeTxn(() async {
      task.archive = false;
      await isar.tasks.put(task);

      tasks.refresh();
      todos.refresh();
    });
    EasyLoading.showSuccess('noTaskArchive'.tr,
        duration: const Duration(milliseconds: 500));
  }

  // Todos
  Future<void> addTodo(
      Tasks task, String title, String desc, String time) async {
    DateTime? date;
    if (time.isNotEmpty) {
      date = DateFormat.yMMMEd(locale.languageCode).add_Hm().parse(time);
    }
    final todosCollection = isar.todos;
    List<Todos> getTodos;
    getTodos = await todosCollection
        .filter()
        .nameEqualTo(title)
        .task((q) => q.idEqualTo(task.id))
        .todoCompletedTimeEqualTo(date)
        .findAll();

    final todosCreate = Todos(
      name: title,
      description: desc,
      todoCompletedTime: date,
    )..task.value = task;

    if (getTodos.isEmpty) {
      await isar.writeTxn(() async {
        todos.add(todosCreate);
        await isar.todos.put(todosCreate);
        await todosCreate.task.save();
        if (time.isNotEmpty) {
          NotificationShow().showNotification(
            todosCreate.id,
            todosCreate.name,
            todosCreate.description,
            date,
          );
        }
      });
      EasyLoading.showSuccess('taskCreate'.tr,
          duration: const Duration(milliseconds: 500));
    } else {
      EasyLoading.showError('duplicateTask'.tr,
          duration: const Duration(milliseconds: 500));
    }
  }

  Future<void> updateTodoCheck(Todos todo) async {
    await isar.writeTxn(() async => isar.todos.put(todo));
    todos.refresh();
  }

  Future<void> updateTodo(
      Todos todo, Tasks task, String title, String desc, String time) async {
    DateTime? date;
    if (time.isNotEmpty) {
      date = DateFormat.yMMMEd(locale.languageCode).add_Hm().parse(time);
    }
    await isar.writeTxn(() async {
      todo.name = title;
      todo.description = desc;
      todo.todoCompletedTime = date;
      todo.task.value = task;
      await isar.todos.put(todo);
      await todo.task.save();

      var newTodo = todo;
      int oldIdx = todos.indexOf(todo);
      todos[oldIdx] = newTodo;
      todos.refresh();

      if (time.isNotEmpty) {
        await flutterLocalNotificationsPlugin.cancel(todo.id);
        NotificationShow().showNotification(
          todo.id,
          todo.name,
          todo.description,
          date,
        );
      } else {
        await flutterLocalNotificationsPlugin.cancel(todo.id);
      }
    });
    EasyLoading.showSuccess('update'.tr,
        duration: const Duration(milliseconds: 500));
  }

  Future<void> deleteTodo(Todos todo) async {
    await isar.writeTxn(() async {
      todos.remove(todo);
      await isar.todos.delete(todo.id);
      if (todo.todoCompletedTime != null) {
        await flutterLocalNotificationsPlugin.cancel(todo.id);
      }
    });
    EasyLoading.showSuccess('taskDelete'.tr,
        duration: const Duration(milliseconds: 500));
  }

  int createdAllTodos() {
    return todos.where((todo) => todo.task.value?.archive == false).length;
  }

  int completedAllTodos() {
    return todos
        .where((todo) => todo.task.value?.archive == false && todo.done == true)
        .length;
  }

  int createdAllTodosTask(Tasks task) {
    return todos.where((todo) => todo.task.value?.id == task.id).length;
  }

  int completedAllTodosTask(Tasks task) {
    return todos
        .where((todo) => todo.task.value?.id == task.id && todo.done == true)
        .length;
  }

  int countTotalTodosCalendar(DateTime date) {
    return todos
        .where((todo) =>
            todo.done == false &&
            todo.todoCompletedTime != null &&
            todo.task.value?.archive == false &&
            DateTime(date.year, date.month, date.day, 0, -1)
                .isBefore(todo.todoCompletedTime!) &&
            DateTime(date.year, date.month, date.day, 23, 60)
                .isAfter(todo.todoCompletedTime!))
        .length;
  }

  void backup() async {
    final dlPath = await FilePicker.platform.getDirectoryPath();

    if (dlPath == null) {
      EasyLoading.showInfo('errorPath'.tr);
      return;
    }

    try {
      final timeStamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

      final taskFileName = 'task_$timeStamp.json';
      final todoFileName = 'todo_$timeStamp.json';

      final fileTask = File('$dlPath/$taskFileName');
      final fileTodo = File('$dlPath/$todoFileName');

      final task = await isar.tasks.where().exportJson();
      final todo = await isar.todos.where().exportJson();

      await fileTask.writeAsString(jsonEncode(task));
      await fileTodo.writeAsString(jsonEncode(todo));
      EasyLoading.showSuccess('successBackup'.tr);
    } catch (e) {
      EasyLoading.showError('error'.tr);
      return Future.error(e);
    }
  }

  void restore() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: true,
    );

    if (result == null) {
      EasyLoading.showInfo('errorPathRe'.tr);
      return;
    }

    bool taskSuccessShown = false;
    bool todoSuccessShown = false;

    for (final files in result.files) {
      final name = files.name.substring(0, 4);
      final file = File(files.path!);
      final jsonString = await file.readAsString();
      final dataList = jsonDecode(jsonString);

      for (final data in dataList) {
        await isar.writeTxn(() async {
          if (name == 'task') {
            try {
              final task = Tasks.fromJson(data);
              final existingTask =
                  tasks.firstWhereOrNull((t) => t.id == task.id);

              if (existingTask == null) {
                tasks.add(task);
              }
              await isar.tasks.put(task);
              if (!taskSuccessShown) {
                EasyLoading.showSuccess('successRestoreTask'.tr);
                taskSuccessShown = true;
              }
            } catch (e) {
              EasyLoading.showError('error'.tr);
              return Future.error(e);
            }
          } else if (name == 'todo') {
            try {
              final searchTask = await isar.tasks
                  .filter()
                  .titleEqualTo('titleRe'.tr)
                  .findAll();
              final task = searchTask.isNotEmpty
                  ? searchTask.first
                  : Tasks(
                      title: 'titleRe'.tr,
                      description: 'descriptionRe'.tr,
                      taskColor: 4284513675,
                    );
              final existingTask =
                  tasks.firstWhereOrNull((t) => t.id == task.id);

              if (existingTask == null) {
                tasks.add(task);
              }
              await isar.tasks.put(task);
              final todo = Todos.fromJson(data)..task.value = task;
              final existingTodos =
                  todos.firstWhereOrNull((t) => t.id == todo.id);
              if (existingTodos == null) {
                todos.add(todo);
              }
              await isar.todos.put(todo);
              await todo.task.save();
              if (todo.todoCompletedTime != null) {
                NotificationShow().showNotification(
                  todo.id,
                  todo.name,
                  todo.description,
                  todo.todoCompletedTime,
                );
              }
              if (!todoSuccessShown) {
                EasyLoading.showSuccess('successRestoreTodo'.tr);
                todoSuccessShown = true;
              }
            } catch (e) {
              EasyLoading.showError('error'.tr);
              return Future.error(e);
            }
          } else {
            EasyLoading.showInfo('errorFile'.tr);
          }
        });
      }
    }
  }
}
