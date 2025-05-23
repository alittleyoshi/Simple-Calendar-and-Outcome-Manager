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

// ========================== Models ==========================

class Task {
  int listId;
  int id;
  String title;
  String description;
  DateTime startTime;
  DateTime endTime;
  int status;

  Task({
    required this.listId,
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.status = 0,
  });

  factory Task.fromDartTask(Dart_Task task) {
    return Task(
      listId: task.list_id,
      id: task.id,
      title: task.title.toDartString(),
      description: task.description.toDartString(),
      startTime: DateTime.parse(task.startDate.toDartString()),
      endTime: DateTime.parse(task.endDate.toDartString()),
      status: task.status,
    );
  }

  bool get isCompleted => status == 1;
  bool get isOverdue => status == 2;
  bool get isDeleted => status == 4;
}

class TaskList {
  int id;
  String title;
  Map<int, Task> tasks;

  TaskList({
    required this.id,
    required this.title,
    Map<int, Task>? tasks,
  }) : tasks = tasks ?? {};

  factory TaskList.fromDartTaskList(Dart_TaskList list) {
    return TaskList(
      id: list.id,
      title: list.title.toDartString(),
    );
  }

  List<Task> get activeTasks =>
      tasks.values.where((task) => !task.isDeleted).toList();
}

// ========================== Services ==========================

class DatabaseService {
  static bool _initialized = false;
  static final Map<int, TaskList> _taskLists = {};

  static Map<int, TaskList> get taskLists => _taskLists;

  static void initialize() {
    if (_initialized) {
      developer.log('Database already initialized', level: 900);
      return;
    }

    database.initDatabaseC();
    _loadTaskLists();
    _loadTasks();
    _initialized = true;
    developer.log('Database initialized successfully', level: 800);
  }

  static void _loadTaskLists() {
    final listNum = database.preGetTaskListC();
    for (int i = 0; i < listNum; i++) {
      final listC = database.getTaskListC();
      final taskList = TaskList.fromDartTaskList(listC);
      _taskLists[taskList.id] = taskList;
    }
  }

  static void _loadTasks() {
    final taskNum = database.preGetTaskC();
    for (int i = 0; i < taskNum; i++) {
      final taskC = database.getTaskC();
      final task = Task.fromDartTask(taskC);

      if (_taskLists[task.listId] != null) {
        _taskLists[task.listId]!.tasks[task.id] = task;
      } else {
        developer.log('No list found for task ${task.id}', level: 1000);
      }
    }
  }

  static int addTaskList(String title) {
    final id = database.addTaskListC(title.toNativeUtf8());
    _taskLists[id] = TaskList(id: id, title: title);
    return id;
  }

  static int addTask(Task task) {
    final id = database.addTaskC(
      task.listId,
      task.title.toNativeUtf8(),
      task.description.toNativeUtf8(),
      task.startTime.toString().toNativeUtf8(),
      task.endTime.toString().toNativeUtf8(),
      task.status,
    );

    task.id = id;
    _taskLists[task.listId]?.tasks[id] = task;
    return id;
  }

  static void updateTask(Task task) {
    database.updateTaskC(
      task.listId,
      task.id,
      task.title.toNativeUtf8(),
      task.description.toNativeUtf8(),
      task.startTime.toString().toNativeUtf8(),
      task.endTime.toString().toNativeUtf8(),
      task.status,
    );
    _taskLists[task.listId]?.tasks[task.id] = task;
  }

  static void deleteTask(int taskId, int listId) {
    database.deleteTaskC(taskId);
    _taskLists[listId]?.tasks.remove(taskId);
  }

  static void deleteTaskList(int listId) {
    database.deleteTaskListC(listId);
    _taskLists.remove(listId);
  }

  static void moveTask(int taskId, int fromListId, int toListId) {
    final task = _taskLists[fromListId]?.tasks[taskId];
    if (task != null && _taskLists[toListId] != null) {
      task.listId = toListId;
      updateTask(task);
      _taskLists[fromListId]?.tasks.remove(taskId);
      _taskLists[toListId]?.tasks[taskId] = task;
    }
  }
}

