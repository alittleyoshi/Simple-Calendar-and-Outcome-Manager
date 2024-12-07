#include "database.h"
#include <chrono>
#include <cstring>
#include <iomanip>
#include <iostream>
#include <string>
#include "sqlite3.h"

#define DART_API extern "C" __attribute__((visibility("default"))) __attribute__((used))

// TODO move these into Manager
int tasklist_num;
int tasklist_id;
int cut_tasklist_id;

std::string timestampToString(const time_t timestamp) {
    const std::tm* tm = std::localtime(&timestamp);
    std::stringstream ss;
    ss << std::put_time(tm, "%Y-%m-%d %H:%M:%S");
    return ss.str();
}

time_t string_to_timestamp(const std::string& timestamp) {
    std::tm tm = {};
    std::istringstream ss(timestamp);
    std::cerr << timestamp << std::endl;
    ss >> std::get_time(&tm, "%Y-%m-%dT%H:%M:%S");
    return mktime(&tm);
}

void Task::output() const {
    std::cerr << list_id << ' ' << id << ' ' << title << ' ' << description << ' '
              << timestampToString(std::stoi(startDate)) << ' ' << timestampToString(std::stoi(endDate))
              << ' ' << status << std::endl;
}

Dart_Task covert_task_dart_task(const Task& task) {
    Dart_Task dart_task{};
    dart_task.list_id = task.list_id;
    dart_task.id = task.id;

    dart_task.title = new char[task.title.length() + 1];
    strcpy(dart_task.title, task.title.c_str());
    dart_task.description = new char[task.description.length() + 1];
    strcpy(dart_task.description, task.description.c_str());
    dart_task.startDate = new char[task.startDate.length() + 1];
    strcpy(dart_task.startDate, task.startDate.c_str());
    dart_task.endDate = new char[task.endDate.length() + 1];
    strcpy(dart_task.endDate, task.endDate.c_str());

    dart_task.status = task.status;
    return dart_task;
}

DatabaseManager::DatabaseManager(const std::string& dbName) {
    if (sqlite3_open(dbName.c_str(), &db)) {
        std::cerr << "Cannot open database: " << sqlite3_errmsg(db) << std::endl;
        return;
    }
    std::cerr << "Database opened successfully" << std::endl;
}

DatabaseManager::~DatabaseManager() { sqlite3_close(db); }

int DatabaseManager::get_tasklist_cur_id() const {
    std::string sql = "SELECT MAX(ID) FROM TASKLISTS";
    char* errMsg = nullptr;

    auto callback = [](void* data, int argc, char** argv, char** azColName) -> int {
        int* result = static_cast<int*>(data);
        if (argv[0] != nullptr) {
            *result = std::stoi(argv[0]);
        }
        return 0;
    };

    int res = 0;
    int rc = sqlite3_exec(db, sql.c_str(), callback, &res, &errMsg);

    if (rc != SQLITE_OK) {
        std::cerr << "In get_tasklist_cur_id, when get max id," << std::endl;
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
    }

    return res;
}

int DatabaseManager::add_tasklist(const std::string& list_name, const int list_id) const {

    // create a task table
    std::string pre = "CREATE TABLE IF NOT EXISTS TASKLIST" + std::to_string(list_id) +
        "("
        "ID INTEGER PRIMARY KEY, "
        "TITLE TEXT NOT NULL, "
        "DESCRIPTION TEXT, "
        "START_TIME INTEGER NOT NULL, "
        "END_TIME INTEGER NOT NULL, "
        "STAT INTEGER NOT NULL);";
    const char* sql = pre.c_str();

    char* errMsg = nullptr;
    int rc = sqlite3_exec(db, sql, nullptr, nullptr, &errMsg);

    if (rc != SQLITE_OK) {
        std::cerr << "In add_tasklist, when create task table," << std::endl;
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return -1;
    }

    // Insert new tasklist record
    std::string insertList = "INSERT INTO TASKLISTS (TASK_ID, LIST_NAME, ID) VALUES (0, '" + list_name + "', " + std::to_string(list_id) + ");";

    rc = sqlite3_exec(db, insertList.c_str(), nullptr, nullptr, &errMsg);

    if (rc != SQLITE_OK) {
        std::cerr << "In add_tasklist, when insert tasklist" << std::endl;
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return -1;
    }

    std::cerr << "Add tasklist successfully" << std::endl;
    tasklist_num++;

    return tasklist_id;
}

