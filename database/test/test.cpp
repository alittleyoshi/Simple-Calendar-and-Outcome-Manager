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
    db = new DatabaseManager("test.db");

    db->initTaskListTable();
    db->add_tasklist("Todo List", 1);
    db->add_tasklist("Todo List", 2);

    int res;

    res = db->queryTasksNum(1);
    assert(res == 0);

    db->insertTask(2, 1, "test", "test", 1, 2, 0);
    res = db->queryTasksNum(2);
    assert(res == 1);

    db->insertTask(2, 2, "test", "test", 1, 2, 0);
    res = db->queryTasksNum(2);
    assert(res == 2);

    db->deleteTaskById(2, 1);
    res = db->queryTasksNum(2);
    assert(res == 1);

    res = db->queryTaskListsNum();
    assert(res == 2);

    return 0;
}

int test_Dart() {
    return 0;
}