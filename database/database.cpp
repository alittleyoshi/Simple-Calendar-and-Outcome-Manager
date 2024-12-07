#include "database.h"
#include <chrono>
#include <cstring>
#include <iomanip>
#include <iostream>
#include <string>
#include "sqlite3.h"

#define DART_API extern "C" __attribute__((visibility("default"))) __attribute__((used))

Task query_result; // 每次查询后的结果存贮在这里

int tasklist_num = 0; // list数量

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

int DatabaseManager::add_tasklist() const {

    // create a task table
    std::string pre = "CREATE TABLE IF NOT EXISTS TASKLIST" + std::to_string(tasklist_num) +
        "("
        "ID INTEGER PRIMARY KEY, " // Removed AUTOINCREMENT
        "TITLE TEXT NOT NULL, "
        "DESCRIPTION TEXT, "
        "START_TIME INTEGER NOT NULL, "
        "END_TIME INTEGER NOT NULL, "
        "STAT INTEGER NOT NULL);";
    const char* sql = pre.c_str();

    char* errMsg = nullptr;
    int rc = sqlite3_exec(db, sql, nullptr, nullptr, &errMsg);

    // TODO improve error message for sqlite error
    if (rc != SQLITE_OK) {
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return -1;
    }

    // Insert new tasklist record
    std::string insertList = "INSERT INTO TASKLISTS (TASK_NUM, LIST_NAME) VALUES (" + std::to_string(0) +
        ", 'TASKLIST" + std::to_string(tasklist_num) + "');";

    rc = sqlite3_exec(db, insertList.c_str(), nullptr, nullptr, &errMsg);

    // TODO improve error message for sqlite error
    if (rc != SQLITE_OK) {
        std::cerr << "In createTable," << std::endl;
        std::cerr << "TaskListNum: " << tasklist_num << std::endl;
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return -1;
    }

    std::cerr << "TASKLIST" << tasklist_num << " created successfully" << std::endl;
    tasklist_num++;
    return tasklist_num;
}

/**
 *
 * @return -1: failed, 0: success
 */
int DatabaseManager::initTaskListTable() const {
     const auto sql = "CREATE TABLE IF NOT EXISTS TASKLISTS ("
                      "TASK_NUM INTEGER NOT NULL, " // 任务数量
                      "LIST_NAME TEXT NOT NULL PRIMARY KEY);";

    char* errMsg = nullptr;
    const int rc = sqlite3_exec(db, sql, nullptr, nullptr, &errMsg);

    // TODO improve error message for sqlite error
    if (rc != SQLITE_OK) {
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return -1;
    }
    return 0;
}


bool DatabaseManager::insertTask(int cur_tasklist,
                                 int task_id, // 新加入的task的id
                                 const std::string& title, const std::string& description, long long startTime,
                                 long long endTime, int stat) const {
    std::string sql = "INSERT INTO TASKLIST" + std::to_string(cur_tasklist) +
        "(ID, TITLE, DESCRIPTION, START_TIME, END_TIME, STAT) "
        "VALUES (" +
        std::to_string(task_id) + ", '" + title + "', '" + description + "', " + std::to_string(startTime) + ", " +
        std::to_string(endTime) + ", " + std::to_string(stat) + ");";

    char* errMsg = nullptr;
    int rc = sqlite3_exec(db, sql.c_str(), nullptr, nullptr, &errMsg);

    // TODO improve error message for sqlite error
    if (rc != SQLITE_OK) {
        std::cerr << "In function insertTask," << std::endl;
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return false;
    }

    std::string modifyList = "UPDATE TASKLISTS SET TASK_NUM = TASK_NUM + 1 WHERE LIST_NAME = 'TASKLIST" +
        std::to_string(cur_tasklist) + "';";
    rc = sqlite3_exec(db, modifyList.c_str(), nullptr, nullptr, &errMsg);
        // TODO improve error message for sqlite error
    if (rc != SQLITE_OK) {
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return false;
    }


    std::cerr << "Task inserted into TASKLIST" << cur_tasklist << " successfully" << std::endl;
    return true;
}

