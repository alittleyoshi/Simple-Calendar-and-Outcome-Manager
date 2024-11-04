package database;

import javafx.collections.ObservableList;
import javafx.collections.ObservableListBase;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;

public final class Plan {
    private final int _id;
    private Date _startTime, _endTime;
    private String _title, _description;
    private final List<Task> _tasks = new ArrayList<>();
    public int getID() {
        return _id;
    }
    public Date getStartTime() {
        return _startTime;
    }
    public void setStartTime(Date startTime) {
        _startTime = startTime;
        DatabaseManager.updatePlan(this);
    }
    public Date getEndTime() {
        return _endTime;
    }
    public void setEndTime(Date endTime) {
        _endTime = endTime;
        DatabaseManager.updatePlan(this);
    }
    public String getTitle() {
        return _title;
    }
    public void setTitle(String title) {
        _title = title;
        DatabaseManager.updatePlan(this);
    }
    public String getDescription() {
        return _description;
    }
    public void setDescription(String description) {
        _description = description;
        DatabaseManager.updatePlan(this);
    }
    public List<Task> getTasks() {
        return Collections.unmodifiableList(_tasks);
    }
    public void setContext(String title, String description, Date startTime, Date endTime) {
        _title = title;
        _description = description;
        _startTime = startTime;
        _endTime = endTime;
        DatabaseManager.updatePlan(this);
    }
    Plan(int id, String title, String description, Date startTime, Date endTime) {
        _id = id;
        _title = title;
        _description = description;
        _startTime = startTime;
        _endTime = endTime;
    }
    void addTask(Task task) {
        _tasks.add(task);
    }
    void removeTask(Task task) {
        _tasks.remove(task);
    }
    public Status getStatus() {
        boolean hasUnstarted = false, hasCompleted = false;
        for (Task task : _tasks) {
            switch (task.getStatus()) {
                case Working:
                    return Status.Working;
                case Unstarted:
                    hasUnstarted = true;
                    break;
                case Completed:
                    hasCompleted = true;
                    break;
                default:
                    break;
            }
        }
        if (hasUnstarted) {
            if (hasCompleted) {
                return Status.Working;
            } else {
                return Status.Unstarted;
            }
        } else {
            if (hasCompleted) {
                return Status.Completed;
            } else {
                return Status.Unstarted;
            }
        }
    }
    @Override
    public String toString() {
        return "Plan{" +
                "id=" + _id +
                ", startTime=" + _startTime +
                ", endTime=" + _endTime +
                ", title='" + _title + '\'' +
                ", description='" + _description + '\'' +
                ", tasks=" + _tasks +
                '}';
    }
}
