package ui.main.planning;

import javafx.beans.property.ObjectProperty;
import javafx.beans.property.ObjectPropertyBase;
import javafx.beans.property.StringProperty;
import javafx.event.EventHandler;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.scene.control.DatePicker;
import javafx.scene.control.TextField;
import javafx.scene.layout.AnchorPane;
import ui.event.PlanningEvent;

import java.io.IOException;
import java.net.URL;
import java.time.LocalDate;
import java.util.ResourceBundle;

public class TaskAddingPane extends AnchorPane implements Initializable {
    public TaskAddingPane() {
        FXMLLoader loader = new FXMLLoader(TaskAddingPane.class.getResource("task adding pane.fxml"));
        loader.setRoot(this);
        loader.setController(this);
        try {
            loader.load();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
    @FXML
    TextField _taskAddingTitleText, _taskAddingDescriptionText;
    @FXML
    DatePicker _taskAddingStartDate, _taskAddingEndDate;

    public StringProperty titleProperty() {
        if (title == null) {
            title = _taskAddingTitleText.textProperty();
        }
        return title;
    }
    public void setTitle(String title) {
        titleProperty().set(title);
    }
    public String getTitle() {
        return titleProperty().get();
    }
    private StringProperty title;

    public StringProperty descriptionProperty() {
        if (description == null) {
            description = _taskAddingDescriptionText.textProperty();
        }
        return description;
    }
    public void setDescription(String description) {
        descriptionProperty().set(description);
    }
    public String getDescription() {
        return descriptionProperty().get();
    }
    private StringProperty description;

    public ObjectProperty<LocalDate> startDateProperty() {
        if (startDateProperty == null) {
            startDateProperty = _taskAddingStartDate.valueProperty();
            startDateProperty.addListener((observable, oldValue, newValue) -> {
                if (getEndDate() == null || newValue.isAfter(getEndDate())) {
                    setEndDate(newValue);
                }
            });
        }
        return startDateProperty;
    }
    public void setStartDate(LocalDate startDate) {
        startDateProperty().set(startDate);
    }
    public LocalDate getStartDate() {
        return startDateProperty().get();
    }
    private ObjectProperty<LocalDate> startDateProperty;

    public ObjectProperty<LocalDate> endDateProperty() {
        if (endDateProperty == null) {
            endDateProperty = _taskAddingEndDate.valueProperty();
            endDateProperty.addListener((observable, oldValue, newValue) -> {
                if (getStartDate() == null || newValue.isBefore(getStartDate())) {
                    setStartDate(newValue);
                }
            });
        }
        return endDateProperty;
    }
    public void setEndDate(LocalDate endDate) {
        endDateProperty().set(endDate);
    }
    public LocalDate getEndDate() {
        return endDateProperty().get();
    }
    private ObjectProperty<LocalDate> endDateProperty;

    @Override
    public void initialize(URL location, ResourceBundle resources) {}
    @FXML
    public void onCancellingTaskAction() {
        fireEvent(new PlanningEvent(PlanningEvent.CANCELLING));
    }
    public ObjectProperty<EventHandler<PlanningEvent>> onCancellingProperty() {
        return onCancelling;
    }
    public void setOnCancelling(EventHandler<PlanningEvent> value) {
        onCancellingProperty().set(value);
    }
    public EventHandler<PlanningEvent> getOnCancelling() {
        return onCancellingProperty().get();
    }
    private final ObjectProperty<EventHandler<PlanningEvent>> onCancelling = new ObjectPropertyBase<EventHandler<PlanningEvent>>() {
        @Override
        protected void invalidated() {
            setEventHandler(PlanningEvent.CANCELLING, get());
        }
        @Override
        public Object getBean() {
            return TaskAddingPane.this;
        }
        @Override
        public String getName() {
            return "onCancelling";
        }
    };
    @FXML
    public void onCreatingTaskAction() {
        fireEvent(new PlanningEvent(PlanningEvent.CREATING));
    }
    public ObjectProperty<EventHandler<PlanningEvent>> onCreatingProperty() {
        return onCreating;
    }
    public void setOnCreating(EventHandler<PlanningEvent> value) {
        onCreatingProperty().set(value);
    }
    public EventHandler<PlanningEvent> getOnCreating() {
        return onCreatingProperty().get();
    }
    private final ObjectProperty<EventHandler<PlanningEvent>> onCreating = new ObjectPropertyBase<EventHandler<PlanningEvent>>() {
        @Override
        protected void invalidated() {
            setEventHandler(PlanningEvent.CREATING, get());
        }
        @Override
        public Object getBean() {
            return TaskAddingPane.this;
        }
        @Override
        public String getName() {
            return "onCreating";
        }
    };
}
