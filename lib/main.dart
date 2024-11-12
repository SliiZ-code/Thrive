import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:thrive/category.dart';
import 'package:thrive/task.dart';
import 'package:thrive/database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Database.initialize();

  runApp(ChangeNotifierProvider(
    create: (context) => Database(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MyAppState(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Inter',
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey)),
          home: const MyHomePage(),
        ));
  }
}

List<List> cardsColors = [
  ["grey", Colors.grey, Colors.grey[800], Colors.grey[900]],
  ["red", Colors.red, Colors.red[800], Colors.red[900]],
  ["blue", Colors.blue, Colors.blue[800], Colors.blue[900]],
  ["green", Colors.green, Colors.green[800], Colors.green[900]],
  ["orange", Colors.orange, Colors.orange[800], Colors.orange[900]],
  ["purple", Colors.purple, Colors.purple[800], Colors.purple[900]],
  ["teal", Colors.teal, Colors.teal[800], Colors.teal[900]],
  ["pink", Colors.pink, Colors.pink[800], Colors.pink[900]],
  ["yellow", Colors.yellow, Colors.yellow[800], Colors.yellow[900]],
];

class MyAppState extends ChangeNotifier {
  int selectedIndex = 0;

  void _updateIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    context.read<Database>().fetchToDoList();
    context.read<Database>().fetchDoneList();
    context.read<Database>().fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    List<Widget> pages = [
      TaskList(appState: appState, done: false),
      TaskList(appState: appState, done: true),
      const Text("WIP"),
      const Text("WIP")
    ];

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 180,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.black,
        elevation: 14,
        title: RichText(
          text: const TextSpan(
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Inter",
                  fontSize: 32,
                  fontWeight: FontWeight.w900),
              text: "Thrive."),
        ),
        actions: [
          const IconButton(
              onPressed: null,
              icon: Icon(
                Icons.search,
                color: Colors.black,
              )),
          IconButton(
              onPressed: () {
                context.read<Database>().fetchToDoList();
                context.read<Database>().incrementSort();
              },
              icon: const Icon(
                Icons.sort_by_alpha,
                color: Colors.black,
              )),
          const SizedBox(
            width: 16,
          )
        ],
      ),
      body: pages.elementAt(appState.selectedIndex),
      bottomNavigationBar: SizedBox(
        height: 66,
        child: Container(
          decoration: const BoxDecoration(boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey,
              blurRadius: 20,
            )
          ]),
          child: BottomAppBar(
            color: Colors.white,
            elevation: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.check_box_outline_blank,
                    color: Colors.black,
                  ),
                  iconSize: 32,
                  onPressed: () {
                    setState(() {
                      appState.selectedIndex = 0;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.check_box,
                    color: Colors.black,
                  ),
                  iconSize: 32,
                  onPressed: () {
                    setState(() {
                      appState.selectedIndex = 1;
                    });
                  },
                ),
                const SizedBox(width: 82),
                IconButton(
                  icon: const Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                  iconSize: 32,
                  onPressed: () {
                    setState(() {
                      appState.selectedIndex = 2;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.black,
                  ),
                  iconSize: 32,
                  onPressed: () {
                    setState(() {
                      appState.selectedIndex = 3;
                    });
                  },
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 82,
        height: 82,
        child: FittedBox(
          child: FloatingActionButton(
            foregroundColor: Colors.white,
            backgroundColor: Colors.black,
            elevation: 1,
            shape: const CircleBorder(),
            onPressed: () {
              newTaskForm(context, appState);
            },
            tooltip: 'New task',
            child: const Icon(
              Icons.add_rounded,
              size: 52,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Future<void> newTaskForm(BuildContext context, MyAppState appState) async {
    context.read<Database>().deleteUnusedCategories();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: NewTaskFormContent(appState: appState),
        );
      },
    );
  }
}

Future<int?> categoriesMenu(BuildContext context, RelativeRect position,
    MyAppState appState, int selectedColor) {
  final db = Provider.of<Database>(context, listen: false);
  List<Category> categories = db.categories;

  return showMenu<int>(context: context, position: position, items: [
    for (var index = 0; index < categories.length; index++)
      PopupMenuItem(
        value: categories[index].id,
        child: Text(categories[index].name,
            style: TextStyle(
                color: cardsColors[categories[index].color][2],
                fontWeight: FontWeight.bold)),
      ),
    PopupMenuItem(
      value: null,
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: 112,
        height: 48,
        child: InkWell(
          child: const Row(
            children: [
              SizedBox(
                width: 8,
              ),
              Icon(Icons.add, size: 20),
              Text(
                "New",
                style: TextStyle(fontWeight: FontWeight.w300),
              ),
            ],
          ),
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Create a new category"),
                    content: Row(
                      children: [
                        Ink(
                          decoration: ShapeDecoration(
                              shape: const CircleBorder(),
                              color: cardsColors[selectedColor][1]),
                          child: IconButton(
                              color: Colors.white,
                              hoverColor: Colors.black,
                              icon: const Icon(Icons.color_lens_rounded),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SimpleDialog(
                                        title: const Text("Choose a color"),
                                        children: [
                                          SizedBox(
                                            width: 200,
                                            height: 300,
                                            child: GridView.count(
                                              crossAxisCount: 3,
                                              padding: const EdgeInsets.all(24),
                                              mainAxisSpacing: 12,
                                              crossAxisSpacing: 12,
                                              children: [
                                                for (var index = 0;
                                                    index < cardsColors.length;
                                                    index++)
                                                  FilledButton(
                                                    onPressed: () {
                                                      selectedColor = index;
                                                      Navigator.pop(context);
                                                    },
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStatePropertyAll<
                                                                    Color>(
                                                                cardsColors[
                                                                    index][1])),
                                                    child: const SizedBox(),
                                                  )
                                              ],
                                            ),
                                          )
                                        ],
                                      );
                                    });
                              }),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Flexible(
                          child: TextFormField(
                            autofocus: true,
                            onFieldSubmitted: (String category) {
                              context
                                  .read<Database>()
                                  .addCategory(category, selectedColor);
                              Navigator.pop(context);
                              if (categories.isNotEmpty) {
                                Navigator.of(context).pop(
                                    categories[categories.length - 1].id + 1);
                              } else {
                                Navigator.of(context).pop(1);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                });
          },
        ),
      ),
    ),
  ]);
}

class TaskList extends StatefulWidget {
  final bool done;
  const TaskList({super.key, required this.appState, required this.done});

  final MyAppState appState;
  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  @override
  Widget build(BuildContext context) {
    final db = context.watch<Database>();
    int sort = db.sorting;
    late List<Task> list = [];
    if (widget.done == false) {
      list = db.toDoList;
    } else {
      list = db.doneList;
    }
    List<Category> categories = db.categories;

    int getCategoryIndex(Task task) {
      for (var index = 0; index < categories.length; index++) {
        if (task.category == categories[index].id) {
          return index;
        }
      }
      return 0;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: ListView(
        children: [
          for (var index = 0; index < list.length; index++)
            Padding(
              padding:
                  const EdgeInsets.only(top: 8, left: 20, right: 20, bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: list[index].category == null
                              ? cardsColors[0][3]
                              : cardsColors[
                                  categories[getCategoryIndex(list[index])]
                                      .color][3],
                          spreadRadius: -1,
                          offset: const Offset(2, 2))
                    ]),
                child: Card(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: list[index].category == null
                              ? cardsColors[0][3]
                              : cardsColors[
                                  categories[getCategoryIndex(list[index])]
                                      .color][3],
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignOutside),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(16))),
                  elevation: 0,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16)),
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              list[index].category == null
                                  ? cardsColors[0][1]
                                  : cardsColors[
                                      categories[getCategoryIndex(list[index])]
                                          .color][1],
                              list[index].category == null
                                  ? cardsColors[0][2]
                                  : cardsColors[
                                      categories[getCategoryIndex(list[index])]
                                          .color][2]
                            ])),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 18.0),
                      child: ListTile(
                        titleAlignment: ListTileTitleAlignment.top,
                        horizontalTitleGap: 4.0,
                        contentPadding: const EdgeInsets.only(left: 4),
                        title: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                context
                                    .read<Database>()
                                    .updateState(list[index].id);
                              },
                              iconSize: 32.0,
                              icon: list[index].done
                                  ? const Icon(Icons.check_box,
                                      color: Colors.white)
                                  : const Icon(Icons.check_box_outline_blank,
                                      color: Colors.white),
                            ),
                            Expanded(
                              child: TextFormField(
                                key: Key(list[index].id.toString()),
                                initialValue: list[index].name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Inter",
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800),
                                decoration: const InputDecoration(
                                    border: InputBorder.none),
                                onChanged: (value) {
                                  context
                                      .read<Database>()
                                      .updateName(list[index].id, value);
                                },
                              ),
                            ),
                            GestureDetector(
                              child: TextButton(
                                  onPressed: () {
                                    null;
                                  },
                                  style: TextButton.styleFrom(
                                      padding: const EdgeInsets.only(left: 6)),
                                  child: Text(
                                      list[index].category != null
                                          ? list[index].date != null
                                              ? "${categories[getCategoryIndex(list[index])].name}  •"
                                              : categories[getCategoryIndex(
                                                      list[index])]
                                                  .name
                                          : "",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Inter",
                                        fontSize: 16,
                                        fontWeight:
                                            sort % 4 == 1 || sort % 4 == 2
                                                ? FontWeight.w600
                                                : FontWeight.w300,
                                      ))),
                              onTapDown: (details) async {
                                final newCategory = await categoriesMenu(
                                    context,
                                    RelativeRect.fromRect(
                                        details.globalPosition &
                                            const Size(40, 40),
                                        Offset.zero &
                                            Overlay.of(context)
                                                .context
                                                .findRenderObject()!
                                                .semanticBounds
                                                .size),
                                    widget.appState,
                                    0);
                                context.read<Database>().updateCategory(
                                    list[index].id, newCategory);
                              },
                            ),
                            TextButton(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: list[index].date,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  context
                                      .read<Database>()
                                      .updateDate(list[index].id, date);
                                }
                              },
                              child: Text(
                                  list[index].date != null
                                      ? 'in ${list[index].date!.difference(DateTime.now()).inDays + 1} days'
                                      : '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Inter",
                                    fontSize: 16,
                                    fontWeight: sort % 4 == 3 || sort % 4 == 0
                                        ? FontWeight.w600
                                        : FontWeight.w300,
                                  )),
                            ),
                            const SizedBox(
                              width: 12.0,
                            )
                          ],
                        ),
                        subtitle: Padding(
                          padding:
                              const EdgeInsets.only(left: 22.0, right: 22.0),
                          child: TextFormField(
                            maxLines: null,
                            initialValue: list[index].description != null
                                ? list[index].description!
                                : "",
                            decoration:
                                const InputDecoration(border: InputBorder.none),
                            style: const TextStyle(
                                color: Colors.white,
                                fontFamily: "Inter",
                                fontSize: 14,
                                fontWeight: FontWeight.w200),
                            onChanged: (value) {
                              context
                                  .read<Database>()
                                  .updateDescription(list[index].id, value);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

class NewTaskFormContent extends StatefulWidget {
  final MyAppState appState;

  const NewTaskFormContent({super.key, required this.appState});

  @override
  NewTaskFormContentState createState() => NewTaskFormContentState();
}

class NewTaskFormContentState extends State<NewTaskFormContent> {
  String taskText = "";
  String? taskDescription;
  DateTime? selectedDate;
  int? selectedCategoryId;
  int selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final db = context.watch<Database>();
    List<Category> categories = db.categories;

    int getCategoryIndex(int id) {
      for (var index = 0; index < categories.length; index++) {
        if (categories[index].id == id) {
          return index;
        }
      }
      return 0;
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 80,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 20.0, bottom: 10.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Task",
                      labelStyle: TextStyle(fontWeight: FontWeight.bold)),
                  onSubmitted: (String text) {
                    context.read<Database>().addTask(taskText, taskDescription,
                        selectedCategoryId, selectedDate);
                    appState._updateIndex(0);
                    Navigator.pop(context);
                  },
                  onChanged: (String text) {
                    taskText = text;
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            height: 80,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 0.0, bottom: 10.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Description (optionnal)",
                      labelStyle: TextStyle(fontWeight: FontWeight.w300)),
                  onChanged: (String description) {
                    taskDescription = description;
                  },
                ),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                  onPressed: () async {
                    final RenderBox button =
                        context.findRenderObject() as RenderBox;
                    final RenderBox overlay = Overlay.of(context)
                        .context
                        .findRenderObject() as RenderBox;
                    final RelativeRect position = RelativeRect.fromRect(
                      Rect.fromPoints(
                        button.localToGlobal(Offset.zero, ancestor: overlay),
                        button.localToGlobal(
                            button.size.bottomRight(Offset.zero),
                            ancestor: overlay),
                      ),
                      Offset.zero & overlay.size,
                    );
                    selectedCategoryId = await categoriesMenu(
                        context, position, appState, selectedColor);
                    context.read<Database>().fetchCategories();
                  },
                  label: constraints.maxWidth >= 365
                      ? selectedCategoryId == null
                          ? const Text("Category")
                          : Text(
                              categories[getCategoryIndex(selectedCategoryId!)]
                                  .name)
                      : Container(),
                  icon: const Icon(Icons.label),
                  style: ButtonStyle(
                      foregroundColor: MaterialStatePropertyAll<Color>(
                          selectedCategoryId == null
                              ? cardsColors[0][2]
                              : cardsColors[categories[
                                      getCategoryIndex(selectedCategoryId!)]
                                  .color][2]))),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      selectedDate = date;
                    });
                  }
                },
                label: constraints.maxWidth >= 365
                    ? selectedDate == null
                        ? const Text("Date")
                        : Text(DateFormat.MMMd().format(selectedDate!))
                    : Container(),
                icon: const Icon(Icons.calendar_month),
                style: ButtonStyle(
                    foregroundColor: MaterialStatePropertyAll<Color>(
                        selectedCategoryId == null
                            ? cardsColors[0][2]
                            : cardsColors[categories[
                                    getCategoryIndex(selectedCategoryId!)]
                                .color][2])),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton.icon(
                  onPressed: () {
                    context.read<Database>().addTask(taskText, taskDescription,
                        selectedCategoryId, selectedDate);
                    appState._updateIndex(0);
                    Navigator.pop(context);
                  },
                  label: constraints.maxWidth >= 365
                      ? const Text("Done")
                      : Container(),
                  icon: const Icon(Icons.check),
                  style: ButtonStyle(
                      foregroundColor: MaterialStatePropertyAll<Color>(
                          selectedCategoryId == null
                              ? cardsColors[0][2]
                              : cardsColors[categories[
                                      getCategoryIndex(selectedCategoryId!)]
                                  .color][2]))),
            ],
          ),
          const SizedBox(
            height: 10,
          )
        ],
      );
    });
  }
}
