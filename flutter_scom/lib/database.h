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

    int createTable();
    bool insertTask(int cur_tasklist, int task_id, const std::string& title,
                   const std::string& description, long long startTime,
                   long long endTime, int stat);
    bool _queryTasks(int cur_tasklist);
    int queryTasksNum(int cur_tasklist);
    bool deleteTaskById(int cur_tasklist, int id);
    bool updateTask(int cur_tasklist, int id, const std::string& title,
                   const std::string& description, long long startTime,
                   long long endTime, int stat);
    bool updateTaskTitle(int cur_tasklist, int id, const std::string& title);
    bool updateTaskStatus(int cur_tasklist, int id, int stat);
    bool queryTaskById(int list_id, int task_id);
    bool initTaskListTable();
    bool queryTaskLists();
    int queryTaskListsNum();
    int queryTaskIdFromList(int list_id);

private:
    sqlite3* db;
};

// Utility functions
std::string timestampToString(time_t timestamp);
time_t string_to_timestamp(std::string timestamp);
void output(Task result);
Dart_Task covert_task_dart_task(Task task);

// Dart API functions
extern "C" {
    int Dart_init();
    int Dart_query_tasklist_num();
    int Dart_query_task_num(int task_num);
    Dart_Task Dart_get_task(int list_num, int task_id);
    int Dart_create_task(int list_num, const char* title, const char* description,
                        const char* startDate, const char* endDate, int status);
    int Dart_update_task(int list_id, int task_id, const char* title,
                        const char* description, const char* startDate,
                        const char* endDate, int status);
    int Dart_update_task_stat(int list_id, int task_id, int stat);
    int Dart_test();
    int Dart_test_f1();
    void Dart_test_f2();
    int Dart_test_f3(int val);
}

#endif //DATABASE_H