// ========================== State Management ==========================

class AppState extends ChangeNotifier {
  void refresh() => notifyListeners();
}

// ========================== Main App ==========================

void main() {
  DatabaseService.initialize();
  runApp(const MyApp());
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
        home: const MyHomePage(),
      ),
    );
  }
}

// ========================== Home Page ==========================

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static const List<({IconData icon, String label})> _destinations = [
    (icon: Icons.checklist, label: 'SCOM'),
    (icon: Icons.calendar_month, label: 'Calendar'),
    (icon: Icons.settings, label: 'Settings'),
  ];

  Widget _getPage(int index) {
    switch (index) {
      case 0: return const TodoPage();
      case 1: return const CalendarPage();
      case 2: return const SettingsPage();
      default: throw UnimplementedError('No widget for $_selectedIndex');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 800;
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          return Scaffold(
            body: _getPage(_selectedIndex),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              items: _destinations.map((dest) =>
                BottomNavigationBarItem(
                  icon: Icon(dest.icon),
                  label: dest.label,
                )
              ).toList(),
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: isWideScreen,
                  destinations: _destinations.map((dest) =>
                    NavigationRailDestination(
                      icon: Icon(dest.icon),
                      label: Text(dest.label),
                    )
                  ).toList(),
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) =>
                      setState(() => _selectedIndex = index),
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: _getPage(_selectedIndex),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ========================== Todo Page ==========================

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  int? _selectedListId;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final taskLists = DatabaseService.taskLists;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;

            if (isMobile) {
              return _buildMobileLayout(taskLists);
            }
            return _buildDesktopLayout(taskLists);
          },
        );
      },
    );
  }

  Widget _buildMobileLayout(Map<int, TaskList> taskLists) {
    if (_selectedListId == null || !taskLists.containsKey(_selectedListId)) {
      return _buildTaskListSelector(taskLists, true);
    }

    return _buildTaskListView(_selectedListId!, true);
  }

  Widget _buildDesktopLayout(Map<int, TaskList> taskLists) {
    return Row(
      children: [
        SizedBox(
          width: 250,
          child: _buildTaskListSelector(taskLists, false),
        ),
        Expanded(
          child: _selectedListId != null && taskLists.containsKey(_selectedListId)
              ? _buildTaskListView(_selectedListId!, false)
              : const Center(child: Text('Select a task list')),
        ),
      ],
    );
  }

  Widget _buildTaskListSelector(Map<int, TaskList> taskLists, bool isMobile) {
    return Scaffold(
      appBar: isMobile ? AppBar(
        title: const Text('Task Lists'),
        leading: _selectedListId != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedListId = null),
              )
            : null,
      ) : null,
      floatingActionButton: FloatingActionButton(
        mini: !isMobile,
        onPressed: _showAddTaskListDialog,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: taskLists.length,
        itemBuilder: (context, index) {
          final taskList = taskLists.values.elementAt(index);
          return _buildTaskListTile(taskList, isMobile);
        },
      ),
    );
  }

  Widget _buildTaskListTile(TaskList taskList, bool isMobile) {
    final taskCount = taskList.activeTasks.length;

    return ListTile(
      leading: const Icon(Icons.list),
      title: Text(taskList.title),
      subtitle: Text('$taskCount tasks'),
      trailing: PopupMenuButton<String>(
        onSelected: (String value) {
          if (value == 'delete') {
            _deleteTaskList(taskList.id);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem<String>(
            value: 'delete',
            child: const Row(
              children: [Icon(Icons.delete), SizedBox(width: 8), Text('Delete')],
            ),
          ),
        ],
      ),
      onTap: () => setState(() => _selectedListId = taskList.id),
      selected: _selectedListId == taskList.id,
    );
  }

  Widget _buildTaskListView(int listId, bool isMobile) {
    final taskList = DatabaseService.taskLists[listId]!;
    final tasks = taskList.activeTasks;

    return Scaffold(
      appBar: isMobile ? AppBar(
        title: Text(taskList.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _selectedListId = null),
        ),
      ) : AppBar(
        title: Text(taskList.title),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(listId),
        child: const Icon(Icons.add),
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('No tasks yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) => _buildTaskTile(tasks[index]),
            ),
    );
  }

  Widget _buildTaskTile(Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: task.isOverdue ? Colors.deepOrange[300] : null,
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) => _toggleTaskStatus(task),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: task.description.isNotEmpty ? Text(task.description) : null,
        trailing: PopupMenuButton<String>(
          onSelected: (String value) {
            switch (value) {
              case 'edit':
                _showEditTaskDialog(task);
                break;
              case 'move':
                _showMoveTaskDialog(task);
                break;
              case 'delete':
                _deleteTask(task);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'move',
              child: Row(
                children: [Icon(Icons.move_to_inbox), SizedBox(width: 8), Text('Move')],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [Icon(Icons.delete), SizedBox(width: 8), Text('Delete')],
              ),
            ),
          ],
        ),
        onTap: () => _showEditTaskDialog(task),
      ),
    );
  }

  void _toggleTaskStatus(Task task) {
    task.status = task.isCompleted ? 0 : 1;
    DatabaseService.updateTask(task);
    context.read<AppState>().refresh();
  }

  void _deleteTask(Task task) {
    DatabaseService.deleteTask(task.id, task.listId);
    context.read<AppState>().refresh();
  }

  void _deleteTaskList(int listId) {
    DatabaseService.deleteTaskList(listId);
    if (_selectedListId == listId) {
      _selectedListId = null;
    }
    context.read<AppState>().refresh();
  }

  void _showAddTaskListDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTaskListDialog(
        onAdd: (title) {
          DatabaseService.addTaskList(title);
          context.read<AppState>().refresh();
        },
      ),
    );
  }

  void _showAddTaskDialog(int listId) {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        listId: listId,
        onAdd: (task) {
          DatabaseService.addTask(task);
          context.read<AppState>().refresh();
        },
      ),
    );
  }

  void _showEditTaskDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) => EditTaskDialog(
        task: task,
        onSave: (updatedTask) {
          DatabaseService.updateTask(updatedTask);
          context.read<AppState>().refresh();
        },
        onDelete: () {
          DatabaseService.deleteTask(task.id, task.listId);
          context.read<AppState>().refresh();
        },
      ),
    );
  }

  void _showMoveTaskDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) => MoveTaskDialog(
        task: task,
        availableLists: DatabaseService.taskLists.values
            .where((list) => list.id != task.listId)
            .toList(),
        onMove: (targetListId) {
          DatabaseService.moveTask(task.id, task.listId, targetListId);
          context.read<AppState>().refresh();
        },
      ),
    );
  }
}

