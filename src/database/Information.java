package database;

import java.util.Date;

public interface Information {
    int getID();

    Type getType();

    State getState();

    Information withState(State state);

    Date getStartTime();

    Information withStartTime(Date startTime);

    Date getEndTime();

    Information withEndTime(Date endTime);

    String getTitle();

    Information withTitle(String title);

    String getDescription();

    Information withDescription(String description);

    void update();
}
