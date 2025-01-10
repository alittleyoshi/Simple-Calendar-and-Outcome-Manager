//
// Created by kibi on 25-1-10.
//

#ifndef DATABASE_H
#define DATABASE_H

#include <string>
#include "sqlite3.h"
extern "C" {
#include "flutter_database.h"
}

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
    int move_task_by_id(int cur_tasklist, int to_tasklist, int task_id) const;

private:
    sqlite3* db;

    int tasklist_num;
    int tasklist_id;
};

// Utility functions
std::string timestampToString(time_t timestamp);
time_t string_to_timestamp(const std::string& timestamp);
Dart_Task covert_task_dart_task(const Task& task);

#endif //DATABASE_H
