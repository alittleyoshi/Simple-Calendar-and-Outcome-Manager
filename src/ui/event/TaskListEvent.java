package ui.event;

import javafx.event.Event;
import javafx.event.EventType;

public class TaskListEvent extends Event {
    public static final EventType<TaskListEvent>
            ADDING = new EventType<>(Event.ANY, "ADDING");
    public TaskListEvent(Type type) {
        super(type.toEventType());
    }
    public enum Type {
        ADDING;
        public EventType<? extends Event> toEventType() {
            switch (this) {
                case ADDING: return TaskListEvent.ADDING;
                default: return Event.ANY;
            }
        }
    }
}