int DatabaseManager::initTaskListTable() const {

    auto sql = "CREATE TABLE IF NOT EXISTS TASKLISTS ("
               "TASK_ID INTEGER NOT NULL, "
               "LIST_NAME TEXT NOT NULL, "
               "ID INTEGER PRIMARY KEY);";

    char* errMsg = nullptr;
    int rc = sqlite3_exec(db, sql, nullptr, nullptr, &errMsg);

    if (rc != SQLITE_OK) {
        std::cerr << "In initTaskListTable, when create task table" << std::endl;
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return -1;
    }

    sql = "PRAGMA TABLE_INFO(TASKLISTS);";

    auto flag = new bool{false};

    auto callback = [](void* data, int argc, char** argv, char** colName) {
        for (int i = 0; i < argc; i++) {
            if (std::string(argv[0]).find("LIST_ID")) {
                *static_cast<bool*>(data) = true;
            }
        }
        return 0;
    };

    rc = sqlite3_exec(db, sql, callback, flag, &errMsg);

    if (rc != SQLITE_OK) {
        std::cerr << "In initTaskListTable, when get table info" << std::endl;
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return -1;
    }

    if (*flag) {
        delete flag;
        return 0;
    }

    delete flag;

    // convert task_num to task_id
    sql = "ALTER TABLE TASKLISTS RENAME TO TASKLISTS_OLD;";
    rc = sqlite3_exec(db, sql, nullptr, nullptr, &errMsg);

    if (rc != SQLITE_OK) {
        std::cerr << "In initTaskListTable, when rename tasklists" << std::endl;
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return -1;
    }

    sql = "CREATE TABLE IF NOT EXISTS TASKLISTS ("
          "TASK_ID INTEGER NOT NULL, "
          "LIST_NAME TEXT NOT NULL, "
          "ID INTEGER PRIMARY KEY);";
    rc = sqlite3_exec(db, sql, nullptr, nullptr, &errMsg);

    if (rc != SQLITE_OK) {
        std::cerr << "In initTaskListTable, when create new tasklists" << std::endl;
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return -1;
    }

    sql = "INSERT INTO TASKLISTS (TASK_ID, LIST_NAME, ID) SELECT TASK_NUM, LIST_NAME, CAST(substr(LIST_NAME, 9) AS "
          "INTEGER) FROM TASKLISTS_OLD;";
    rc = sqlite3_exec(db, sql, nullptr, nullptr, &errMsg);

    if (rc != SQLITE_OK) {
        std::cerr << "In initTaskListTable, when insert tasklists" << std::endl;
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return -1;
    }

    sql = "DROP TABLE TASKLISTS_OLD;";
    rc = sqlite3_exec(db, sql, nullptr, nullptr, &errMsg);

    if (rc != SQLITE_OK) {
        std::cerr << "In initTaskListTable, when drop tasklists" << std::endl;
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return -1;
    }

    std::cerr << "Init tasklist table successfully" << std::endl;
    return 0;
}

int DatabaseManager::queryTasklistIdByNum(int list_num) const {
    auto sql = "SELECT ID FROM TASKLISTS LIMIT " + std::to_string(list_num) + ", 1;";
    int res = 0;
    char* errMsg = nullptr;

    auto callback = [](void* data, int argc, char** argv, char** colName) {
        *static_cast<int*>(data) = std::stoi(argv[0]);
        return 0;
    };

    int rc = sqlite3_exec(db, sql.c_str(), callback, &res, &errMsg);

    if (rc != SQLITE_OK) {
        std::cerr << "In queryTasklistIdByNum" << std::endl;
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return -1;
    }

    return res;
}

int DatabaseManager::insertTask(int cur_tasklist, // tasklist id
                                int task_id, const std::string& title, const std::string& description,
                                long long startTime, long long endTime, int stat) const {
    std::string sql = "INSERT INTO TASKLIST" + std::to_string(cur_tasklist) +
        "(ID, TITLE, DESCRIPTION, START_TIME, END_TIME, STAT) "
        "VALUES (" +
        std::to_string(task_id) + ", '" + title + "', '" + description + "', " + std::to_string(startTime) + ", " +
        std::to_string(endTime) + ", " + std::to_string(stat) + ");";

    char* errMsg = nullptr;
    int rc = sqlite3_exec(db, sql.c_str(), nullptr, nullptr, &errMsg);

    if (rc != SQLITE_OK) {
        std::cerr << "In insertTask, when insert task into tasklist" << std::endl;
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return -1;
    }

    // update task_num in tasklists
    sql = "UPDATE TASKLISTS SET TASK_ID = TASK_ID + 1 WHERE LIST_NAME = 'TASKLIST" +
        std::to_string(cur_tasklist) + "';";

    rc = sqlite3_exec(db, sql.c_str(), nullptr, nullptr, &errMsg);

    if (rc != SQLITE_OK) {
        std::cerr << "In insertTask, when modify tasklists" << std::endl;
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return -1;
    }

    std::cerr << "Task inserted into TASKLIST" << cur_tasklist << " successfully" << std::endl;
    return 0;
}

