package ui.event;

import javafx.event.Event;
import javafx.event.EventType;

import java.time.LocalDate;

public class PlanningPaneEvent extends Event {
    public static final EventType<PlanningPaneEvent>
            CANCELED = new EventType<>(Event.ANY, "CANCELED"),
            CREATED = new EventType<>(Event.ANY, "CREATED");
    protected final Type _type;
    protected final String _title, _description;
    protected final LocalDate _startDate, _endDate;
    public PlanningPaneEvent(Type type, String title, String description, LocalDate startDate, LocalDate endDate) {
        super(type.toEventType());
        _type = type;
        _title = title;
        _description = description;
        _startDate = startDate;
        _endDate = endDate;
    }
    public Type getType() {
        return _type;
    }
    public String getTitle() {
        return _title;
    }
    public String getDescription() {
        return _description;
    }
    public LocalDate getStartDate() {
        return _startDate;
    }
    public LocalDate getEndDate() {
        return _endDate;
    }
    @Override
    @SuppressWarnings("unchecked")
    public EventType<? extends PlanningPaneEvent> getEventType() {
        return (EventType<? extends PlanningPaneEvent>) super.getEventType();
    }
    public enum Type {
        CANCELLING, CREATING;
        public EventType<? extends Event> toEventType() {
            switch (this) {
                case CANCELLING: return PlanningPaneEvent.CANCELED;
                case CREATING: return PlanningPaneEvent.CREATED;
                default: return Event.ANY;
            }
        }
    }
}