// ========================== Dialogs ==========================

class AddTaskListDialog extends StatefulWidget {
  final Function(String) onAdd;

  const AddTaskListDialog({super.key, required this.onAdd});

  @override
  State<AddTaskListDialog> createState() => _AddTaskListDialogState();
}

class _AddTaskListDialogState extends State<AddTaskListDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task List'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'List Title',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              widget.onAdd(_controller.text.trim());
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class AddTaskDialog extends StatefulWidget {
  final int listId;
  final Function(Task) onAdd;

  const AddTaskDialog({super.key, required this.listId, required this.onAdd});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  DateTime _endDate = DateTime.now();
  TimeOfDay _endTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildDateTimeSelector(
              'Start',
              _startDate,
              _startTime,
              (date) => setState(() => _startDate = date),
              (time) => setState(() => _startTime = time),
            ),
            const SizedBox(height: 16),
            _buildDateTimeSelector(
              'End',
              _endDate,
              _endTime,
              (date) => setState(() => _endDate = date),
              (time) => setState(() => _endTime = time),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addTask,
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelector(
    String label,
    DateTime date,
    TimeOfDay time,
    Function(DateTime) onDateChanged,
    Function(TimeOfDay) onTimeChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label Time', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) onDateChanged(picked);
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(DateFormat('MMM d, yyyy').format(date)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: time,
                  );
                  if (picked != null) onTimeChanged(picked);
                },
                icon: const Icon(Icons.access_time),
                label: Text(time.format(context)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _addTask() {
    if (_titleController.text.trim().isEmpty) return;

    final startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    final task = Task(
      listId: widget.listId,
      id: 0,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      startTime: startDateTime,
      endTime: endDateTime,
    );

    widget.onAdd(task);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class EditTaskDialog extends StatefulWidget {
  final Task task;
  final Function(Task) onSave;
  final VoidCallback onDelete;

  const EditTaskDialog({
    super.key,
    required this.task,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _startDate = widget.task.startTime;
    _startTime = TimeOfDay.fromDateTime(widget.task.startTime);
    _endDate = widget.task.endTime;
    _endTime = TimeOfDay.fromDateTime(widget.task.endTime);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildDateTimeSelector(
              'Start',
              _startDate,
              _startTime,
              (date) => setState(() => _startDate = date),
              (time) => setState(() => _startTime = time),
            ),
            const SizedBox(height: 16),
            _buildDateTimeSelector(
              'End',
              _endDate,
              _endTime,
              (date) => setState(() => _endDate = date),
              (time) => setState(() => _endTime = time),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onDelete();
            Navigator.pop(context);
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveTask,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelector(
    String label,
    DateTime date,
    TimeOfDay time,
    Function(DateTime) onDateChanged,
    Function(TimeOfDay) onTimeChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label Time', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) onDateChanged(picked);
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(DateFormat('MMM d, yyyy').format(date)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: time,
                  );
                  if (picked != null) onTimeChanged(picked);
                },
                icon: const Icon(Icons.access_time),
                label: Text(time.format(context)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) return;

    final startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    final updatedTask = Task(
      listId: widget.task.listId,
      id: widget.task.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      startTime: startDateTime,
      endTime: endDateTime,
      status: widget.task.status,
    );

    widget.onSave(updatedTask);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class MoveTaskDialog extends StatelessWidget {
  final Task task;
  final List<TaskList> availableLists;
  final Function(int) onMove;

  const MoveTaskDialog({
    super.key,
    required this.task,
    required this.availableLists,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Move "${task.title}"'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: availableLists.map((list) =>
          ListTile(
            title: Text(list.title),
            onTap: () {
              onMove(list.id);
              Navigator.pop(context);
            },
          ),
        ).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

// ========================== Calendar Page ==========================

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        Widget page;
        switch (_selectedIndex) {
          case 0:
            page = HourlyView(tasks: _getAllTasks());
            break;
          case 1:
            page = WeeklyView(tasks: _getAllTasks());
            break;
          case 2:
            page = MonthlyView(tasks: _getAllTasks());
            break;
          default:
            throw UnimplementedError('No page for $_selectedIndex');
        }

        if (isMobile) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Calendar'),
              bottom: TabBar(
                controller: TabController(
                  length: 3,
                  vsync: Scaffold.of(context),
                  initialIndex: _selectedIndex,
                ),
                onTap: (index) => setState(() => _selectedIndex = index),
                tabs: const [
                  Tab(text: 'Day', icon: Icon(Icons.calendar_view_day)),
                  Tab(text: 'Week', icon: Icon(Icons.calendar_view_week)),
                  Tab(text: 'Month', icon: Icon(Icons.calendar_view_month)),
                ],
              ),
            ),
            body: page,
          );
        }

        return Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) =>
                  setState(() => _selectedIndex = index),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_view_day),
                  label: Text('Day'),
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
            ),
            Expanded(child: page),
          ],
        );
      },
    );
  }

  List<Task> _getAllTasks() {
    return DatabaseService.taskLists.values
        .expand((list) => list.activeTasks)
        .toList();
  }
}

