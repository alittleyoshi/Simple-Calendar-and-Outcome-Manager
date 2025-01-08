package database;

import java.util.Date;

public interface Information {
    int getID();
    Date getStartTime();
    void setStartTime(Date startTime);
    Date getEndTime();
    void setEndTime(Date endTime);
    String getTitle();
    void setTitle(String title);
    String getDescription();
    void setDescription(String description);
}
