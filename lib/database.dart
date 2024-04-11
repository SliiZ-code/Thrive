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

  final List<Task> tasksList = [];
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
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    List<Task> fetchedTasks = await isar.tasks.where().findAll();
    tasksList.clear();
    tasksList.addAll(fetchedTasks);
    notifyListeners();
  }

  Future<void> updateName(Id id, String name) async {
    final existingTask = await isar.tasks.get(id);
    if (existingTask != null) {
      existingTask.name = name;
      await isar.writeTxn(() => isar.tasks.put(existingTask));
      await fetchTasks();
    }
  }

  Future<void> updateDescription(Id id, String description) async {
    final existingTask = await isar.tasks.get(id);
    if (existingTask != null) {
      existingTask.description = description;
      await isar.writeTxn(() => isar.tasks.put(existingTask));
      await fetchTasks();
    }
  }

  Future<void> updateCategory(Id id, int? category) async {
    final existingTask = await isar.tasks.get(id);
    if (existingTask != null) {
      existingTask.category = category;
      await isar.writeTxn(() => isar.tasks.put(existingTask));
      await fetchTasks();
    }
  }

  Future<void> updateDate(Id id, DateTime date) async {
    final existingTask = await isar.tasks.get(id);
    if (existingTask != null) {
      existingTask.date = date;
      await isar.writeTxn(() => isar.tasks.put(existingTask));
      await fetchTasks();
    }
  }

  Future<void> updateState(Id id) async {
    final existingTask = await isar.tasks.get(id);
    if (existingTask != null) {
      existingTask.done = !existingTask.done;
      await isar.writeTxn(() => isar.tasks.put(existingTask));
      await fetchTasks();
    }
  }

  Future<void> deleteTask(Id id) async {
    await isar.writeTxn(() => isar.tasks.delete(id));
    await fetchTasks();
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
}