// ========================== Calendar Views ==========================

class HourlyView extends StatefulWidget {
  final List<Task> tasks;

  const HourlyView({super.key, required this.tasks});

  @override
  State<HourlyView> createState() => _HourlyViewState();
}

class _HourlyViewState extends State<HourlyView> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final dayTasks = widget.tasks.where((task) {
      final taskDate = task.startTime;
      return taskDate.year == _selectedDate.year &&
             taskDate.month == _selectedDate.month &&
             taskDate.day == _selectedDate.day;
    }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(() =>
                  _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
            ),
            GestureDetector(
              onTap: _selectDate,
              child: Text(
                DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(() =>
                  _selectedDate = _selectedDate.add(const Duration(days: 1))),
            ),
          ],
        ),
      ),
      body: dayTasks.isEmpty
          ? const Center(child: Text('No tasks for this day'))
          : ListView.builder(
              itemCount: dayTasks.length,
              itemBuilder: (context, index) {
                final task = dayTasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    title: Text(task.title),
                    subtitle: Text(
                      '${DateFormat.jm().format(task.startTime)} - ${DateFormat.jm().format(task.endTime)}',
                    ),
                    trailing: task.isCompleted
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                  ),
                );
              },
            ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }
}

class WeeklyView extends StatefulWidget {
  final List<Task> tasks;

