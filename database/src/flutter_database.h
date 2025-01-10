#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

#ifndef FLUTTER_DATABASE_H
#define FLUTTER_DATABASE_H

FFI_PLUGIN_EXPORT struct Dart_Task {
    int list_id;
    int id;
    char* title;
    char* description;
    char* startDate;
    char* endDate;
    int status;
};

// Dart API functions
FFI_PLUGIN_EXPORT int Dart_init();
FFI_PLUGIN_EXPORT int Dart_query_tasklist_num();
FFI_PLUGIN_EXPORT int Dart_query_tasklist_id(int num);
FFI_PLUGIN_EXPORT char* Dart_query_tasklist_name(int id);
FFI_PLUGIN_EXPORT int Dart_query_task_num(int task_num);
FFI_PLUGIN_EXPORT struct Dart_Task Dart_get_task(int list_num, int task_num);
FFI_PLUGIN_EXPORT int Dart_create_tasklist(const char* list_name);
FFI_PLUGIN_EXPORT int Dart_create_task(int list_num, const char* title, const char* description,
                    const char* startDate, const char* endDate, int status);
FFI_PLUGIN_EXPORT int Dart_update_task(int list_id, int task_id, const char* title,
                    const char* description, const char* startDate,
                    const char* endDate, int status);
FFI_PLUGIN_EXPORT int Dart_update_task_stat(int list_id, int task_id, int stat);
FFI_PLUGIN_EXPORT int Dart_delete_task(int list_id, int task_id);
FFI_PLUGIN_EXPORT int Dart_delete_tasklist(int list_id);


#endif