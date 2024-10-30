package database;

import java.util.Date;

public final class Task {
    private final int _id;
    private Date _startTime, _endTime;
    private String _title, _description;
    private TaskStatus _status;
    private final Plan _plan;
    public int getID() {
        return _id;
    }
    public Plan getPlan() {
        return _plan;
    }
    public Date getStartTime() {
        return _startTime;
    }
    public void setStartTime(Date startTime) {
        _startTime = startTime;
        DatabaseManager.updateTask(this);
    }
    public Date getEndTime() {
        return _endTime;
    }
    public void setEndTime(Date endTime) {
        _endTime = endTime;
        DatabaseManager.updateTask(this);
    }
    public String getTitle() {
        return _title;
    }
    public void setTitle(String title) {
        _title = title;
        DatabaseManager.updateTask(this);
    }
    public String getDescription() {
        return _description;
    }
    public void setDescription(String description) {
        _description = description;
        DatabaseManager.updateTask(this);
    }
    public TaskStatus getStatus() {
        return _status;
    }
    public void setStatus(TaskStatus status) {
        _status = status;
        DatabaseManager.updateTask(this);
    }
    public void setContext(String title, String description, Date startTime, Date endTime, TaskStatus status) {
        _title = title;
        _description = description;
        _startTime = startTime;
        _endTime = endTime;
        _status = status;
        DatabaseManager.updateTask(this);
    }
    Task(int id, Plan plan, String title, String description, Date startTime, Date endTime, TaskStatus status) {
        _id = id;
        _plan = plan;
        _title = title;
        _description = description;
        _startTime = startTime;
        _endTime = endTime;
        _status = status;
    }
    @Override
    public String toString() {
        return "Task{" +
                "id=" + _id +
                ", startTime=" + _startTime +
                ", endTime=" + _endTime +
                ", title='" + _title + '\'' +
                ", description='" + _description + '\'' +
                ", plan.id=" + _plan.getID() +
                '}';
    }
}
