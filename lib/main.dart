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
  String text;
  DateTime? date;
  int? category;
  bool done;

  Task(this.text, {this.category, this.date, this.done = false});
}

class MyAppState extends ChangeNotifier {
  var toDoList = <Task>[];
  var doneList = <Task>[];
  var categories = <List>[
    ["Work", 1],
    ["School", 2],
    ["Social", 3]
  ];

  int sorting = 0;

  void newTask(String task, [int? category, DateTime? date]) {
    toDoList.add(Task(
      task,
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
    toDoList[index].done = !toDoList[index].done;
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

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 130,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.black,
        elevation: 14,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: RichText(
            text: const TextSpan(
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.w800),
                text: "Thrive."),
          ),
        ),
        actions: [
          const IconButton(onPressed: null, icon: Icon(Icons.search)),
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
              icon: const Icon(Icons.sort_by_alpha)),
          const SizedBox(
            width: 16,
          )
        ],
      ),
      body: ToDoList(appState: appState),
      bottomNavigationBar: Container(
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
                  label: "Test", icon: Icon(Icons.check_box_outline_blank)),
              BottomNavigationBarItem(
                  label: "Test", icon: Icon(Icons.check_box)),
              BottomNavigationBarItem(label: "Test", icon: Icon(Icons.add)),
              BottomNavigationBarItem(label: "Test", icon: Icon(Icons.person)),
              BottomNavigationBarItem(label: "Test", icon: Icon(Icons.settings))
            ]),
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
      builder: (BuildContext context) {
        return NewTaskFormContent(appState: appState);
      },
    );
  }
}

class ToDoList extends StatefulWidget {
  const ToDoList({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  State<ToDoList> createState() => _TaskListState();
}

class _TaskListState extends State<ToDoList> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: ListView(
        children: [
          for (var index = 0; index < widget.appState.toDoList.length; index++)
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 20, right: 20),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: widget.appState.toDoList[index].category ==
                                  null
                              ? cardsColors[0][3]
                              : cardsColors[widget.appState.categories[widget
                                  .appState.toDoList[index].category!][1]][3],
                          spreadRadius: -1,
                          offset: const Offset(2, 2))
                    ]),
                child: Card(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: widget.appState.toDoList[index].category ==
                                  null
                              ? cardsColors[0][3]
                              : cardsColors[widget.appState.categories[widget
                                  .appState.toDoList[index].category!][1]][3],
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
                              widget.appState.toDoList[index].category == null
                                  ? cardsColors[0][1]
                                  : cardsColors[widget.appState.categories[
                                      widget.appState.toDoList[index]
                                          .category!][1]][1],
                              widget.appState.toDoList[index].category == null
                                  ? cardsColors[0][2]
                                  : cardsColors[widget.appState.categories[
                                      widget.appState.toDoList[index]
                                          .category!][1]][2]
                            ])),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 38.0),
                      child: ListTile(
                        title: Transform.translate(
                          offset: const Offset(-12, 0),
                          child: Text(
                            widget.appState.toDoList[index].text,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                        trailing: RichText(
                          textAlign: TextAlign.end,
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: widget.appState.toDoList[index]
                                            .category !=
                                        null
                                    ? widget.appState.toDoList[index].date !=
                                            null
                                        ? "${widget.appState.categories[widget.appState.toDoList[index].category!][0]}  •  "
                                        : widget.appState.categories[widget
                                            .appState
                                            .toDoList[index]
                                            .category!][0]
                                    : "",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight:
                                      widget.appState.sorting % 4 == 1 ||
                                              widget.appState.sorting % 4 == 2
                                          ? FontWeight.w800
                                          : FontWeight.w300,
                                ),
                              ),
                              TextSpan(
                                  text: widget.appState.toDoList[index].date !=
                                          null
                                      ? 'in ${widget.appState.toDoList[index].date!.difference(DateTime.now()).inDays + 1} days'
                                      : '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                        widget.appState.sorting % 4 == 3 ||
                                                widget.appState.sorting % 4 == 0
                                            ? FontWeight.w800
                                            : FontWeight.w300,
                                  )),
                            ],
                          ),
                        ),
                        leading: IconButton(
                          onPressed: () {
                            widget.appState.taskDone(index);
                          },
                          iconSize: 28.0,
                          icon: widget.appState.toDoList[index].done
                              ? const Icon(Icons.check_box, color: Colors.white)
                              : const Icon(Icons.check_box_outline_blank,
                                  color: Colors.white),
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
                      labelText: "Enter your new task"),
                  onSubmitted: (String text) {
                    appState.newTask(
                      taskText,
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
                    selectedCategory = await showMenu<int>(
                        context: context,
                        position: position,
                        items: [
                          for (var index = 0;
                              index < appState.categories.length;
                              index++)
                            PopupMenuItem(
                              value: index,
                              child: Text(appState.categories[index][0],
                                  style: TextStyle(
                                      color: cardsColors[
                                          appState.categories[index][1]][2])),
                            ),
                          PopupMenuItem(
                              value: null,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                                "Create a new category"),
                                            content: Row(
                                              children: [
                                                Ink(
                                                  decoration: ShapeDecoration(
                                                      shape:
                                                          const CircleBorder(),
                                                      color: cardsColors[
                                                          selectedColor][1]),
                                                  child: IconButton(
                                                      color: Colors.white,
                                                      hoverColor: Colors.black,
                                                      icon: const Icon(Icons
                                                          .color_lens_rounded),
                                                      onPressed: () {
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return SimpleDialog(
                                                                title: const Text(
                                                                    "Choose a color"),
                                                                children: [
                                                                  SizedBox(
                                                                    width: 200,
                                                                    height: 300,
                                                                    child: GridView
                                                                        .count(
                                                                      crossAxisCount:
                                                                          3,
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          24),
                                                                      mainAxisSpacing:
                                                                          12,
                                                                      crossAxisSpacing:
                                                                          12,
                                                                      children: [
                                                                        for (var index =
                                                                                0;
                                                                            index <
                                                                                cardsColors.length;
                                                                            index++)
                                                                          FilledButton(
                                                                            onPressed:
                                                                                () {
                                                                              selectedColor = index;
                                                                              Navigator.pop(context);
                                                                              setState(() {
                                                                                selectedColor = index;
                                                                              });
                                                                            },
                                                                            style:
                                                                                ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(cardsColors[index][1])),
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
                                                    onFieldSubmitted:
                                                        (String category) {
                                                      appState.categories.add([
                                                        category,
                                                        selectedColor
                                                      ]);
                                                      Navigator.of(context)
                                                          .pop();
                                                      Navigator.of(context).pop(
                                                          appState.categories
                                                                  .length -
                                                              1);
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        });
                                  },
                                  label: const Text("New         "),
                                  icon: const Icon(Icons.add),
                                ),
                              )),
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
                    appState.newTask(taskText, selectedCategory, selectedDate);
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
