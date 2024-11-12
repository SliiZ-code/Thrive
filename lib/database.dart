import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thrive/category.dart';
import 'package:thrive/task.dart';

class Database extends ChangeNotifier {
  static late Isar isar;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([TaskSchema, CategorySchema], directory: dir.path);
  }

  int sorting = 0;
  final List<Task> toDoList = [];
  final List<Task> doneList = [];
  final List<Category> categories = [];

  // Tasks

  Future<void> addTask(String task,
      [String? description, int? category, DateTime? date]) async {
    await isar.writeTxn(() async {
      await isar.tasks.put(Task(
        task,
        description: description,
        category: category,
        date: date,
      ));
    });
    fetchToDoList();
    fetchDoneList();
  }

  Future<void> fetchToDoList() async {
    switch (sorting % 4) {
      case 0:
        List<Task> fetchedTasks = await isar.tasks
            .filter()
            .doneEqualTo(false)
            .sortByCategory()
            .findAll();
        toDoList.clear();
        toDoList.addAll(fetchedTasks);
        notifyListeners();
      case 1:
        List<Task> fetchedTasks = await isar.tasks
            .filter()
            .doneEqualTo(false)
            .sortByCategoryDesc()
            .findAll();
        toDoList.clear();
        toDoList.addAll(fetchedTasks);
        notifyListeners();
      case 2:
        List<Task> fetchedTasks =
            await isar.tasks.filter().doneEqualTo(false).sortByDate().findAll();
        toDoList.clear();
        toDoList.addAll(fetchedTasks);
        notifyListeners();
      case 3:
        List<Task> fetchedTasks = await isar.tasks
            .filter()
            .doneEqualTo(false)
            .sortByDateDesc()
            .findAll();
        toDoList.clear();
        toDoList.addAll(fetchedTasks);
        notifyListeners();
    }
  }

  void incrementSort() {
    sorting++;
  }

  Future<void> fetchDoneList() async {
    List<Task> fetchedTasks =
        await isar.tasks.filter().doneEqualTo(true).findAll();
    doneList.clear();
    doneList.addAll(fetchedTasks);
    notifyListeners();
  }

  Future<void> updateName(Id id, String name) async {
    final existingTask = await isar.tasks.get(id);
    if (existingTask != null) {
      existingTask.name = name;
      await isar.writeTxn(() => isar.tasks.put(existingTask));
      await fetchToDoList();
      await fetchDoneList();
    }
  }

  Future<void> updateDescription(Id id, String description) async {
    final existingTask = await isar.tasks.get(id);
    if (existingTask != null) {
      existingTask.description = description;
      await isar.writeTxn(() => isar.tasks.put(existingTask));
      await fetchToDoList();
      await fetchDoneList();
    }
  }

  Future<void> updateCategory(Id id, int? category) async {
    final existingTask = await isar.tasks.get(id);
    if (existingTask != null) {
      existingTask.category = category;
      await isar.writeTxn(() => isar.tasks.put(existingTask));
      await fetchToDoList();
      await fetchDoneList();
    }
  }

  Future<void> updateDate(Id id, DateTime date) async {
    final existingTask = await isar.tasks.get(id);
    if (existingTask != null) {
      existingTask.date = date;
      await isar.writeTxn(() => isar.tasks.put(existingTask));
      await fetchToDoList();
      await fetchDoneList();
    }
  }

  Future<void> updateState(Id id) async {
    final existingTask = await isar.tasks.get(id);
    if (existingTask != null) {
      existingTask.done = !existingTask.done;
      await isar.writeTxn(() => isar.tasks.put(existingTask));
      await fetchToDoList();
      await fetchDoneList();
    }
  }

  Future<void> deleteTask(Id id) async {
    await isar.writeTxn(() => isar.tasks.delete(id));
    await fetchToDoList();
    await fetchDoneList();
  }

  // Categories

  Future<void> addCategory(String name, int color) async {
    await isar.writeTxn(() async {
      await isar.categories.put(Category(name, color));
    });
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    List<Category> fetchedCategories = await isar.categories.where().findAll();
    categories.clear();
    categories.addAll(fetchedCategories);
    notifyListeners();
  }

  Future<void> deleteCategory(Id id) async {
    await isar.writeTxn(() => isar.categories.delete(id));
    await fetchCategories();
  }

  Future<void> deleteUnusedCategories() async {
    print("delete Unused Categories");
    fetchCategories();
    fetchDoneList();
    fetchToDoList();
    for (var index = 0; index < categories.length; index++) {
      var counter = 0;
      for (var j = 0; j < toDoList.length; j++) {
        if (toDoList[j].category == categories[index].id) {
          counter++;
        }
      }
      for (var k = 0; k < doneList.length; k++) {
        if (toDoList[k].category == categories[index].id) {
          counter++;
        }
      }
      if (counter == 0) {
        deleteCategory(categories[index].id);
      }
    }
  }
}
