#include <iostream>
#include <chrono>
#include <iomanip>
#include <sqlite3.h>
#include <string>

#define DART_API extern "C" __attribute__((visibility("default"))) __attribute__((used))

struct Task{
	int is_in_tasklist;
	int id;
	std::string title;
	std::string description;
	std::string startDate;
	std::string endDate;
	int status;	// 0 - not started, 1 - completed, 2 - emergency
};

Task query_result;

int tasklist_num=0;


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
	
	int createTable() {
		std::string pre = "CREATE TABLE IF NOT EXISTS TASKLIST"
		+std::to_string(tasklist_num)+
		"("
		"ID INTEGER PRIMARY KEY AUTOINCREMENT,"
		"TITLE TEXT NOT NULL,"
		"DESCRIPTION TEXT,"
		"START_TIME INTEGER NOT NULL,"  // long long for timestamp
		"END_TIME INTEGER NOT NULL,"    // long long for timestamp
		"STAT INTEGER NOT NULL);";      // int for status
		const char* sql = pre.c_str();
		
		
		char* errMsg = 0;
		int rc = sqlite3_exec(db, sql, 0, 0, &errMsg);
		
		if (rc != SQLITE_OK) {
			std::cout << "SQL error: " << errMsg << std::endl;
			sqlite3_free(errMsg);
			return -1;
		}
		
		std::cout << "TASKLIST" << tasklist_num << " created successfully" << std::endl;
		tasklist_num++;
		return tasklist_num;
	}
	
	bool insertTask(int cur_tasklist,
		const std::string& title, 
		const std::string& description, 
		long long startTime,
		long long endTime,
		int stat) {
			std::string sql = "INSERT INTO TASKLIST"
			+std::to_string(cur_tasklist)+
			"(TITLE, DESCRIPTION, START_TIME, END_TIME, STAT) "
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
			
			std::cout << "Task inserted into TASKLIST"<<cur_tasklist<<" successfully" << std::endl;
			return true;
		}
	
	
	bool queryTasks(int cur_tasklist) {
		static int temp;
		std::string sql = "SELECT * FROM TASKLIST"+std::to_string(cur_tasklist)+";";
		char* errMsg = 0;
		
		temp = cur_tasklist;
		
		auto callback = [](void* data, int argc, char** argv, char** azColName) {
			query_result = {temp, std::stoi(argv[0]), argv[1], argv[2], argv[3], argv[4], argv[5][0] - '0'};
//		for(int i = 0; i < argc; i++) {
//			std::cout << azColName[i] << ": " << (argv[i] ? argv[i] : "NULL") << std::endl;
//		}
			std::cout << std::endl;
			return 0;
		};
		
		int rc = sqlite3_exec(db, sql.c_str(), callback, 0, &errMsg);
		
		if (rc != SQLITE_OK) {
			std::cout << "SQL error: " << errMsg << std::endl;
			sqlite3_free(errMsg);
			return false;
		}
		return true;
	}
	
	bool deleteTaskById(int cur_tasklist, int id) {
		std::string sql = "DELETE FROM TASKLIST"
		+std::to_string(cur_tasklist)+" WHERE ID = " + std::to_string(id) + ";";
		
		char* errMsg = 0;
		int rc = sqlite3_exec(db, sql.c_str(), 0, 0, &errMsg);
		
		if (rc != SQLITE_OK) {
			std::cout << "SQL error: " << errMsg << std::endl;
			sqlite3_free(errMsg);
			return false;
		}
		
		std::cout << "Task deleted from TASKLIST"<<cur_tasklist<<" successfully" << std::endl;
		return true;
	}
	
	bool updateTask(int cur_tasklist,
		int id,
		const std::string& title,
		const std::string& description,
		long long startTime,
		long long endTime,
		int stat) {
			std::string sql = "UPDATE "
			+std::to_string(cur_tasklist)+" SET "
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
			
			std::cout << "Task updated in TASKLIST"<<cur_tasklist<<"successfully" << std::endl;
			return true;
		}
	
	// 更新单个字段的便捷方法
	bool updateTaskTitle(int cur_tasklist,int id, const std::string& title) {
		std::string sql = "UPDATE TASKLIST"
		+std::to_string(cur_tasklist)+
		" SET TITLE = '" + title + "' "
		"WHERE ID = " + std::to_string(id) + ";";
		
		char* errMsg = 0;
		int rc = sqlite3_exec(db, sql.c_str(), 0, 0, &errMsg);
		
		if (rc != SQLITE_OK) {
			std::cout << "SQL error: " << errMsg << std::endl;
			sqlite3_free(errMsg);
			return false;
		}
		
		std::cout << "Task title updated in TASKLIST"<<cur_tasklist<<"successfully" << std::endl;
		return true;
	}
	
	bool updateTaskStatus(int cur_tasklist, int id, int stat) {
		std::string sql = "UPDATE TASKLIST"
		+std::to_string(cur_tasklist)+
		" SET STAT = " + std::to_string(stat) + " "
		"WHERE ID = " + std::to_string(id) + ";";
		
		char* errMsg = 0;
		int rc = sqlite3_exec(db, sql.c_str(), 0, 0, &errMsg);
		
		if (rc != SQLITE_OK) {
			std::cout << "SQL error: " << errMsg << std::endl;
			sqlite3_free(errMsg);
			return false;
		}
		
		std::cout << "Task status updated in TASKLIST"<<cur_tasklist<<" successfully" << std::endl;
		return true;
	}
};