bool DatabaseManager::_queryTasks(int cur_tasklist) const {
    static int temp;
    std::string sql = "SELECT * FROM TASKLIST" + std::to_string(cur_tasklist) + ";";
    char* errMsg = nullptr;

    temp = cur_tasklist;

    auto callback = [](void* data, int argc, char** argv, char** azColName) {
        query_result = {temp, std::stoi(argv[0]), argv[1], argv[2], argv[3], argv[4], argv[5][0] - '0'};
        std::cerr << std::endl;
        return 0;
    };

    int rc = sqlite3_exec(db, sql.c_str(), callback, nullptr, &errMsg);

    // TODO improve error message for sqlite error
    if (rc != SQLITE_OK) {
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return false;
    }
    return true;
}

int DatabaseManager::queryTasksNum(int cur_tasklist) const {
    static int res;
    std::string sql = "SELECT * FROM TASKLIST" + std::to_string(cur_tasklist) + ";";
    char* errMsg = nullptr;

    res = 0;

    auto callback = [](void* data, int argc, char** argv, char** azColName) {
        res++;
        return 0;
    };

    int rc = sqlite3_exec(db, sql.c_str(), callback, nullptr, &errMsg);

    // TODO improve error message for sqlite error
    if (rc != SQLITE_OK) {
        std::cerr << "In queryTasksNum," << std::endl;
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return false;
    }
    return res;
}

bool DatabaseManager::deleteTaskById(int cur_tasklist, int id) const {
    std::string sql = "DELETE FROM TASKLIST" + std::to_string(cur_tasklist) + " WHERE ID = " + std::to_string(id) + ";";

    char* errMsg = nullptr;
    int rc = sqlite3_exec(db, sql.c_str(), nullptr, nullptr, &errMsg);

    // TODO improve error message for sqlite error
    if (rc != SQLITE_OK) {
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return false;
    }

    std::cerr << "Task deleted from TASKLIST" << cur_tasklist << " successfully" << std::endl;
    return true;
}

bool DatabaseManager::updateTask(int cur_tasklist, int id, const std::string& title, const std::string& description,
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

    // TODO improve error message for sqlite error
    if (rc != SQLITE_OK) {
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return false;
    }

    std::cerr << "Task updated in TASKLIST" << cur_tasklist << "successfully" << std::endl;
    return true;
}

// 更新单个字段的便捷方法
bool DatabaseManager::updateTaskTitle(int cur_tasklist, int id, const std::string& title) const {
    std::string sql = "UPDATE TASKLIST" + std::to_string(cur_tasklist) + " SET TITLE = '" + title +
        "' "
        "WHERE ID = " +
        std::to_string(id) + ";";

    char* errMsg = nullptr;
    int rc = sqlite3_exec(db, sql.c_str(), nullptr, nullptr, &errMsg);

    // TODO improve error message for sqlite error
    if (rc != SQLITE_OK) {
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return false;
    }

    std::cerr << "Task title updated in TASKLIST" << cur_tasklist << "successfully" << std::endl;
    return true;
}

bool DatabaseManager::updateTaskStatus(int cur_tasklist, int id, int stat) const {
    std::string sql = "UPDATE TASKLIST" + std::to_string(cur_tasklist) + " SET STAT = " + std::to_string(stat) +
        " "
        "WHERE ID = " +
        std::to_string(id) + ";";

    char* errMsg = nullptr;
    int rc = sqlite3_exec(db, sql.c_str(), nullptr, nullptr, &errMsg);

    // TODO improve error message for sqlite error
    if (rc != SQLITE_OK) {
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return false;
    }

    std::cerr << "Task status updated in TASKLIST" << cur_tasklist << " successfully" << std::endl;
    return true;
}

// 根据list和id查找
bool DatabaseManager::queryTaskById(int list_id, int task_id) const {
    static int temp;
    std::string sql =
        "SELECT * FROM TASKLIST" + std::to_string(list_id) + " WHERE ID = " + std::to_string(task_id) + ";";
    char* errMsg = nullptr;

    temp = list_id;

    auto callback = [](void* data, int argc, char** argv, char** azColName) {
        query_result = {temp, std::stoi(argv[0]), argv[1], argv[2], argv[3], argv[4], argv[5][0] - '0'};
        std::cerr << std::endl;
        return 0;
    };

    int rc = sqlite3_exec(db, sql.c_str(), callback, nullptr, &errMsg);

    // TODO improve error message for sqlite error
    if (rc != SQLITE_OK) {
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return false;
    }
    return true;
}

