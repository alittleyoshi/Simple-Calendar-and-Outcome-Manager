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
    DatabaseManager(const std::string& dbName);
    ~DatabaseManager();

    int add_tasklist(const std::string& list_name, int list_id) const;
    int get_tasklist_cur_id() const;
    int insertTask(int cur_tasklist, int task_id, const std::string& title, const std::string& description,
                   long long startTime, long long endTime, int stat) const;
    int queryTasklistIdByNum(int list_num) const;
    int queryTasksNum(int cur_tasklist) const;
    int deleteTaskById(int cur_tasklist, int id) const;
    int queryTaskByNum(int cur_tasklist, int task_num, Task* task) const;
    int updateTask(int cur_tasklist, int id, const std::string& title, const std::string& description,
                   long long startTime, long long endTime, int stat) const;
    bool updateTaskTitle(int cur_tasklist, int id, const std::string& title) const;
    bool updateTaskStatus(int cur_tasklist, int id, int stat) const;
    int queryTaskById(int list_id, int task_id, Task* task) const;
    int initTaskListTable() const;
    bool queryTaskLists() const;
    int queryTaskListsNum() const;
    int queryTaskIdFromList(int list_id) const;

private:
    sqlite3* db;
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
}

#endif //DATABASE_H
