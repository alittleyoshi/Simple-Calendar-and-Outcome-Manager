package database;

import java.util.List;

interface PlanImpl extends Information {
    List<Task> getTasks();
}
