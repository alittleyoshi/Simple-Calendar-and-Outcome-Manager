package ui.event;

import javafx.event.Event;
import javafx.event.EventType;

public class PlanItemEvent extends Event {
    public static final EventType<PlanItemEvent>
            DELETED = new EventType<>(Event.ANY, "DELETED");
    public PlanItemEvent(Type type) {
        super(type.toEventType());
    }
    public enum Type {
        DELETED;
        public EventType<? extends Event> toEventType() {
            switch (this) {
                case DELETED: return PlanItemEvent.DELETED;
                default: return Event.ANY;
            }
        }
    }
}
