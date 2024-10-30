package database;

import java.util.List;

public final class Plan {
    private final int _id;
    private final long _startTime, _endTime;
    private final String _title, _description;
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
    Plan(int id, String title, String description, long startTime, long endTime) {
        _id = id;
        _title = title;
        _description = description;
        _startTime = startTime;
        _endTime = endTime;
    }
}
