### Structure

#### TABLE(TASKLIST + num) 

e.g. (TASKLIST1)

Some tables to store the tasks(id, title, description, start_time, end_time, status)

could be modified with id

#### TABLE(TASKLISTS)

The table to store the tasklist(TASK_ID, LIST_NAME, ID)

### NT (Version 0.0.2(3))

DATABASE:

  - TABLE: META (VERSION, LIST_ID, TASK_ID)
    - NAME: TEXT (KEY)
    - VALUE: TEXT
 
  - TABLE: TASKLISTS
    - LIST_ID: INT (KEY)
    - TITLE: TEXT
  
  - TABLE: TASKS
    - TASK_ID: INT (KEY)
    - BELONG: INT
    - TITLE: TEXT
    - DESCRIPTION: TEXT
    - START_TIME: INT
    - END_TIME: INT
    - STATUS: INT