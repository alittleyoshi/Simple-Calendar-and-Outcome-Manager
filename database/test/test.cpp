//
// Created by kibi on 24-12-7.
//

#include <cassert>
#include <iostream>
#include "database.h"

int test_Dart();

int test_manager();

int main() {
    test_manager();
    test_Dart();
    return 0;
}

DatabaseManager *db;

// TODO test

/*
int test_add_tasklist() ;
int test_insertTask() ;
bool test__queryTasks() ;
int test_queryTasksNum() ;
int test_deleteTaskById() ;
int test_updateTask() ;
bool test_updateTaskTitle() ;
bool test_updateTaskStatus() ;
int test_queryTaskById() ;
int test_initTaskListTable() ;
bool test_queryTaskLists() ;
int test_queryTaskListsNum() ;
int test_queryTaskIdFromList() ;
*/

int test_manager() {
    remove("test.db");
    db = new DatabaseManager("test.db");

    db->init_task_list_table();
    db->add_tasklist("Todo List", 1);
    db->add_tasklist("Todo List", 2);

    int res;

    res = db->query_tasks_num(1);
    assert(res == 0);

    db->insert_task(2, 1, "test", "test", 1, 2, 0);
    res = db->query_tasks_num(2);
    assert(res == 1);

    db->insert_task(2, 2, "test", "test", 1, 2, 0);
    res = db->query_tasks_num(2);
    assert(res == 2);

    db->delete_task_by_id(2, 1);
    res = db->query_tasks_num(2);
    assert(res == 1);

    res = db->query_task_lists_num();
    assert(res == 2);

    db->insert_task(2, 3, "test", "test", 1, 2, 0);
    auto task = new Task;
    db->query_task_by_num(2, 1, task);
    assert(task->id == 3);

    db->delete_tasklist_by_id(1);
    res = db->query_task_lists_num();
    assert(res == 1);

    // auto exist_db = new DatabaseManager("tasks.db");
    // exist_db->init_task_list_table();

    return 0;
}

int test_Dart() {
    return 0;
}