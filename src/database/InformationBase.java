package database;

import java.util.Date;
import java.util.Objects;

abstract class InformationBase implements Information {
    protected final int id;
    protected final Type type;
    protected State state;
    protected Date startTime, endTime;
    protected String title, description;

    @Override
    public int getID() {
        return id;
    }

    @Override
    public Type getType() {
        return type;
    }

    @Override
    public State getState() {
        return state;
    }

    @Override
    public Information withState(State state) {
        this.state = Objects.requireNonNull(state);
        return this;
    }

    @Override
    public Date getStartTime() {
        return startTime;
    }

    @Override
    public Information withStartTime(Date startTime) {
        this.startTime = Objects.requireNonNull(startTime);
        return this;
    }

    @Override
    public Date getEndTime() {
        return endTime;
    }

    @Override
    public Information withEndTime(Date endTime) {
        this.endTime = Objects.requireNonNull(endTime);
        return this;
    }

    @Override
    public String getTitle() {
        return title;
    }

    @Override
    public Information withTitle(String title) {
        this.title = Objects.requireNonNull(title);
        return this;
    }

    @Override
    public String getDescription() {
        return description;
    }

    @Override
    public Information withDescription(String description) {
        this.description = Objects.requireNonNull(description);
        return this;
    }

    protected InformationBase(int id, Type type, String title, String description, Date startTime, Date endTime, State state) {
        this.id = id;
        this.type = type;
        withState(state);
        withStartTime(startTime);
        withEndTime(endTime);
        withTitle(title);
        withDescription(description);
    }
}
