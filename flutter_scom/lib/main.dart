import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
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

class MyAppState extends ChangeNotifier {

}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  var calendarIconIndex = 0;

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

    IconData calendarIcon;
    switch (calendarIconIndex) {
      case 0:
        calendarIcon = Icons.calendar_view_day;
        break;
      case 1:
        calendarIcon = Icons.calendar_view_week;
        break;
      case 2:
        calendarIcon = Icons.calendar_view_month;
        break;
      default:
        throw UnimplementedError('no icon for $calendarIconIndex');
    }

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

final class TaskC extends Struct {
  external Pointer<Utf8> title, description, startTime, endTime;

  @Int32()
  external int status;
}

class Task {
  var id = 0;
  var title = 'Task 1';
  var description = 'Task description.';
  var startTime = DateTime.now();
  var endTime = DateTime.now();
  var stat = 0;

  Task(this.id, this.title, this.description, this.startTime, this.endTime, this.stat);
}

Task changeTaskCtoTask(TaskC task) {
  return Task(0, task.title.toDartString(), task.description.toDartString(), DateTime.parse(task.startTime.toDartString()), DateTime.parse(task.endTime.toDartString()), task.status);
}

int getTodoListNum() {
  return 0;
}

int getTask(int listId) {
  return 0;
}

class TodoList {
  var id = 0;
  var taskList = <Task>[];
}

class _TodoPageState extends State<TodoPage> {
  var selectedIndex = 0;

  var todoList = <TodoList>[];

  @override
  Widget build(BuildContext context) {
    Widget page;

    todoList.add(TodoList());
    todoList.add(TodoList());
    todoList[0].taskList.add(Task(0, 'Title', 'Todo1', DateTime.now(), DateTime.now(), 0));
    todoList[0].taskList.add(Task(1, 'eltiT', 'Todo2', DateTime.now(), DateTime.now(), 1));

    var destination = todoList.map((list) => NavigationRailDestination(
        icon: Icon(Icons.star),
        label: Text("Todo List ${list.id + 1}"),
    )).toList();

    page = GeneratorTodoPage(list: todoList[selectedIndex]);

    // var destination = todoList[selectedIndex].taskList.map((task) => )

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child:
            NavigationRail(
              backgroundColor: Color.lerp(Colors.white, Theme.of(context).colorScheme.primaryContainer, 0.5),
              extended: true,
              destinations: destination,
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
  }
}

class GeneratorTodoPage extends StatelessWidget {
  const GeneratorTodoPage({
    super.key,
    required this.list,
  });

  final TodoList list;

  @override build(BuildContext context) {
    return Center(
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
                Text("Todo List ${list.id + 1}"),
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
                  ListView(
                    children: list.taskList.map((task) => Container(
                      color: task.stat != 2 ? Theme.of(context).colorScheme.primaryContainer : Colors.deepOrange[300],
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: (){
                              task.stat = task.stat == 1 ? 0 : 1;
                            },
                            icon: Icon(task.stat == 1 ? Icons.task_alt : Icons.circle),
                            label: SizedBox(),
                          ),
                          SizedBox(width: 10),
                          Text('Task ${task.title}'),
                        ],
                      ),
                    )).toList(),
                  ),
                  SizedBox(width: 15),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CalendarPage extends StatelessWidget {
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