int DatabaseManager::queryTasksNum(int cur_tasklist) const {
    static int res;

    std::string sql = "SELECT count(*) FROM TASKLIST" + std::to_string(cur_tasklist) + ";";
    char* errMsg = nullptr;
    res = 0;

    auto callback = [](void* data, int argc, char** argv, char** azColName) {
        res = std::stoi(argv[0]);
        return 0;
    };

    int rc = sqlite3_exec(db, sql.c_str(), callback, nullptr, &errMsg);

    if (rc != SQLITE_OK) {
        std::cerr << "In queryTasksNum," << std::endl;
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return -1;
    }
    return res;
}

int DatabaseManager::deleteTaskById(int cur_tasklist, int id) const {
    std::string sql = "DELETE FROM TASKLIST" + std::to_string(cur_tasklist) + " WHERE ID = " + std::to_string(id) + ";";

    char* errMsg = nullptr;
    int rc = sqlite3_exec(db, sql.c_str(), nullptr, nullptr, &errMsg);

    if (rc != SQLITE_OK) {
        std::cerr << "In deleteTaskById," << std::endl;
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return -1;
    }

    std::cerr << "Task deleted from TASKLIST" << cur_tasklist << " successfully" << std::endl;
    return 0;
}

int DatabaseManager::updateTask(int cur_tasklist, int id, const std::string& title, const std::string& description,
                                long long startTime, long long endTime, int stat) const {
    std::string sql = "UPDATE TASKLIST" + std::to_string(cur_tasklist) +
        " SET "
        "TITLE = '" +
        title +
        "',  "
        "DESCRIPTION = '" +
        description +
        "',  "
        "START_TIME = " +
        std::to_string(startTime) +
        ",  "
        "END_TIME = " +
        std::to_string(endTime) +
        ",  "
        "STAT = " +
        std::to_string(stat) +
        " "
        "WHERE ID = " +
        std::to_string(id) + ";";

    char* errMsg = nullptr;
    int rc = sqlite3_exec(db, sql.c_str(), nullptr, nullptr, &errMsg);

    if (rc != SQLITE_OK) {
        std::cerr << "In updateTask," << std::endl;
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return -1;
    }

    std::cerr << "Task updated in TASKLIST" << cur_tasklist << "successfully" << std::endl;
    return 0;
}

[[deprecated]]
bool DatabaseManager::updateTaskTitle(int cur_tasklist, int id, const std::string& title) const {
    std::string sql = "UPDATE TASKLIST" + std::to_string(cur_tasklist) + " SET TITLE = '" + title +
        "' "
        "WHERE ID = " +
        std::to_string(id) + ";";

    char* errMsg = nullptr;
    int rc = sqlite3_exec(db, sql.c_str(), nullptr, nullptr, &errMsg);

    if (rc != SQLITE_OK) {
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return false;
    }

    std::cerr << "Task title updated in TASKLIST" << cur_tasklist << "successfully" << std::endl;
    return true;
}

[[deprecated]]
bool DatabaseManager::updateTaskStatus(int cur_tasklist, int id, int stat) const {
    std::string sql = "UPDATE TASKLIST" + std::to_string(cur_tasklist) + " SET STAT = " + std::to_string(stat) +
        " "
        "WHERE ID = " +
        std::to_string(id) + ";";

    char* errMsg = nullptr;
    int rc = sqlite3_exec(db, sql.c_str(), nullptr, nullptr, &errMsg);

    if (rc != SQLITE_OK) {
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return false;
    }

    std::cerr << "Task status updated in TASKLIST" << cur_tasklist << " successfully" << std::endl;
    return true;
}

// query by given list_id and task_id
int DatabaseManager::queryTaskById(int list_id, int task_id, Task* task) const {
    if (task == nullptr) {
        std::cerr << "In queryTaskById, task is nullptr" << std::endl;
        return -1;
    }

    std::string sql =
        "SELECT * FROM TASKLIST" + std::to_string(list_id) + " WHERE ID = " + std::to_string(task_id) + ";";
    char* errMsg = nullptr;

    auto callback = [](void* data, int argc, char** argv, char** azColName) {
        *static_cast<Task*>(data) = {0, std::stoi(argv[0]), argv[1], argv[2], argv[3], argv[4], std::stoi(argv[5])};
        return 0;
    };

    int rc = sqlite3_exec(db, sql.c_str(), callback, task, &errMsg);
    task->list_id = list_id;

    if (rc != SQLITE_OK) {
        std::cerr << "In queryTaskById," << std::endl;
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return -1;
    }
    return 0;
}

