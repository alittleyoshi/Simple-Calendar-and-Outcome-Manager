import 'dart:developer' as developer;
import 'dart:math';
import 'package:database/database_bindings_generated.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:database/database.dart' as database;
import 'package:table_calendar/table_calendar.dart';

class Task {
  var listId = 0;
  var id = 0;
  var title = 'Task 1';
  var description = 'Task description.';
  var startTime = DateTime.now();
  var endTime = DateTime.now();
  var status = 0;

  Task(this.listId, this.id, this.title, this.description, this.startTime, this.endTime, this.status);
}

class TaskList {
  var id = 0;
  var title = 'Todo List';
  Map<int, Task> tasks = <int, Task>{};

  TaskList(this.id, this.title, this.tasks);
}

void main() {
  init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: "SCOM",
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

var initialized = false;
var taskList = <int, TaskList>{};

void init() {
  if (!initialized) {
    database.initDatabaseC();

    var listNum = database.preGetTaskListC();
    for (var i = 0; i < listNum; i++) {
      var listC = database.getTaskListC();
      var list = listCToList(listC);
      taskList[list.id] = list;
    }

    var taskNum = database.preGetTaskC();
    developer.log('taskNum: $taskNum', level: 800);
    for (var i = 0; i < taskNum; i++) {
      developer.log('Task $i', level: 800);
      var taskC = database.getTaskC();
      developer.log('TaskC ${taskC.startDate.toDartString()}, ${taskC.endDate.toDartString()}', level: 800);
      var task = taskCToTask(taskC);
      developer.log('Task ${task.startTime.toLocal()}, ${task.endTime.toLocal()}', level: 800);
      if (taskList[task.listId] == null) {
        developer.log('No List found for a task!', level: 1000, error: task.listId);
      } else {
        taskList[task.listId]!.tasks[task.id] = task;
      }
    }

    developer.log('init finished.', level: 800);
    initialized = true;
  } else {
    developer.log('Repeated init.', level: 900);
  }
}

void addList(TaskList list) {
  developer.log('addList', level: 800, error: list);
  list.id = database.addTaskListC(list.title.toNativeUtf8());
  taskList[list.id] = list;
}

void addTask(Task task) {
  developer.log('addTask', level: 800, error: task);
  task.id = database.addTaskC(task.listId, task.title.toNativeUtf8(), task.description.toNativeUtf8(), task.startTime.toString().toNativeUtf8(), task.endTime.toString().toNativeUtf8(), task.status);
  developer.log('Task ${task.startTime.toString()}, ${task.endTime.toString()}', level: 800);
  if (taskList[task.listId] == null) {
    developer.log('No list found for a task!', level: 1000, error: task.listId);
  } else {
    taskList[task.listId]!.tasks[task.id] = task;
  }
}

void deleteTask(int id, int listId) {
  database.deleteTaskC(id);
  if (taskList[listId] == null) {
    developer.log('No list found for a task!', level: 1000, error: listId);
  } else {
    taskList[listId]!.tasks.remove(id);
  }
}

void modifyTask(int id, int listId) {
  if (taskList[listId] == null) {
    developer.log('No list found for a task!', level: 1000, error: listId);
  } else {
    if (taskList[listId]!.tasks[id] == null) {
      developer.log('No task found!', level: 1000, error: id);
    }
    var task = taskList[listId]!.tasks[id];
    database.updateTaskC(listId, id, task!.title.toNativeUtf8(), task.description.toNativeUtf8(), task.startTime.toString().toNativeUtf8(), task.endTime.toString().toNativeUtf8(), task.status);
  }
}

void moveTask(int id, int listId, int newListId) {
  if (taskList[listId] == null || taskList[newListId] == null) {
    developer.log('No list found for a task!', level: 1000, error: listId);
  } else {
    if (taskList[listId]!.tasks[id] == null) {
      developer.log('No task found!', level: 1000, error: id);
    }
    var task = taskList[listId]!.tasks[id];
    database.updateTaskC(
      newListId,
      id,
      task!.title.toNativeUtf8(),
      task.description.toNativeUtf8(),
      task.startTime.toString().toNativeUtf8(),
      task.endTime.toString().toNativeUtf8(),
      task.status
    );
    taskList[listId]!.tasks.remove(id);
    task.listId = newListId;
    taskList[newListId]!.tasks[id] = task;
  }
}

void deleteList(int id) {
  database.deleteTaskListC(id);
  taskList.remove(id);
}

TaskList listCToList(Dart_TaskList list) {
  var dartList = TaskList(list.id, list.title.toDartString().toString(), {});
  return dartList;
}

Task taskCToTask(Dart_Task task) {
  var dartTask = Task(task.list_id, task.id, task.title.toDartString().toString(), task.description.toDartString().toString(), DateTime.parse(task.startDate.toDartString().toString()), DateTime.parse(task.endDate.toDartString().toString()), task.status);
  return dartTask;
}

class AppState extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;

    switch (selectedIndex) {
      case 0:
        page = TodoPage();
        break;
      case 1:
        page = CalendarPage();
        break;
      case 2:
        page = SettingPage();
        break;
      default :
        throw UnimplementedError('no widget for $selectedIndex');
    }

    IconData calendarIcon = Icons.calendar_month;

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row (
          children: [
            SafeArea(
              child:
                NavigationRail(
                  extended: constraints.maxWidth >= 800,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.checklist),
                      label: Text('SCOM'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(calendarIcon),
                      label: Text('Calendar'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value){
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child : page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class TodoPage extends StatefulWidget {
  @override
  State<TodoPage> createState() => _TodoPageState();
}

Task changeTaskCtoTask(Dart_Task task) {
  return Task(task.list_id, task.id, task.title.toDartString(), task.description.toDartString(), DateTime.parse(task.startDate.toDartString()), DateTime.parse(task.endDate.toDartString()), task.status);
}

class MyNavigationRail extends StatefulWidget {
  const MyNavigationRail({
    super.key,
    this.destinations = const [],
    required this.onDestinationSelected,
    required this.selectedIndex,
  });
  final List<(int, Widget)> destinations;
  final ValueChanged<(int, int)> onDestinationSelected;
  final int selectedIndex;

  @override
  State<MyNavigationRail> createState() => _MyNavigationRailState();
}

class MyDestination {
  MyDestination({
    required this.widget,
    required this.index,
    required this.id,
  });
  Widget widget;
  int index;
  int id;
}

class _MyNavigationRailState extends State<MyNavigationRail> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    selectedIndex = widget.selectedIndex;
    List<MyDestination> list = [];
    for (var i = 0; i < widget.destinations.length; i++) {
      list.add(MyDestination(widget: widget.destinations[i].$2, index: i, id: widget.destinations[i].$1));
    }
    var destinations = list.map((destination) {
      if (destination.index == selectedIndex) {
        return Container(
            margin: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: InkWell(
              onTap: (){
                setState(() {
                  selectedIndex = destination.index;
                  widget.onDestinationSelected((destination.index, destination.id));
                });
              },
              child: destination.widget,
            ),
        );
      }
      return Container(
        margin: EdgeInsets.all(10.0),
        child: InkWell(
          onTap: (){
            setState(() {
              selectedIndex = destination.index;
              widget.onDestinationSelected((destination.index, destination.id));
            });
          },
          child: destination.widget,
        ),
      );
    }).toList();
    return Container(
      color: Color.lerp(Colors.white, Theme.of(context).colorScheme.primaryContainer, 0.5),
      child: ListView(
        children: destinations,
      ),
    );
  }

  void changeSelectedIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
}

class AddTaskListPage<T> extends PopupRoute<T> {
  @override
  Color? get barrierColor => Colors.black.withAlpha(0x50);

  // This allows the popup to be dismissed by tapping the scrim or by pressing
  // the escape key on the keyboard.
  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Add Task List';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {

    var titleController = TextEditingController();
    var appState = context.watch<AppState>();

    return Center(
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!,
        child: Container(
          margin: EdgeInsets.all(40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            children: [
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Add Task List',
                      style: Theme.of(context).textTheme.headlineLarge),
                ],
              ),
              SizedBox(height: 10.0),
              Expanded(
                // padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    SizedBox(width: 10.0),
                    Expanded(
                      // padding: const EdgeInsets.all(8.0),
                      child: Scaffold(
                        body: Column(
                          children: [
                            TextField(
                              controller: titleController,
                              decoration: InputDecoration(
                                labelText: 'Title',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                            SizedBox(height: 10.0),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10.0),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(),
                  ),
                  ElevatedButton(
                    onPressed: (){
                      var list = TaskList(0, titleController.text, {});
                      addList(list);
                      appState.notify();
                      Navigator.of(context).pop();
                    },
                    child: Text("Add"),
                  ),
                  Expanded(
                    child: SizedBox(),
                  )
                ],
              ),
              SizedBox(height: 10.0,)
            ],
          ),
        ),
      ),
    );
  }
}

class _TodoPageState extends State<TodoPage> {
  var selectedIndex = -1;
  var selectedListId = 0;

  @override
  Widget build(BuildContext context) { // TODO deal with none todo list
    var appState = context.watch<AppState>();

    Widget page;

    var destination = taskList.values.map((list) => (list.id, Row(
      children: [
        Icon(Icons.star),
        SizedBox(width: 10.0),
        Text(list.title),
      ],
    ))).toList();

    destination.add((0, Row(
      children: [
        Icon(Icons.add_circle),
        SizedBox(width: 10.0),
        Text("Add List"),
      ],
    )));

    if ( taskList[selectedListId] == null) {
      setState(() {
        selectedIndex = -1;
      });
    }

    var myNavigationRail = MyNavigationRail(
      destinations: destination,
      onDestinationSelected: (value){
        setState(() {
          var index = value.$1, id = value.$2;
          if (index == taskList.length) {
            Navigator.of(context).push(AddTaskListPage());
            return;
          }
          selectedIndex = index;
          selectedListId = id;
        });
      },
      selectedIndex: selectedIndex,
    );

    if (destination.length == 1) {
      page = Scaffold();
    }

    page = GeneratorTodoPage(listIndex: selectedListId);

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: myNavigationRail,
          ),
          Expanded(
            flex: 4,
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child : page,
            ),
          ),
        ],
      ),
    );
  }
}

