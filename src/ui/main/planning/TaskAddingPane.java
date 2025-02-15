package ui.main.planning;

import javafx.beans.property.ObjectProperty;
import javafx.beans.property.ObjectPropertyBase;
import javafx.beans.property.StringProperty;
import javafx.event.EventHandler;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.scene.control.DatePicker;
import javafx.scene.control.TextArea;
import javafx.scene.control.TextField;
import javafx.scene.layout.AnchorPane;
import ui.event.PlanningPaneEvent;

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
    TextField _taskAddingTitleText;
    @FXML
    TextArea _taskAddingDescriptionText;
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
    public void initialize(URL location, ResourceBundle resources) {
        _taskAddingStartDate.valueProperty().addListener((observable, oldValue, newValue) -> {
            if (_taskAddingEndDate.getValue() == null || newValue.isAfter(_taskAddingEndDate.getValue())) {
                _taskAddingEndDate.setValue(newValue);
            }
        });
        _taskAddingEndDate.valueProperty().addListener((observable, oldValue, newValue) -> {
            if (newValue.isBefore(_taskAddingStartDate.getValue())) {
                _taskAddingStartDate.setValue(_taskAddingEndDate.getValue());
            }
        });
        _taskAddingStartDate.setValue(LocalDate.now());
        visibleProperty().addListener((observable, oldValue, newValue) -> {
            if (newValue) {
                _taskAddingStartDate.setValue(LocalDate.now());
            }
        });
    }
    @FXML
    public void onCancellingTaskAction() {
        fireEvent(new PlanningPaneEvent(PlanningPaneEvent.Type.CANCELLING, getTitle(), getDescription(), getStartDate(), getEndDate()));
    }
    public ObjectProperty<EventHandler<PlanningPaneEvent>> onCancellingProperty() {
        return onCancelling;
    }
    public void setOnCancelling(EventHandler<PlanningPaneEvent> value) {
        onCancellingProperty().set(value);
    }
    public EventHandler<PlanningPaneEvent> getOnCancelling() {
        return onCancellingProperty().get();
    }
    private final ObjectProperty<EventHandler<PlanningPaneEvent>> onCancelling = new ObjectPropertyBase<EventHandler<PlanningPaneEvent>>() {
        @Override
        protected void invalidated() {
            setEventHandler(PlanningPaneEvent.CANCELED, get());
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
        fireEvent(new PlanningPaneEvent(PlanningPaneEvent.Type.CREATING, getTitle(), getDescription(), getStartDate(), getEndDate()));
    }
    public ObjectProperty<EventHandler<PlanningPaneEvent>> onCreatedProperty() {
        return onCreated;
    }
    public void setOnCreated(EventHandler<PlanningPaneEvent> value) {
        onCreatedProperty().set(value);
    }
    public EventHandler<PlanningPaneEvent> getOnCreated() {
        return onCreatedProperty().get();
    }
    private final ObjectProperty<EventHandler<PlanningPaneEvent>> onCreated = new ObjectPropertyBase<EventHandler<PlanningPaneEvent>>() {
        @Override
        protected void invalidated() {
            setEventHandler(PlanningPaneEvent.CREATED, get());
        }
        @Override
        public Object getBean() {
            return TaskAddingPane.this;
        }
        @Override
        public String getName() {
            return "onCreated";
        }
    };
}