bool DatabaseManager::queryTaskLists() const {
    std::string sql = "SELECT * FROM TASKLISTS;";
    char* errMsg = nullptr;

    auto callback = [](void* data, int argc, char** argv, char** azColName) {
        std::cerr << "Task num: " << argv[0] << ", Name: " << argv[1] << std::endl;
        return 0;
    };

    int rc = sqlite3_exec(db, sql.c_str(), callback, nullptr, &errMsg);

    // TODO improve error message for sqlite error
    if (rc != SQLITE_OK) {
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return false;
    }
    return true;
}

int DatabaseManager::queryTaskListsNum() const {
    std::string sql = "SELECT * FROM TASKLISTS;";
    char* errMsg = nullptr;

    static int res;
    res = 0;

    auto callback = [](void* data, int argc, char** argv, char** azColName) {
        res++;
        return 0;
    };

    int rc = sqlite3_exec(db, sql.c_str(), callback, nullptr, &errMsg);

    // TODO improve error message for sqlite error
    if (rc != SQLITE_OK) {
        std::cerr << "In queryTaskListsNum," << std::endl;
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return false;
    }
    return res;
}

int DatabaseManager::queryTaskIdFromList(int list_id) const {
    std::string sql = "SELECT TASK_NUM FROM TASKLISTS WHERE LIST_NAME = 'TASKLIST" + std::to_string(list_id) + "';";
    char* errMsg = nullptr;
    static int ret = 0;
    auto callback = [](void* data, int argc, char** argv, char** azColName) {
        ret = std::stoi(argv[0]);
        std::cerr << "Task num: " << argv[0] << std::endl;
        return 0;
    };
    int rc = sqlite3_exec(db, sql.c_str(), callback, nullptr, &errMsg);

    // TODO improve error message for sqlite error
    if (rc != SQLITE_OK) {
        std::cerr << "In queryTaskIdFromList," << std::endl;
        std::cerr << "list_id: " << list_id << std::endl;
        std::cerr << "ret: " << ret << std::endl;
        std::cerr << "SQL error: " << errMsg << std::endl;
        sqlite3_free(errMsg);
        return false;
    }
    return ret;
}

// };

// TODO given list_id and id return Task
// DART_API Task dart_query(
//	const char *title,
//	const char *description,
//	const char *startTime,
//	const char *endTime,
//	int status){
//		return Task{title, description, startTime, endTime, status};
// }

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

    while (tasklist_num < 2) { // if no list found, create a new one
        db->add_tasklist();
    }
    std::cerr << "Create Table finished." << std::endl;

    return 0;
}

DART_API int Dart_query_tasklist_num() { return tasklist_num; }

DART_API int Dart_query_task_num(int task_num) {
    int res = db->queryTaskIdFromList(task_num);
    std::cerr << "Task num: " << res << std::endl;
    return res;
}

DART_API Dart_Task Dart_get_task(int list_num, int task_id) {
    db->queryTaskById(list_num, task_id);
    std::cerr << "Query task finished." << std::endl;
    query_result.output();
    return covert_task_dart_task(query_result);
}

DART_API int Dart_create_task(int list_num, const char* title, const char* description, const char* startDate,
                              const char* endDate, int status) {
    auto id = db->queryTaskIdFromList(list_num);
    std::cerr << "Create task id: " << id << std::endl;
    db->insertTask(list_num, id, title, description, string_to_timestamp(startDate), string_to_timestamp(endDate),
                   status);
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

#ifdef TEST

DART_API int Dart_test() {
    Dart_init();

    return 0;
}

DART_API int Dart_test_f1() {
    std::cerr << 1 << std::endl;
    return 0;
}

DART_API void Dart_test_f2() { std::cerr << 2 << std::endl; }

DART_API int Dart_test_f3(int val) {
    std::cerr << 3 << std::endl;
	return val;
}

int main() {
	Dart_test();

	return 0;
}

#endif