class GeneratorTodoPage extends StatefulWidget {
  GeneratorTodoPage({
    super.key,
    required this.listIndex,
    // required this.pop,
  });

  final int listIndex;
  // final bool pop;

  @override
  State<GeneratorTodoPage> createState() => _GeneratorTodoPageState();
}

class _GeneratorTodoPageState extends State<GeneratorTodoPage> {
  @override build(BuildContext context) {
    var appState = context.watch<AppState>();

    if (taskList[widget.listIndex] == null) {
      return Scaffold();
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          setState(() {
            Navigator.of(context).push(
              AddTaskPage<void>(listId: widget.listIndex)
            );
          });
        },
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 5),
            Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Row(
                children: [
                  SizedBox(width: 10),
                  Icon(Icons.star),
                  SizedBox(width: 10),
                  Text(taskList[widget.listIndex]!.title),
                  Expanded(child: SizedBox()),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        deleteList(widget.listIndex);
                        appState.notify();
                      });
                    },
                    label: Icon(Icons.delete),
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ),
            SizedBox(height: 5),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Row(
                  children: [
                    SizedBox(width: 15),
                    Expanded(
                      child: ListView(
                        children: taskList[widget.listIndex]!.tasks.values.map((task) => task.status != 4 ? Container(
                          // color: task.stat != 2 ? Theme.of(context).colorScheme.primaryContainer : Colors.deepOrange[300],
                          margin: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: task.status != 2 ? Theme.of(context).colorScheme.primaryContainer : Colors.deepOrange[300],
                            border: Border.all(
                              color: Colors.black,
                              width: 1.0,
                            ),
                          ),
                          child: InkWell(
                            onTap: (){
                              modifyTaskState.listIndex = widget.listIndex;
                              modifyTaskState.task = task;
                              // modifyTaskState.task.listId = widget.listIndex; what's?
                              Navigator.of(context).push(
                                modifyTaskPage<void>()
                              );
                            },
                            child: Row(
                              children: [
                                SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: (){
                                    setState((){
                                      task.status = task.status == 1 ? 0 : 1;
                                      // print('changed task${task.id}');
                                      modifyTask(task.id, widget.listIndex);
                                      // updateTaskStatus(widget.listIndex, task.id, task.status);
                                    });
                                  },
                                  label: Icon(task.status == 1 ? Icons.task_alt : Icons.circle),
                                ),
                                SizedBox(width: 10),
                                Text(task.title),
                                Expanded(child: SizedBox()),
                                ElevatedButton(
                                    onPressed: (){
                                      setState(() {
                                        Navigator.of(context).push(
                                          MoveTaskPage(task: task)
                                        );
                                      });
                                    },
                                    child: Text("Move"),
                                ),
                                SizedBox(width: 10.0),
                                ElevatedButton(
                                    onPressed: (){
                                      // task.stat = 4;
                                      // modifyTaskState.task = task;
                                      // appState.modifyTask(modifyTaskState.task.listId, modifyTaskState.task.id, modifyTaskState.task);
                                      deleteTask(task.id, widget.listIndex);
                                      appState.notify();
                                    },
                                    child: Text("Delete"),
                                ),
                                SizedBox(width: 10.0),
                              ],
                            ),
                          ),
                        ) : SizedBox()).toList(),
                      ),
                    ),
                    SizedBox(width: 15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddTaskState {
  var startTime = DateTime.now(), endTime = DateTime.now();
}

AddTaskState addTaskState = AddTaskState();

class AddTaskPage<T> extends PopupRoute<T> {
  final int listId;

  AddTaskPage({required this.listId});

  @override
  Color? get barrierColor => Colors.black.withAlpha(0x50);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Add Task';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  TimeOfDay selectedStartTime = TimeOfDay.now();
  TimeOfDay selectedEndTime = TimeOfDay.now();

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    var titleController = TextEditingController();
    var descriptionController = TextEditingController();
    var appState = context.watch<AppState>();

    return Center(
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!,
        child: Container(
          margin: EdgeInsets.all(40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: [
                  SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Add Task', style: Theme.of(context).textTheme.headlineLarge),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Expanded(
                    child: Row(
                      children: [
                        SizedBox(width: 10.0),
                        Expanded(
                          child: Scaffold(
                            body: Column(
                              children: [
                                TextField(
                                  controller: titleController,
                                  decoration: InputDecoration(
                                    labelText: 'Task Title',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                TextField(
                                  controller: descriptionController,
                                  minLines: 2,
                                  maxLines: 10,
                                  decoration: InputDecoration(
                                    labelText: 'Task Description',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                // 日期选择器
                                Row(
                                  children: [
                                    Text('Date: ${selectedStartDate.toLocal()}'),
                                    SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final DateTime? pickedDate = await showDatePicker(
                                          context: context,
                                          initialDate: selectedStartDate,
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2101),
                                        );
                                        if (pickedDate != null && pickedDate != selectedStartDate) {
                                          setState(() {
                                            selectedStartDate = pickedDate;
                                          });
                                        }
                                      },
                                      child: Text('Select Date'),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.0),
                                // 开始时间选择器
                                Row(
                                  children: [
                                    Text('Start Time: ${selectedStartTime.format(context)}'),
                                    SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final TimeOfDay? pickedTime = await showTimePicker(
                                          context: context,
                                          initialTime: selectedStartTime,
                                        );
                                        if (pickedTime != null && pickedTime != selectedStartTime) {
                                          setState(() {
                                            selectedStartTime = pickedTime;
                                          });
                                        }
                                      },
                                      child: Text('Select Start Time'),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.0),
                                Row(
                                  children: [
                                    Text('Date: ${selectedEndDate.toLocal()}'),
                                    SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final DateTime? pickedDate = await showDatePicker(
                                          context: context,
                                          initialDate: selectedEndDate,
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2101),
                                        );
                                        if (pickedDate != null && pickedDate != selectedEndDate) {
                                          setState(() {
                                            selectedEndDate = pickedDate;
                                          });
                                        }
                                      },
                                      child: Text('Select Date'),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.0),
                                // 结束时间选择器
                                Row(
                                  children: [
                                    Text('End Time: ${selectedEndTime.format(context)}'),
                                    SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final TimeOfDay? pickedTime = await showTimePicker(
                                          context: context,
                                          initialTime: selectedEndTime,
                                        );
                                        if (pickedTime != null && pickedTime != selectedEndTime) {
                                          setState(() {
                                            selectedEndTime = pickedTime;
                                          });
                                        }
                                      },
                                      child: Text('Select End Time'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(child: SizedBox()),
                      ElevatedButton(
                        onPressed: () {
                          // 将时间选择器的值转换为DateTime
                          final startTime = DateTime(
                            selectedStartDate.year,
                            selectedStartDate.month,
                            selectedStartDate.day,
                            selectedStartTime.hour,
                            selectedStartTime.minute,
                          );
                          final endTime = DateTime(
                            selectedEndDate.year,
                            selectedEndDate.month,
                            selectedEndDate.day,
                            selectedEndTime.hour,
                            selectedEndTime.minute,
                          );

                          // 创建任务
                          var task = Task(
                            listId,
                            0,
                            titleController.text,
                            descriptionController.text,
                            startTime,
                            endTime,
                            1,
                          );
                          addTask(task);
                          appState.notify();
                          Navigator.of(context).pop();
                        },
                        child: Text("Add"),
                      ),
                      SizedBox(width: 20.0),
                    ],
                  ),
                  SizedBox(height: 10.0),
                ],
              );
            }
          ),
        ),
      ),
    );
  }
}

class MoveTaskPage<T> extends PopupRoute<T> {
  MoveTaskPage({
    required this.task,
  });

  @override
  Color? get barrierColor => Colors.black.withAlpha(0x50);

  // This allows the popup to be dismissed by tapping the scrim or by pressing
  // the escape key on the keyboard.
  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Move Task';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  final Task task;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    var appState = context.watch<AppState>();

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          var height = (constraints.maxHeight - 100.0) / 2;
          var width = (constraints.maxWidth - 500.0) / 2;

          var listController = TextEditingController();
          var selectedList;

          return Container(
            margin: EdgeInsets.fromLTRB(width, height, width, height),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Scaffold(
              body: Center(
                child: Row(children: [
                  Expanded(child: SizedBox()),
                  DropdownMenu<int>(
                    label: const Text('Move'),
                    dropdownMenuEntries: taskList.values.map((list) =>
                        DropdownMenuEntry<int>(
                          value: list.id,
                          label: list.title,
                        )).toList(),
                    controller: listController,
                    onSelected: (int? listId){
                      selectedList = listId;
                    },
                  ),
                  SizedBox(width: 50.0),
                  ElevatedButton(onPressed: () {
                    moveTask(task.id, task.listId, selectedList);
                    appState.notify();
                    Navigator.pop(context);
                  }, child: Text("Move")),
                  Expanded(child: SizedBox()),
                ],
                ),
              ),
            ),
          );
        }
    );
  }
}


class AddTaskPageCalendar extends StatefulWidget {
  @override
  State<AddTaskPageCalendar> createState() => _AddTaskPageCalendarState();
}

class _AddTaskPageCalendarState extends State<AddTaskPageCalendar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("Start Time:"),
        SizedBox(width: 10.0),
        CustomPopup(
          showArrow: false,
          content: SizedBox(
            width: 300,
            child: CalendarDatePicker(
              initialDate: addTaskState.startTime,
              firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
              lastDate: DateTime.fromMicrosecondsSinceEpoch(10000000000000000),
              onDateChanged: (v) {
                setState(() {

                });
                addTaskState.startTime = v;
                print(v);
              },
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
            child: Icon(Icons.calendar_month),
          ),
        ),
        SizedBox(width: 10.0),
        Text("${addTaskState.startTime.year}-${addTaskState.startTime.month}-${addTaskState.startTime.day}"),
        SizedBox(width: 100.0),
        Text("End Time:"),
        SizedBox(width: 10.0),
        CustomPopup(
          showArrow: false,
          content: SizedBox(
            width: 300,
            child: CalendarDatePicker(
              initialDate: addTaskState.endTime,
              firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
              lastDate: DateTime.fromMicrosecondsSinceEpoch(10000000000000000),
              onDateChanged: (v) {
                setState(() {

                });
                addTaskState.endTime = v;
                print(v);
              },
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
            child: Icon(Icons.calendar_month),
          ),
        ),
        SizedBox(width: 10.0),
        Text("${addTaskState.endTime.year}-${addTaskState.endTime.month}-${addTaskState.endTime.day}"),
      ],
    );
  }
}