[[deprecated]]
bool DatabaseManager::queryTaskLists() const {
    std::string sql = "SELECT * FROM TASKLISTS;";
    char* errMsg = nullptr;

    auto callback = [](void* data, int argc, char** argv, char** azColName) {
        std::cerr << "Task num: " << argv[0] << ", Name: " << argv[1] << std::endl;
        return 0;
    };

    int rc = sqlite3_exec(db, sql.c_str(), callback, nullptr, &errMsg);

    if (rc != SQLITE_OK) {
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return false;
    }
    return true;
}

int DatabaseManager::queryTaskListsNum() const {

    std::string sql = "SELECT count(*) FROM TASKLISTS;";
    char* errMsg = nullptr;

    static int res;
    res = 0;

    auto callback = [](void* data, int argc, char** argv, char** azColName) {
        res = std::stoi(argv[0]);
        return 0;
    };

    int rc = sqlite3_exec(db, sql.c_str(), callback, nullptr, &errMsg);

    if (rc != SQLITE_OK) {
        std::cerr << "In queryTaskListsNum," << std::endl;
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return -1;
    }
    return res;
}

// query current task id ?
int DatabaseManager::queryTaskIdFromList(int list_id) const {

    std::string sql = "SELECT TASK_ID FROM TASKLISTS WHERE LIST_NAME = 'TASKLIST" + std::to_string(list_id) + "';";
    char* errMsg = nullptr;

    static int ret = 0;
    auto callback = [](void* data, int argc, char** argv, char** azColName) {
        ret = std::stoi(argv[0]);
        return 0;
    };
    int rc = sqlite3_exec(db, sql.c_str(), callback, nullptr, &errMsg);

    if (rc != SQLITE_OK) {
        std::cerr << "In queryTaskIdFromList," << std::endl;
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return false;
    }
    return ret;
}

// TODO add init check, check if init is called before any operation

DatabaseManager* db;
DART_API int Dart_init() {
    db = new DatabaseManager("tasks.db");

    if (db->initTaskListTable() == -1) {
        std::cerr << "Init TaskListTable failed." << std::endl;
        return -1;
    }
    std::cerr << "Create TaskListTable finished." << std::endl;

    tasklist_num = db->queryTaskListsNum();
    std::cerr << "Init tasklist_num: " << tasklist_num << std::endl;

    tasklist_id = db->get_tasklist_cur_id();

    while (tasklist_num < 1) { // if no list found, create a new one
        if (db->add_tasklist("Todo List", ++tasklist_id) == -1) {
            std::cerr << "Add tasklist failed." << std::endl;
            return -1;
        }
    }

    std::cerr << "Create Table finished." << std::endl;

    return 0;
}

DART_API int Dart_query_tasklist_num() { return tasklist_num; }

DART_API int Dart_query_tasklist_id(int num) {
    int res = db->queryTasklistIdByNum(num);
    std::cerr << "Tasklist id: " << res << std::endl;
    return res;
}

DART_API [[deprecated]] int Dart_query_task_num(int task_num) {
    int res = db->queryTaskIdFromList(task_num);
    std::cerr << "Task num: " << res << std::endl;
    return res;
}

DART_API int Dart_query_task_id(int list_id) {
    int res = db->queryTaskIdFromList(list_id);
    std::cerr << "Task num: " << res << std::endl;
    return res;
}

DART_API Dart_Task Dart_get_task(int list_num, int task_id) {
    Task* res = new Task;
    db->queryTaskById(list_num, task_id, res);
    std::cerr << "Query task finished." << std::endl;
    res->output();
    Dart_Task dart_task = covert_task_dart_task(*res);
    delete res;
    return dart_task;
}

DART_API int Dart_create_task(int list_num, const char* title, const char* description, const char* startDate,
                              const char* endDate, int status) {
    auto id = db->queryTaskIdFromList(list_num);
    std::cerr << "Create task id: " << id << std::endl;
    if (db->insertTask(list_num, id, title, description, string_to_timestamp(startDate), string_to_timestamp(endDate), status) == -1) {
        return -1;
    }
    std::cerr << "Create task finished." << std::endl;
    return id;
}

DART_API int Dart_update_task(int list_id, int task_id, const char* title, const char* description,
                              const char* startDate, const char* endDate, int status) {
    db->updateTask(list_id, task_id, title, description, string_to_timestamp(startDate), string_to_timestamp(endDate),
                   status);
    return 0;
}

DART_API int Dart_update_task_stat(int list_id, int task_id, int stat) {
    db->updateTaskStatus(list_id, task_id, stat);
    return 0;
}