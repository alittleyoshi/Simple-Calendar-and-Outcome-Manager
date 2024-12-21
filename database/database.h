#ifndef DATABASE_H
#define DATABASE_H

#include <string>
#include "sqlite3.h"

struct Task {
    int list_id;
    int id;
    std::string title;
    std::string description;
    std::string startDate;
    std::string endDate;
    int status;

    void output() const;
};

struct Dart_Task {
    int list_id;
    int id;
    char* title;
    char* description;
    char* startDate;
    char* endDate;
    int status;
};

class DatabaseManager {
public:
    explicit DatabaseManager(const std::string& dbName);
    ~DatabaseManager();

    int add_tasklist(const std::string& list_name);
    int get_tasklist_cur_id() const;
    int insert_task(int cur_tasklist, const std::string& title, const std::string& description, long long startTime,
                    long long endTime, int stat) const;
    int query_tasklist_id_by_num(int list_num) const;
    int query_tasks_num(int cur_tasklist) const;
    int delete_task_by_id(int cur_tasklist, int id) const;
    int delete_tasklist_by_id(int tasklist_id);
    int query_task_by_num(int cur_tasklist, int task_num, Task* task) const;
    int update_task(int cur_tasklist, int id, const std::string& title, const std::string& description,
                   long long startTime, long long endTime, int stat) const;
    [[deprecated]] bool updateTaskTitle(int cur_tasklist, int id, const std::string& title) const;
    [[deprecated]] bool updateTaskStatus(int cur_tasklist, int id, int stat) const;
    int query_task_by_id(int list_id, int task_id, Task* task) const;
    std::string query_tasklist_name_by_id(int id) const;
    int init_task_list_table() const;
    int after_init() ;
    [[deprecated]] bool queryTaskLists() const;
    int query_task_lists_num() const;
    int query_task_id_from_list(int list_id) const;

private:
    sqlite3* db;

    int tasklist_num;
    int tasklist_id;
};

// Utility functions
std::string timestampToString(time_t timestamp);
time_t string_to_timestamp(const std::string& timestamp);
Dart_Task covert_task_dart_task(const Task& task);

// Dart API functions
extern "C" {
    int Dart_init();
    int Dart_query_tasklist_num();
    int Dart_query_tasklist_id(int num);
    char* Dart_query_tasklist_name(int id);
    int Dart_query_task_num(int task_num);
    Dart_Task Dart_get_task(int list_num, int task_num);
    int Dart_create_tasklist(const char* list_name);
    int Dart_create_task(int list_num, const char* title, const char* description,
                        const char* startDate, const char* endDate, int status);
    int Dart_update_task(int list_id, int task_id, const char* title,
                        const char* description, const char* startDate,
                        const char* endDate, int status);
    int Dart_update_task_stat(int list_id, int task_id, int stat);
    int Dart_delete_task(int list_id, int task_id);
    int Dart_delete_tasklist(int list_id);
}

#endif //DATABASE_H