class ModifyTaskState {
  var listIndex;
  var task;
}

var modifyTaskState = ModifyTaskState();

class modifyTaskPage<T> extends PopupRoute<T> {
  @override
  Color? get barrierColor => Colors.black.withAlpha(0x50);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Modify Task';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  TimeOfDay selectedStartTime = TimeOfDay.now();
  TimeOfDay selectedEndTime = TimeOfDay.now();

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    var titleController = TextEditingController(text: modifyTaskState.task.title);
    var descriptionController = TextEditingController(text: modifyTaskState.task.description);
    var appState = context.watch<AppState>();

    selectedStartDate = modifyTaskState.task.startTime;
    selectedEndDate = modifyTaskState.task.endTime;
    selectedStartTime = TimeOfDay.fromDateTime(modifyTaskState.task.startTime);
    selectedEndTime = TimeOfDay.fromDateTime(modifyTaskState.task.endTime);

    return Center(
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!,
        child: Container(
          margin: EdgeInsets.all(40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: [
                  SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Modify Task', style: Theme.of(context).textTheme.headlineLarge),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Expanded(
                    child: Row(
                      children: [
                        SizedBox(width: 10.0),
                        Expanded(
                          child: Scaffold(
                            body: Column(
                              children: [
                                TextField(
                                  controller: titleController,
                                  decoration: InputDecoration(
                                    labelText: 'Task Title',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                TextField(
                                  controller: descriptionController,
                                  minLines: 2,
                                  maxLines: 10,
                                  decoration: InputDecoration(
                                    labelText: 'Task Description',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Row(
                                  children: [
                                    Text('Date: ${selectedStartDate.toLocal()}'),
                                    SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final DateTime? pickedDate = await showDatePicker(
                                          context: context,
                                          initialDate: selectedStartDate,
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2101),
                                        );
                                        if (pickedDate != null && pickedDate != selectedStartDate) {
                                          setState(() {
                                            selectedStartDate = pickedDate;
                                          });
                                        }
                                      },
                                      child: Text('Select Date'),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.0),
                                Row(
                                  children: [
                                    Text('Start Time: ${selectedStartTime.format(context)}'),
                                    SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final TimeOfDay? pickedTime = await showTimePicker(
                                          context: context,
                                          initialTime: selectedStartTime,
                                        );
                                        if (pickedTime != null && pickedTime != selectedStartTime) {
                                          setState(() {
                                            selectedStartTime = pickedTime;
                                          });
                                        }
                                      },
                                      child: Text('Select Start Time'),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.0),
                                Row(
                                  children: [
                                    Text('Date: ${selectedEndDate.toLocal()}'),
                                    SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final DateTime? pickedDate = await showDatePicker(
                                          context: context,
                                          initialDate: selectedEndDate,
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2101),
                                        );
                                        if (pickedDate != null && pickedDate != selectedEndDate) {
                                          setState(() {
                                            selectedEndDate = pickedDate;
                                          });
                                        }
                                      },
                                      child: Text('Select Date'),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.0),
                                Row(
                                  children: [
                                    Text('End Time: ${selectedEndTime.format(context)}'),
                                    SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final TimeOfDay? pickedTime = await showTimePicker(
                                          context: context,
                                          initialTime: selectedEndTime,
                                        );
                                        if (pickedTime != null && pickedTime != selectedEndTime) {
                                          setState(() {
                                            selectedEndTime = pickedTime;
                                          });
                                        }
                                      },
                                      child: Text('Select End Time'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(width: 20.0),
                      ElevatedButton(
                        onPressed: () {
                          deleteTask(modifyTaskState.task.id, modifyTaskState.listIndex);
                          appState.notify();
                          Navigator.of(context).pop();
                        },
                        child: Text("Delete"),
                      ),
                      Expanded(child: SizedBox()),
                      ElevatedButton(
                        onPressed: () {
                          final startTime = DateTime(
                            selectedStartDate.year,
                            selectedStartDate.month,
                            selectedStartDate.day,
                            selectedStartTime.hour,
                            selectedStartTime.minute,
                          );
                          final endTime = DateTime(
                            selectedEndDate.year,
                            selectedEndDate.month,
                            selectedEndDate.day,
                            selectedEndTime.hour,
                            selectedEndTime.minute,
                          );

                          modifyTaskState.task.title = titleController.text;
                          modifyTaskState.task.description = descriptionController.text;
                          modifyTaskState.task.startTime = startTime;
                          modifyTaskState.task.endTime = endTime;

                          taskList[modifyTaskState.listIndex]!.tasks[modifyTaskState.task.id] = modifyTaskState.task;
                          modifyTask(modifyTaskState.task.id, modifyTaskState.listIndex);
                          appState.notify();
                          Navigator.of(context).pop();
                        },
                        child: Text("Save"),
                      ),
                      SizedBox(width: 20.0),
                    ],
                  ),
                  SizedBox(height: 10.0),
                ],
              );
            }
          ),
        ),
      ),
    );
  }
}

class CalendarPage extends StatefulWidget {
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    // appState.init();

    // var calendarState = context.watch<CalendarState>();

    Widget page;

    switch (selectedIndex) {
      case 0:
        page = HourlyView(
          // selectedDay: DateTime.now(),
          tasks: taskList.values.expand((list) => list.tasks.values).toList(),
        );
        break;
      case 1:
        page = GeneratorWeekPage();
        break;
      case 2:
        page = GeneratorMonthPage();
        break;
      default:
        throw UnimplementedError("No implemented for ${selectedIndex}");
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                backgroundColor: Color.lerp(Colors.white, Theme.of(context).colorScheme.primaryContainer, 0.5),
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.calendar_view_day),
                    label: Text('Hours'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.calendar_view_week),
                    label: Text('Week'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.calendar_view_month),
                    label: Text('Month'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value){
                  setState((){
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: page,
              ),
            ),
          ],
        ),
      );
    });

  }
}

class GeneratorHourPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var begin_time = DateTime.now().add(Duration(hours: -1));
    var end_time = begin_time.add(Duration(hours: 12));



    return Row(
      children: [
        SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Text(begin_time.toString()),
              ),
              Container(
                alignment: Alignment.center,
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Text(begin_time.add(Duration(hours: 1)).toString()),
              ),
              Container(
                alignment: Alignment.center,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Text(begin_time.add(Duration(hours: 2)).toString()),
              ),
              Container(
                alignment: Alignment.center,
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Text(begin_time.add(Duration(hours: 3)).toString()),
              ),
              Container(
                alignment: Alignment.center,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Text(begin_time.add(Duration(hours: 4)).toString()),
              ),
              Container(
                alignment: Alignment.center,
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Text(begin_time.add(Duration(hours: 5)).toString()),
              ),
              Container(
                alignment: Alignment.center,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Text(begin_time.add(Duration(hours: 6)).toString()),
              ),
              Container(
                alignment: Alignment.center,
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Text(begin_time.add(Duration(hours: 7)).toString()),
              ),
              Container(
                alignment: Alignment.center,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Text(begin_time.add(Duration(hours: 8)).toString()),
              ),
              Container(
                alignment: Alignment.center,
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Text(begin_time.add(Duration(hours: 9)).toString()),
              ),
              Container(
                alignment: Alignment.center,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Text(begin_time.add(Duration(hours: 10)).toString()),
              ),
              Container(
                alignment: Alignment.center,
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Text(begin_time.add(Duration(hours: 11)).toString()),
              ),
            ],
          ),
        ),
        SizedBox(width: 20),
      ],
    );
  }
}

class CalendarHourPageContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: SizedBox(height: 30, width: 100),
          ),
          Container(
            alignment: Alignment.center,
            color: Theme.of(context).colorScheme.tertiaryContainer,
            child: Text(""),
          ),
        ],
      ),
    );
  }
}

// Failed assertion: line 115 pos 16: 'destinations.length >= 2': is not true.
// must have at least 2 destinations

class HourlyView extends StatefulWidget {
  final List<Task> tasks;

  const HourlyView({Key? key, required this.tasks}) : super(key: key);

  @override
  _HourlyViewState createState() => _HourlyViewState();
}

class _HourlyViewState extends State<HourlyView> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = widget.tasks.where((task) =>
      task.startTime.year == _selectedDate.year &&
      task.startTime.month == _selectedDate.month &&
      task.startTime.day == _selectedDate.day
    ).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 日期选择器
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('yyyy-MM-dd').format(_selectedDate),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.calendar_today, size: 20),
                onPressed: () => _selectDate(context),
              ),
            ],
          ),
        ),
        // 小时视图内容
        Expanded(
          child: _buildHourlyView(filteredTasks),
        ),
      ],
    );
  }

  Widget _buildHourlyView(List<Task> tasks) {
    // 按开始时间排序任务
    tasks.sort((a, b) => a.startTime.compareTo(b.startTime));

    // 计算任务列
    final taskColumns = _calculateTaskColumns(tasks);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical, // 垂直滚动
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // 横向滚动
        child: Container(
          width: _calculateTotalWidth(taskColumns), // 动态计算总宽度
          child: Stack(
            children: [
              // 背景：每小时一行
              Column(
                children: List.generate(24, (hour) {
                  return Container(
                    height: 60, // 每小时60像素
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '${hour.toString().padLeft(2, '0')}:00',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  );
                }),
              ),
              // 任务块
              ..._buildTaskBlocks(taskColumns),
            ],
          ),
        ),
      ),
    );
  }

  // 计算任务列
  Map<Task, int> _calculateTaskColumns(List<Task> tasks) {
    final taskColumns = <Task, int>{};
    final columnEndTimes = <int, DateTime>{};

    for (final task in tasks) {
      var column = 0;
      while (columnEndTimes.containsKey(column) &&
          columnEndTimes[column]!.isAfter(task.startTime)) {
        column++;
      }
      taskColumns[task] = column;
      columnEndTimes[column] = task.endTime;
    }

    return taskColumns;
  }

  // 计算总宽度
  double _calculateTotalWidth(Map<Task, int> taskColumns) {
    final maxColumn = taskColumns.values.isEmpty ? 0 : taskColumns.values.reduce((a, b) => a > b ? a : b);
    final contentWidth = 80 + (maxColumn + 1) * 120;
    final screenWidth = MediaQuery.of(context).size.width;
    return max(contentWidth.toDouble(), screenWidth); // 关键改动：取最大值
    // return 80 + (maxColumn + 1) * 120; // 左侧时间标签宽度 + 列数 * 列宽
  }

  // 构建任务块
  List<Widget> _buildTaskBlocks(Map<Task, int> taskColumns) {
    return taskColumns.entries.map((entry) {
      final task = entry.key;
      final column = entry.value;

      final startHour = task.startTime.hour;
      final startMinute = task.startTime.minute;
      final endHour = task.endTime.hour;
      final endMinute = task.endTime.minute;

      // 计算任务块的起始位置和高度
      final top = startHour * 60 + startMinute; // 每分钟1像素
      final height = (endHour - startHour) * 60 + (endMinute - startMinute);

      // 计算任务块的左侧偏移量
      final left = 80 + column * 120; // 每列宽度为120像素

      return Positioned(
        top: top.toDouble(),
        left: left.toDouble(),
        width: 100, // 任务块宽度
        height: height.toDouble(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.5), // 任务块颜色
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              task.title,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      );
    }).toList();
  }
}

