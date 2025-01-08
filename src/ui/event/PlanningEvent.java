package ui.event;

import database.Plan;
import javafx.event.Event;
import javafx.event.EventType;

import java.time.LocalDate;

public class PlanningEvent extends Event {
    public static final EventType<PlanningEvent>
            CANCELLING = new EventType<>(Event.ANY, "CANCELLING"),
            CREATING = new EventType<>(Event.ANY, "CREATING");
    protected final Type _type;
    protected final String _title, _description;
    protected final LocalDate _startDate, _endDate;
    public PlanningEvent(Type type, String title, String description, LocalDate startDate, LocalDate endDate) {
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
    public EventType<? extends PlanningEvent> getEventType() {
        return (EventType<? extends PlanningEvent>) super.getEventType();
    }
    public enum Type {
        CANCELLING, CREATING;
        public EventType<? extends Event> toEventType() {
            switch (this) {
                case CANCELLING: return PlanningEvent.CANCELLING;
                case CREATING: return PlanningEvent.CREATING;
                default: return Event.ANY;
            }
        }
    }
}
