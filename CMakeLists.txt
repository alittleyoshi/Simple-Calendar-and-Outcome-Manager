cmake_minimum_required(VERSION 3.29)
project(SCOM_database)

set(CMAKE_CXX_STANDARD 20)

add_compile_definitions(SQLITE_ENABLE_RTREE
    SQLITE_ENABLE_COLUMN_METADATA
    SQLITE_ENABLE_DESERIALIZE
    SQLITE_ENABLE_FTS5
    SQLITE_ENABLE_FTS3)

# Add header and source files
set(SOURCES
    flutter_scom/lib/database.cpp
)

set(HEADERS
    flutter_scom/lib/database.h
)

# Create shared library
add_library(SCOM_database SHARED ${SOURCES} ${HEADERS})

# Add SQLite library
add_library(sqlite3 STATIC flutter_scom/lib/sqlite3.c)

# Link libraries
target_link_libraries(SCOM_database PRIVATE sqlite3)

target_include_directories(SCOM_database PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/flutter_scom/lib
)#target_link_libraries(SCOM_database PUBLIC sqlite3)