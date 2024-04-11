import 'package:isar/isar.dart';

part 'task.g.dart';

@collection
class Task {
  Id id = Isar.autoIncrement;
  String name;
  String? description;
  DateTime? date;
  int? category;
  bool done;

  Task(this.name,
      {this.description, this.category, this.date, this.done = false});
}
