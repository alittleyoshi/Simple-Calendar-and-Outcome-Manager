package database;

import javafx.collections.ObservableList;
import javafx.collections.ObservableListBase;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public final class Plan {
    private final int _id;
    private final long _startTime, _endTime;
    private final String _title, _description;
    private final List<Task> _tasks = new ArrayList<>();
    public int getID() {
        return _id;
    }
    public long getStartTime() {
        return _startTime;
    }
    public long getEndTime() {
        return _endTime;
    }
    public String getTitle() {
        return _title;
    }
    public String getDescription() {
        return _description;
    }
    public List<Task> getTasks() {
        return Collections.unmodifiableList(_tasks);
    }
    void addTask(Task task) {
        _tasks.add(task);
    }
    boolean removeTask(Task task) {
        return _tasks.remove(task);
    }
    Plan(int id, String title, String description, long startTime, long endTime) {
        _id = id;
        _title = title;
        _description = description;
        _startTime = startTime;
        _endTime = endTime;
    }
}
