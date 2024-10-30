package database;

public final class Task {
    private final int _id;
    private final long _startTime, _endTime;
    private final String _title, _description;
    private final Plan _plan;
    public int getID() {
        return _id;
    }
    public Plan getPlan() {
        return _plan;
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
    Task(int id, Plan plan, String title, String description, long startTime, long endTime) {
        _id = id;
        _plan = plan;
        _title = title;
        _description = description;
        _startTime = startTime;
        _endTime = endTime;
    }
}
