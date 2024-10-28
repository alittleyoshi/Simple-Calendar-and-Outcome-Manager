import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                  extended: constraints.maxWidth >= 600,
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
                // Expanded(child: Text('')),
                // NavigationRail(
                //   extended: constraints.maxWidth >= 600,
                //   destinations: [
                //     NavigationRailDestination(
                //       icon: Icon(Icons.settings),
                //       label: Text('Setting'),
                //       // padding: EdgeInsets.only(top: constraints.maxHeight),
                //     ),
                //   ],
                //   selectedIndex: selectedIndex,
                //   onDestinationSelected: (value){
                //     setState(() {
                //       selectedIndex = value + 2;
                //     });
                //   },
                // ),
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

class Task {
  var id = 0;
  var title = 'Task 1';
  var description = 'Task description.';
  var startTime = DateTime.now();
  var endTime = DateTime.now();
  var stat = 0;
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
    
    var destination = todoList.map((list) => NavigationRailDestination(
        icon: Icon(Icons.star),
        label: Text("Todo List ${selectedIndex + 1}"),
    )).toList();

    page =

    // var destination = todoList[selectedIndex].taskList.map((task) => )

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child:
            NavigationRail(
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
    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Row(
            children: [
              Icon(Icons.star),
              SizedBox(width: 10),
              Text("Todo List ${list.id + 1}"),
            ],
          ),
        ),

      ],
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