  const WeeklyView({super.key, required this.tasks});

  @override
  State<WeeklyView> createState() => _WeeklyViewState();
}

class _WeeklyViewState extends State<WeeklyView> {
  DateTime _currentWeek = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final startOfWeek = _currentWeek.subtract(Duration(days: _currentWeek.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(() =>
                  _currentWeek = _currentWeek.subtract(const Duration(days: 7))),
            ),
            Text(
              '${DateFormat('MMM d').format(startOfWeek)} - ${DateFormat('MMM d, yyyy').format(endOfWeek)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(() =>
                  _currentWeek = _currentWeek.add(const Duration(days: 7))),
            ),
          ],
        ),
      ),
      body: Row(
        children: List.generate(7, (index) {
          final day = startOfWeek.add(Duration(days: index));
          final dayTasks = widget.tasks.where((task) {
            final taskDate = task.startTime;
            return taskDate.year == day.year &&
                   taskDate.month == day.month &&
                   taskDate.day == day.day;
          }).toList();

          return Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DateTime.now().day == day.day &&
                           DateTime.now().month == day.month &&
                           DateTime.now().year == day.year
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                        : null,
                    border: Border(
                      right: index < 6
                          ? BorderSide(color: Colors.grey.shade300)
                          : BorderSide.none,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('EEE').format(day),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(DateFormat('d').format(day)),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: index < 6
                            ? BorderSide(color: Colors.grey.shade300)
                            : BorderSide.none,
                      ),
                    ),
                    child: ListView.builder(
                      itemCount: dayTasks.length,
                      itemBuilder: (context, taskIndex) {
                        final task = dayTasks[taskIndex];
                        return Container(
                          margin: const EdgeInsets.all(2),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            task.title,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class MonthlyView extends StatefulWidget {
  final List<Task> tasks;

  const MonthlyView({super.key, required this.tasks});

  @override
  State<MonthlyView> createState() => _MonthlyViewState();
}

class _MonthlyViewState extends State<MonthlyView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Task> _getTasksForDay(DateTime day) {
    return widget.tasks.where((task) {
      final taskDate = task.startTime;
      return taskDate.year == day.year &&
             taskDate.month == day.month &&
             taskDate.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TableCalendar<Task>(
            firstDay: DateTime.utc(2010, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getTasksForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() => _focusedDay = focusedDay);
            },
          ),
          if (_selectedDay != null) ...[
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _getTasksForDay(_selectedDay!).length,
                itemBuilder: (context, index) {
                  final task = _getTasksForDay(_selectedDay!)[index];
                  return ListTile(
                    title: Text(task.title),
                    subtitle: Text(
                      '${DateFormat.jm().format(task.startTime)} - ${DateFormat.jm().format(task.endTime)}',
                    ),
                    trailing: task.isCompleted
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ========================== Settings Page ==========================

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Coming soon'),
            value: _darkModeEnabled,
            onChanged: null, // Disabled for now
          ),
          ListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Configure notification settings'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Implement notification settings
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('About SCOM'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'SCOM',
                applicationVersion: '1.0.0',
                applicationLegalese: '©2025 SCOM Team',
                children: const [
                  Text('A simple and efficient task management application.'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}