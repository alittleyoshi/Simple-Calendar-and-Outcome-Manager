#include <iostream>
#include <sqlite3.h>
#include <string>

#define DART_API extern "C" __attribute__((visibility("default"))) __attribute__((used))

struct Task{
	std::string title;
	std::string description;
	std::string startDate;
	std::string endDate;
	int status;	// 0 - not started, 1 - completed, 2 - emergency
};

Task query_result;

class DatabaseManager {
private:
	sqlite3* db;
	
public:
	DatabaseManager(const std::string& dbName) {
		int rc = sqlite3_open(dbName.c_str(), &db);
		if (rc) {
			std::cout << "Cannot open database: " << sqlite3_errmsg(db) << std::endl;
			return;
		}
		std::cout << "Database opened successfully" << std::endl;
	}
	
	~DatabaseManager() {
		sqlite3_close(db);
	}
	
	bool createTable() {
		const char* sql = "CREATE TABLE IF NOT EXISTS TASKS("
		"ID INTEGER PRIMARY KEY AUTOINCREMENT,"
		"TITLE TEXT NOT NULL,"
		"DESCRIPTION TEXT,"
		"START_TIME INTEGER NOT NULL,"  // long long for timestamp
		"END_TIME INTEGER NOT NULL,"    // long long for timestamp
		"STAT INTEGER NOT NULL);";      // int for status
		
		char* errMsg = 0;
		int rc = sqlite3_exec(db, sql, 0, 0, &errMsg);
		
		if (rc != SQLITE_OK) {
			std::cout << "SQL error: " << errMsg << std::endl;
			sqlite3_free(errMsg);
			return false;
		}
		
		std::cout << "Table created successfully" << std::endl;
		return true;
	}
	
	bool insertTask(const std::string& title, 
		const std::string& description, 
		long long startTime,
		long long endTime,
		int stat) {
			std::string sql = "INSERT INTO TASKS (TITLE, DESCRIPTION, START_TIME, END_TIME, STAT) "
			"VALUES ('" + title + "', '" + description + "', " + 
			std::to_string(startTime) + ", " + 
			std::to_string(endTime) + ", " +
			std::to_string(stat) + ");";
			
			char* errMsg = 0;
			int rc = sqlite3_exec(db, sql.c_str(), 0, 0, &errMsg);
			
			if (rc != SQLITE_OK) {
				std::cout << "SQL error: " << errMsg << std::endl;
				sqlite3_free(errMsg);
				return false;
			}
			
			std::cout << "Task inserted successfully" << std::endl;
			return true;
		}
	
	static int callback(void* data, int argc, char** argv, char** azColName) {
		query_result = {argv[1], argv[2], argv[3], argv[4], argv[5][0] - '0'};
		for(int i = 0; i < argc; i++) {
			std::cout << azColName[i] << ": " << (argv[i] ? argv[i] : "NULL") << std::endl;
		}
		std::cout << std::endl;
		return 0;
	}
	
	bool queryTasks() {
		const char* sql = "SELECT * FROM TASKS;";
		char* errMsg = 0;
		
		int rc = sqlite3_exec(db, sql, callback, 0, &errMsg);
		
		if (rc != SQLITE_OK) {
			std::cout << "SQL error: " << errMsg << std::endl;
			sqlite3_free(errMsg);
			return false;
		}
		return true;
	}
	
	bool deleteTaskById(int id) {
		std::string sql = "DELETE FROM TASKS WHERE ID = " + std::to_string(id) + ";";
		
		char* errMsg = 0;
		int rc = sqlite3_exec(db, sql.c_str(), 0, 0, &errMsg);
		
		if (rc != SQLITE_OK) {
			std::cout << "SQL error: " << errMsg << std::endl;
			sqlite3_free(errMsg);
			return false;
		}
		
		std::cout << "Task deleted successfully" << std::endl;
		return true;
	}
	
	bool updateTask(int id,
		const std::string& title,
		const std::string& description,
		long long startTime,
		long long endTime,
		int stat) {
			std::string sql = "UPDATE TASKS SET "
			"TITLE = '" + title + "', "
			"DESCRIPTION = '" + description + "', "
			"START_TIME = " + std::to_string(startTime) + ", "
			"END_TIME = " + std::to_string(endTime) + ", "
			"STAT = " + std::to_string(stat) + " "
			"WHERE ID = " + std::to_string(id) + ";";
			
			char* errMsg = 0;
			int rc = sqlite3_exec(db, sql.c_str(), 0, 0, &errMsg);
			
			if (rc != SQLITE_OK) {
				std::cout << "SQL error: " << errMsg << std::endl;
				sqlite3_free(errMsg);
				return false;
			}
			
			std::cout << "Task updated successfully" << std::endl;
			return true;
		}
	
	// 更新单个字段的便捷方法
	bool updateTaskTitle(int id, const std::string& title) {
		std::string sql = "UPDATE TASKS SET TITLE = '" + title + "' "
		"WHERE ID = " + std::to_string(id) + ";";
		
		char* errMsg = 0;
		int rc = sqlite3_exec(db, sql.c_str(), 0, 0, &errMsg);
		
		if (rc != SQLITE_OK) {
			std::cout << "SQL error: " << errMsg << std::endl;
			sqlite3_free(errMsg);
			return false;
		}
		
		std::cout << "Task title updated successfully" << std::endl;
		return true;
	}
	
	bool updateTaskStatus(int id, int stat) {
		std::string sql = "UPDATE TASKS SET STAT = " + std::to_string(stat) + " "
		"WHERE ID = " + std::to_string(id) + ";";
		
		char* errMsg = 0;
		int rc = sqlite3_exec(db, sql.c_str(), 0, 0, &errMsg);
		
		if (rc != SQLITE_OK) {
			std::cout << "SQL error: " << errMsg << std::endl;
			sqlite3_free(errMsg);
			return false;
		}
		
		std::cout << "Task status updated successfully" << std::endl;
		return true;
	}
};


DART_API Task dart_query(const char *title, 
	const char *description, 
	const char *startTime, 
	const char *endTime, 
	int status){
		return Task{title,description,startTime,endTime,status};
}


// 在main函数中使用这些新方法的示例：
int main() {
	DatabaseManager dbManager("tasks.db");
	
	// 创建表
	dbManager.createTable();
	
	// 插入示例数据
	dbManager.insertTask(
		"Meeting", 
		"Team weekly meeting", 
		1677649200000,  
		1677652800000,  
		1              
		);
	
	// 查询初始状态
	std::cout << "\nInitial task:\n";
	dbManager.queryTasks();
	
	std::cout<<query_result.title<<' '<<query_result.description<<' '<<query_result.startDate<<' '<<query_result.endDate<<' '<<query_result.status<<'\n';
	
	// // 更新整个任务
	// dbManager.updateTask(
	// 	1,                  // ID
	// 	"Updated Meeting",  // 新标题
	// 	"Updated description", // 新描述
	// 	1677649200000,     // 新开始时间
	// 	1677652800000,     // 新结束时间
	// 	2                  // 新状态
	// 	);

	// // 查询更新后的状态
	// std::cout << "\nAfter full update:\n";
	// dbManager.queryTasks();

	// // 只更新标题
	// dbManager.updateTaskTitle(1, "Quick Meeting");

	// // 只更新状态
	// dbManager.updateTaskStatus(1, 3);
	
	// // 查询最终状态
	// std::cout << "\nAfter partial updates:\n";
	// dbManager.queryTasks();

	system("pause");
	return 0;
}
