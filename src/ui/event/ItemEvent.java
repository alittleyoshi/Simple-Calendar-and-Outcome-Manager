package ui.event;

import javafx.event.Event;
import javafx.event.EventType;

public class ItemEvent extends Event {
    public static final EventType<ItemEvent>
            DELETED = new EventType<>(Event.ANY, "DELETED"),
            EDITING = new EventType<>(Event.ANY, "EDITING"),
            CHANGED = new EventType<>(Event.ANY, "CHANGED");
    public ItemEvent(Type type) {
        super(type.toEventType());
    }
    public enum Type {
        DELETED,
        EDITING,
        CHANGED;
        public EventType<? extends Event> toEventType() {
            switch (this) {
                case DELETED: return ItemEvent.DELETED;
                case EDITING: return ItemEvent.EDITING;
                case CHANGED: return ItemEvent.CHANGED;
                default: return Event.ANY;
            }
        }
    }
}
