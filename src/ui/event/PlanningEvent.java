package ui.event;

import javafx.event.Event;
import javafx.event.EventType;

public class PlanningEvent extends Event {
    public static final EventType<PlanningEvent>
            CANCELLING = new EventType<>(Event.ANY, "CANCELLING"),
            CREATING = new EventType<>(Event.ANY, "CREATING");
    public PlanningEvent(EventType<? extends Event> eventType) {
        super(eventType);
    }
    @Override
    @SuppressWarnings("unchecked")
    public EventType<? extends PlanningEvent> getEventType() {
        return (EventType<? extends PlanningEvent>) super.getEventType();
    }
}