class GeneratorMonthPage extends StatefulWidget {
  @override
  _GeneratorMonthPageState createState() => _GeneratorMonthPageState();
}

class _GeneratorMonthPageState extends State<GeneratorMonthPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Task>> _tasksByDay = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Populate _tasksByDay from your taskList data
    _loadTasksForMonth();
  }

  void _loadTasksForMonth() {
    // Logic to filter tasks from 'taskList' for the currently focused month
    // and group them by day.
    // Example:
    _tasksByDay.clear();
    taskList.values.forEach((list) {
      list.tasks.values.forEach((task) {
        // Normalize task.startTime to midnight for day-based grouping
        DateTime taskDay = DateTime(task.startTime.year, task.startTime.month, task.startTime.day);
        if (_tasksByDay[taskDay] == null) {
          _tasksByDay[taskDay] = [];
        }
        _tasksByDay[taskDay]!.add(task);
      });
    });
    setState(() {});
  }

  List<Task> _getEventsForDay(DateTime day) {
    // Normalize day to midnight for lookup
    DateTime normalizedDay = DateTime(day.year, day.month, day.day);
    return _tasksByDay[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>(); // If needed for updates

    return Scaffold(
      appBar: AppBar(
        title: Text('Month View'),
      ),
      body: Column(
        children: [
          TableCalendar<Task>(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              _loadTasksForMonth(); // Reload tasks for the new month
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _selectedDay != null
                ? ListView(
                    children: _getEventsForDay(_selectedDay!)
                        .map((task) => ListTile(
                              title: Text(task.title),
                              subtitle: Text(task.description),
                              onTap: (){
                                Navigator.of(context).push(
                                    modifyTaskPage<void>()
                                );},
                              // Add onTap to view/edit task
                            ))
                        .toList(),
                  )
                : Container(),
          ),
        ],
      ),
    );
  }
}

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _darkModeEnabled = false; // Example setting

  @override
  Widget build(BuildContext context) {
    // var appState = context.watch<AppState>(); // To modify global app settings

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            title: Text('Dark Mode (Not Impl)'),
            value: _darkModeEnabled,
            onChanged: (bool value) {
              setState(() {
                _darkModeEnabled = value;
                // Here you would typically call a method in your AppState or
                // a theme provider to change the theme of the app.
                // For example: Provider.of<ThemeProvider>(context, listen: false).setTheme(value);
              });
            },
          ),
          ListTile(
            title: Text('Notification Settings (Example)'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to a detailed notification settings page
            },
          ),
          ListTile(
            title: Text('About SCOM'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'SCOM',
                applicationVersion: '0.0.1', // Get from package_info_plus if you want
                applicationLegalese: '©2025 OIer/HSAS',
              );
            },
          ),
        ],
      ),
    );
  }
}

