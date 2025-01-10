
import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'database_bindings_generated.dart';

/// A very short-lived native function.
///
/// For very short-lived functions, it is fine to call them on the main isolate.
/// They will block the Dart execution while running the native function, so
/// only do this for native functions which are guaranteed to be short-lived.
// int sum(int a, int b) => _bindings.sum(a, b);

final _bindings = DatabaseBindings(Platform.isLinux ?
    DynamicLibrary.open('libdatabase.so') : Platform.isMacOS ?
    DynamicLibrary.open('libdatabase.dylib') :
    DynamicLibrary.open('libdatabase.dll'));

final initDatabaseC = _bindings.Dart_init;

final queryTaskListId = _bindings.Dart_query_tasklist_id;

final queryTaskListNum =  _bindings.Dart_query_tasklist_num;

final queryTaskListName =  _bindings.Dart_query_tasklist_name;

final queryTaskNum =  _bindings.Dart_query_task_num;

final getTaskC =  _bindings.Dart_get_task;

final addTaskList =  _bindings.Dart_create_tasklist;

final addTaskC =  _bindings.Dart_create_task;

final updateStatTaskC =  _bindings.Dart_update_task_stat;

final updateTaskC =  _bindings.Dart_update_task;

final deleteTaskC =  _bindings.Dart_delete_task;

final deleteTaskListC =  _bindings.Dart_delete_tasklist;