//TODO given list_id and id return Task
//DART_API Task dart_query(
//	const char *title, 
//	const char *description, 
//	const char *startTime, 
//	const char *endTime, 
//	int status){
//		return Task{title,description,startTime,endTime,status};
//}

DART_API int query_tasklist_num(){
	return tasklist_num;
}




void output(Task result){
	std::cout<<result.is_in_tasklist<<' '
	<<result.id<<' '
	<<result.title<<' '
	<<result.description<<' '
	<<result.startDate<<' '
	<<result.endDate<<' '
	<<result.status<<'\n';
}

std::string timestampToString(time_t timestamp) { 
	std::tm* tm = std::localtime(&timestamp); 
	std::stringstream ss; 
	ss << std::put_time(tm, "%Y-%m-%d %H:%M:%S"); 
	return ss.str();
}


// 在main函数中使用这些新方法的示例：
int main() {
	DatabaseManager dbManager("tasks.db");
	
	// 创建表
	dbManager.createTable();
	
	// 插入示例数据
	dbManager.insertTask(
		0,
		"First title", 
		"First desctription", 
		16776492,
		16776528,
		1
		);
	
	// 查询初始状态
	std::cout << "\nQuery task:\n";
	dbManager.queryTasks(0);
	output(query_result);
	
	dbManager.updateTaskStatus(0, 1, 2);
	
	dbManager.queryTasks(0);
	output(query_result);
	
	dbManager.createTable();
	
	dbManager.insertTask(1,"task2","des2",114514,1919810,0);
	
	dbManager.queryTasks(0);
	output(query_result);
	dbManager.queryTasks(1);
	output(query_result);
	
	std::cout<<timestampToString(16776492);
	
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


DART_API int test(){
	DatabaseManager dbManager("tasks.db");
	
	// 创建表
	dbManager.createTable();
	
	// 插入示例数据
	dbManager.insertTask(
		0,
		"First title", 
		"First desctription", 
		16776492,
		16776528,
		1
		);
	
	// 查询初始状态
	std::cout << "\nQuery task:\n";
	dbManager.queryTasks(0);
	output(query_result);
	
	dbManager.updateTaskStatus(0, 1, 2);
	
	dbManager.queryTasks(0);
	output(query_result);
	
	dbManager.createTable();
	
	dbManager.insertTask(1,"task2","des2",114514,1919810,0);
	
	dbManager.queryTasks(0);
	output(query_result);
	dbManager.queryTasks(1);
	output(query_result);
	
	std::cout<<timestampToString(16776492);
	
}