class GeneratorWeekPage extends StatefulWidget {
  @override
  _GeneratorWeekPageState createState() => _GeneratorWeekPageState();
}

class _GeneratorWeekPageState extends State<GeneratorWeekPage> {
  late DateTime _currentDate; // Any date within the current week
  late DateTime _startOfWeek;
  late DateTime _endOfWeek;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _calculateWeekRange(_currentDate);
  }

  void _calculateWeekRange(DateTime date) {
    // Assuming Monday is the start of the week
    _startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    _endOfWeek = _startOfWeek.add(Duration(days: 6));
    // To ensure time components are zeroed out for accurate date comparison
    _startOfWeek = DateTime(_startOfWeek.year, _startOfWeek.month, _startOfWeek.day);
    _endOfWeek = DateTime(_endOfWeek.year, _endOfWeek.month, _endOfWeek.day, 23, 59, 59); // End of the last day
  }

  void _previousWeek() {
    setState(() {
      _currentDate = _currentDate.subtract(Duration(days: 7));
      _calculateWeekRange(_currentDate);
    });
  }

  void _nextWeek() {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: 7));
      _calculateWeekRange(_currentDate);
    });
  }

  List<Task> _getTasksForDay(DateTime day) {
    List<Task> dayTasks = [];
    DateTime dayStart = DateTime(day.year, day.month, day.day);
    DateTime dayEnd = DateTime(day.year, day.month, day.day, 23, 59, 59, 999);

    taskList.values.forEach((list) {
      list.tasks.values.forEach((task) {
        // Check if the task's startTime or endTime falls within the day
        // This is a simple check, you might want more complex logic for multi-day tasks
        if ((task.startTime.isAfter(dayStart) && task.startTime.isBefore(dayEnd)) ||
            (task.endTime.isAfter(dayStart) && task.endTime.isBefore(dayEnd)) ||
            (task.startTime.isBefore(dayStart) && task.endTime.isAfter(dayEnd))) {
          dayTasks.add(task);
        }
      });
    });
    dayTasks.sort((a, b) => a.startTime.compareTo(b.startTime)); // Sort tasks by start time
    return dayTasks;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>(); // Watch for changes if tasks can be updated elsewhere

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back button if it's part of a sub-navigation
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: _previousWeek,
            ),
            Text(
              "${DateFormat('MMM d').format(_startOfWeek)} - ${DateFormat('MMM d, yyyy').format(_endOfWeek)}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right),
              onPressed: _nextWeek,
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine if the layout should be more compact (e.g. for smaller screens)
          // For simplicity, this example uses a fixed number of columns for days
          // For a responsive design, you might use GridView or change layout based on constraints.
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(7, (index) { // 7 days in a week
              final day = _startOfWeek.add(Duration(days: index));
              final tasksForDay = _getTasksForDay(day);

              return Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: index < 6 ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Day Header
                      Container(
                        padding: EdgeInsets.all(8.0),
                        width: double.infinity,
                        color: DateTime.now().day == day.day && DateTime.now().month == day.month && DateTime.now().year == day.year
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                            : Colors.grey.shade200,
                        child: Column(
                          children: [
                            Text(
                              DateFormat('EEE').format(day), // e.g., Mon
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              DateFormat('d').format(day), // e.g., 12
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      // Tasks List for the day
                      Expanded(
                        child: tasksForDay.isEmpty
                            ? Center(child: Text('-', style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                                itemCount: tasksForDay.length,
                                itemBuilder: (context, taskIndex) {
                                  final task = tasksForDay[taskIndex];
                                  return InkWell(
                                    onTap: () {
                                       // Navigate to task details or modify task
                                       // Similar to your TodoPage's task onTap
                                      modifyTaskState.listIndex = task.listId;
                                      modifyTaskState.task = task;
                                      Navigator.of(context).push(
                                        modifyTaskPage<void>()
                                      ).then((_) => setState((){})); // Refresh UI after modification
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                                      padding: EdgeInsets.all(6.0),
                                      decoration: BoxDecoration(
                                        color: task.status == 2 // Example: Highlight completed tasks
                                            ? Colors.deepOrange[200]
                                            : Theme.of(context).colorScheme.secondaryContainer,
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task.title,
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            "${DateFormat.jm().format(task.startTime)} - ${DateFormat.jm().format(task.endTime)}",
                                            style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}