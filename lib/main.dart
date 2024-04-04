import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MyAppState(),
        child: MaterialApp(
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

class Task {
  String name;
  String? description;
  DateTime? date;
  int? category;
  bool done;

  Task(this.name,
      {this.description, this.category, this.date, this.done = false});
}

class MyAppState extends ChangeNotifier {
  var toDoList = <Task>[
    Task("Task 1",
        category: 0, date: DateTime.now().add(const Duration(hours: 24 * 1))),
    Task("Task 2",
        category: 1, date: DateTime.now().add(const Duration(hours: 24 * 2))),
    Task("Task 3",
        category: 0,
        date: DateTime.now().add(const Duration(hours: 24 * 3)),
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed non risus. Suspendisse lectus tortor, dignissim sit amet, adipiscing nec"),
    Task("Task 4",
        category: 2, date: DateTime.now().add(const Duration(hours: 24 * 4))),
    Task("Task 5",
        category: 1,
        date: DateTime.now().add(const Duration(hours: 24 * 5)),
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed non risus. Suspendisse lectus tortor, dignissim sit amet, adipiscing nec"),
  ];
  var doneList = <Task>[];
  var categories = <List>[
    ["Work", 1],
    ["School", 2],
    ["Social", 3]
  ];

  int sorting = 0;
  int selectedIndex = 0;

  void newTask(String task,
      [String? description, int? category, DateTime? date]) {
    toDoList.add(Task(
      task,
      description: description,
      category: category,
      date: date,
    ));
    notifyListeners();
  }

  void taskDone(int index) {
    toDoList[index].done = !toDoList[index].done;
    doneList.add(toDoList[index]);
    toDoList.removeAt(index);
    notifyListeners();
  }

  void taskToDo(int index) {
    doneList[index].done = !doneList[index].done;
    toDoList.add(doneList[index]);
    doneList.removeAt(index);
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
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    List<Widget> pages = [
      TaskList(
        appState: appState,
        list: appState.toDoList,
      ),
      TaskList(
        appState: appState,
        list: appState.doneList,
      ),
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
                switch (appState.sorting % 4) {
                  case 0:
                    appState.toDoList.sort((a, b) =>
                        a.category != null && b.category != null
                            ? b.category!.compareTo(a.category!)
                            : 1);
                  case 1:
                    appState.toDoList.sort((a, b) =>
                        a.category != null && b.category != null
                            ? a.category!.compareTo(b.category!)
                            : 1);
                  case 2:
                    appState.toDoList.sort((a, b) =>
                        a.date != null && b.date != null
                            ? a.date!.compareTo(b.date!)
                            : 1);
                  case 3:
                    appState.toDoList.sort((a, b) =>
                        a.date != null && b.date != null
                            ? b.date!.compareTo(a.date!)
                            : 1);
                }
                appState.sorting++;
                appState.notifyListeners();
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
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            iconSize: 32.0,
            elevation: 16.0,
            items: const [
              BottomNavigationBarItem(
                  label: "ToDo",
                  icon: Icon(
                    Icons.check_box_outline_blank,
                    color: Colors.black,
                  )),
              BottomNavigationBarItem(
                  label: "Done",
                  icon: Icon(
                    Icons.check_box,
                    color: Colors.black,
                  )),
              BottomNavigationBarItem(
                  label: "Add",
                  icon: Icon(
                    Icons.add,
                    color: Colors.black,
                  )),
              BottomNavigationBarItem(
                  label: "Account",
                  icon: Icon(
                    Icons.person,
                    color: Colors.black,
                  )),
              BottomNavigationBarItem(
                  label: "Setings",
                  icon: Icon(
                    Icons.settings,
                    color: Colors.black,
                  ))
            ],
            currentIndex: appState.selectedIndex,
            onTap: (index) {
              setState(() {
                if (index < 3) {
                  appState.selectedIndex = index;
                }
              });
            },
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

class TaskList extends StatefulWidget {
  final List<Task> list;
  const TaskList({
    super.key,
    required this.appState,
    required this.list,
  });

  final MyAppState appState;

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: ListView(
        children: [
          for (var index = 0; index < widget.list.length; index++)
            Padding(
              padding:
                  const EdgeInsets.only(top: 8, left: 20, right: 20, bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: widget.list[index].category == null
                              ? cardsColors[0][3]
                              : cardsColors[widget.appState
                                      .categories[widget.list[index].category!]
                                  [1]][3],
                          spreadRadius: -1,
                          offset: const Offset(2, 2))
                    ]),
                child: Card(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: widget.list[index].category == null
                              ? cardsColors[0][3]
                              : cardsColors[widget.appState
                                      .categories[widget.list[index].category!]
                                  [1]][3],
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
                              widget.list[index].category == null
                                  ? cardsColors[0][1]
                                  : cardsColors[widget.appState.categories[
                                      widget.list[index].category!][1]][1],
                              widget.list[index].category == null
                                  ? cardsColors[0][2]
                                  : cardsColors[widget.appState.categories[
                                      widget.list[index].category!][1]][2]
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
                                if (widget.appState.selectedIndex == 0) {
                                  widget.appState.taskDone(index);
                                } else {
                                  widget.appState.taskToDo(index);
                                }
                              },
                              iconSize: 32.0,
                              icon: widget.list[index].done
                                  ? const Icon(Icons.check_box,
                                      color: Colors.white)
                                  : const Icon(Icons.check_box_outline_blank,
                                      color: Colors.white),
                            ),
                            Expanded(
                              child: TextFormField(
                                key: Key(widget.list[index].name),
                                initialValue: widget.list[index].name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Inter",
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800),
                                decoration: const InputDecoration(
                                    border: InputBorder.none),
                                onChanged: (value) {
                                  setState(() {
                                    widget.list[index].name = value;
                                  });
                                },
                              ),
                            ),
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    widget.list[index].category = 1;
                                  });
                                },
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero),
                                child: Text(
                                    widget.list[index].category != null
                                        ? widget.list[index].date != null
                                            ? "${widget.appState.categories[widget.list[index].category!][0]}  •"
                                            : widget.appState.categories[widget
                                                .appState
                                                .toDoList[index]
                                                .category!][0]
                                        : "",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "Inter",
                                      fontSize: 16,
                                      fontWeight: widget.appState.sorting % 4 ==
                                                  1 ||
                                              widget.appState.sorting % 4 == 2
                                          ? FontWeight.w600
                                          : FontWeight.w300,
                                    ))),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  widget.list[index].date = DateTime.now();
                                });
                              },
                              child: Text(
                                  widget.list[index].date != null
                                      ? 'in ${widget.list[index].date!.difference(DateTime.now()).inDays + 1} days'
                                      : '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Inter",
                                    fontSize: 16,
                                    fontWeight:
                                        widget.appState.sorting % 4 == 3 ||
                                                widget.appState.sorting % 4 == 0
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
                            initialValue: widget.list[index].description != null
                                ? widget.list[index].description!
                                : "",
                            decoration:
                                const InputDecoration(border: InputBorder.none),
                            style: const TextStyle(
                                color: Colors.white,
                                fontFamily: "Inter",
                                fontSize: 14,
                                fontWeight: FontWeight.w200),
                            onChanged: (value) {
                              setState(() {
                                widget.list[index].description = value;
                              });
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
  int? selectedCategory;
  int selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
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
                      fillColor: Colors.orange,
                      labelText: "Task",
                      labelStyle: TextStyle(fontWeight: FontWeight.bold)),
                  onSubmitted: (String text) {
                    appState.newTask(
                      taskText,
                      taskDescription,
                      selectedCategory,
                      selectedDate,
                    );
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
                      fillColor: Colors.orange,
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
                    selectedCategory = await showMenu<
                        int>(context: context, position: position, items: [
                      for (var index = 0;
                          index < appState.categories.length;
                          index++)
                        PopupMenuItem(
                          value: index,
                          child: Text(appState.categories[index][0],
                              style: TextStyle(
                                  color:
                                      cardsColors[appState.categories[index][1]]
                                          [2],
                                  fontWeight: FontWeight.bold)),
                        ),
                      PopupMenuItem(
                        value: null,
                        child: const Row(
                          children: [
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
                                            color: cardsColors[selectedColor]
                                                [1]),
                                        child: IconButton(
                                            color: Colors.white,
                                            hoverColor: Colors.black,
                                            icon: const Icon(
                                                Icons.color_lens_rounded),
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return SimpleDialog(
                                                      title: const Text(
                                                          "Choose a color"),
                                                      children: [
                                                        SizedBox(
                                                          width: 200,
                                                          height: 300,
                                                          child: GridView.count(
                                                            crossAxisCount: 3,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(24),
                                                            mainAxisSpacing: 12,
                                                            crossAxisSpacing:
                                                                12,
                                                            children: [
                                                              for (var index =
                                                                      0;
                                                                  index <
                                                                      cardsColors
                                                                          .length;
                                                                  index++)
                                                                FilledButton(
                                                                  onPressed:
                                                                      () {
                                                                    selectedColor =
                                                                        index;
                                                                    Navigator.pop(
                                                                        context);
                                                                    setState(
                                                                        () {
                                                                      selectedColor =
                                                                          index;
                                                                    });
                                                                  },
                                                                  style: ButtonStyle(
                                                                      backgroundColor: MaterialStatePropertyAll<
                                                                          Color>(cardsColors[
                                                                              index]
                                                                          [1])),
                                                                  child:
                                                                      const SizedBox(),
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
                                            appState.categories
                                                .add([category, selectedColor]);
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop(
                                                appState.categories.length - 1);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              });
                        },
                      ),
                    ]);
                    setState(() {
                      selectedCategory = selectedCategory;
                    });
                  },
                  label: constraints.maxWidth >= 365
                      ? selectedCategory == null
                          ? const Text("Category")
                          : Text(
                              widget.appState.categories[selectedCategory!][0])
                      : Container(),
                  icon: const Icon(Icons.label),
                  style: ButtonStyle(
                      foregroundColor: MaterialStatePropertyAll<Color>(
                          selectedCategory == null
                              ? cardsColors[0][2]
                              : cardsColors[1 + selectedCategory!][2]))),
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
                        selectedCategory == null
                            ? cardsColors[0][2]
                            : cardsColors[1 + selectedCategory!][2])),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton.icon(
                  onPressed: () {
                    appState.newTask(taskText, taskDescription,
                        selectedCategory, selectedDate);
                    Navigator.pop(context);
                  },
                  label: constraints.maxWidth >= 365
                      ? const Text("Done")
                      : Container(),
                  icon: const Icon(Icons.check),
                  style: ButtonStyle(
                      foregroundColor: MaterialStatePropertyAll<Color>(
                          selectedCategory == null
                              ? cardsColors[0][2]
                              : cardsColors[1 + selectedCategory!][2]))),
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
