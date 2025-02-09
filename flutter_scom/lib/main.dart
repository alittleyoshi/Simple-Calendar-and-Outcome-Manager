import 'dart:developer' as developer;
import 'package:database/database_bindings_generated.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:database/database.dart' as database;

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
  var selectedIndex = 0;
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

    // TODO
    // if (appState.afterDelete) {
    //   setState(() {
    //     appState.afterDelete = false;
    //     appState.listIndex = 0;
    //     selectedIndex = 0;
    //   });
    // }

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

    // if(selectedIndex == appState.tasklist.length) {
    //   Navigator.of(context).push(AddTaskListPage());
    //   return build(context);
    // }

    if (destination.length == 1) {
      page = Scaffold();
    }

    page = GeneratorTodoPage(listIndex: selectedListId);

    // print("${appState.tasklist.length}");

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
    // widget.list.taskList.add(Task(1, 'eltiT', 'Todo2', DateTime.now(), DateTime.now(), 1));
    var appState = context.watch<AppState>();

    // var addTaskPage = GeneratorAddTaskPage(child: Text('???'));

    // if (widget.pop) {
    //   return addTaskPage;
    // }

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

  // This allows the popup to be dismissed by tapping the scrim or by pressing
  // the escape key on the keyboard.
  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Add Todo Task';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {

    var titleController = TextEditingController();
    var descriptionController = TextEditingController();
    var appState = context.watch<AppState>();

    titleController.text = modifyTaskState.task.title;
    descriptionController.text = modifyTaskState.task.description;
    addTaskState.startTime = modifyTaskState.task.startTime;
    addTaskState.endTime = modifyTaskState.task.endTime;

    print("Changed");
    print(addTaskState.startTime.toString());

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
                  Text('Modify Todo Task',
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
                            AddTaskPageCalendar(),
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
                      onPressed: (){
                        // modifyTaskState.task.stat = 4;
                        // appState.modifyTask(modifyTaskState.task.listId, modifyTaskState.task.id, modifyTaskState.task);
                        deleteTask(modifyTaskState.task.id, modifyTaskState.listIndex);
                        appState.notify();
                        Navigator.of(context).pop();
                      },
                      child: Text("Delete"),
                  ),
                  Expanded(
                    child: SizedBox(),
                  ),
                  ElevatedButton(
                      onPressed: (){
                        Task temp = modifyTaskState.task;
                        modifyTaskState.task.title = titleController.text;
                        modifyTaskState.task.description = descriptionController.text;
                        modifyTaskState.task.startTime = addTaskState.startTime;
                        modifyTaskState.task.endTime = addTaskState.endTime;
                        taskList[modifyTaskState.listIndex]!.tasks[temp.id] = temp;
                        modifyTask(modifyTaskState.task.id, modifyTaskState.listIndex);
                        // modifyTask(modifyTaskState.listIndex, modifyTaskState.task.id);
                      },
                      child: Text("Save"),
                  ),
                  SizedBox(width: 20.0),
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
          selectedDay: DateTime.now(),
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

class GeneratorWeekPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

class GeneratorMonthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

// Failed assertion: line 115 pos 16: 'destinations.length >= 2': is not true.
// must have at least 2 destinations

class HourlyView extends StatelessWidget {
  final DateTime selectedDay;
  final List<Task> tasks;

  HourlyView({required this.selectedDay, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
          ..._buildTaskBlocks(),
        ],
      ),
    );
  }

  // 构建任务块
  List<Widget> _buildTaskBlocks() {
    return tasks.map((task) {
      final startHour = task.startTime.hour;
      final startMinute = task.startTime.minute;
      final endHour = task.endTime.hour;
      final endMinute = task.endTime.minute;

      // 计算任务块的起始位置和高度
      final top = startHour * 60 + startMinute; // 每分钟1像素
      final height = (endHour - startHour) * 60 + (endMinute - startMinute);

      return Positioned(
        top: top.toDouble(),
        left: 80, // 左侧留出时间标签的空间
        right: 0,
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