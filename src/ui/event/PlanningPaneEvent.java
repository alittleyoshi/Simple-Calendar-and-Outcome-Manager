package ui.event;

import javafx.event.Event;
import javafx.event.EventType;

import java.time.LocalDate;

public class PlanningPaneEvent extends Event {
    public static final EventType<PlanningPaneEvent>
            CANCELED = new EventType<>(Event.ANY, "CANCELED"),
            CONFIRMED = new EventType<>(Event.ANY, "CONFIRMED");
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
        CANCELLING, CONFIRMED;
        public EventType<? extends Event> toEventType() {
            switch (this) {
                case CANCELLING: return PlanningPaneEvent.CANCELED;
                case CONFIRMED: return PlanningPaneEvent.CONFIRMED;
                default: return Event.ANY;
            }
        }
    }
}
