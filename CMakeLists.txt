#cmake_minimum_required(VERSION 3.29)
#project(Simple_Calender_and_Outcome_Manager)
#
#set(CMAKE_CXX_STANDARD 14)
#
#add_executable(Simple_Calender_and_Outcome_Manager
#    flutter_scom/lib/database.cpp)

cmake_minimum_required(VERSION 3.29)
project(SCOM_database)

set(CMAKE_CXX_STANDARD 20)

#find_library(sqlite3Lib sqlite3 HINTS D:\\Kibi\\sqlite3)

add_library(SCOM_database SHARED flutter_scom/lib/database.cpp)

target_link_directories(SCOM_database PUBLIC flutter_scom/lib)

target_link_libraries(SCOM_database LINK_PUBLIC sqlite3)