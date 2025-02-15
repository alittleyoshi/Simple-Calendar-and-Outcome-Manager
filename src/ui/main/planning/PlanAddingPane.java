package ui.main.planning;

import javafx.beans.property.*;
import javafx.event.EventHandler;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.scene.control.DatePicker;
import javafx.scene.control.Label;
import javafx.scene.control.TextArea;
import javafx.scene.control.TextField;
import javafx.scene.layout.AnchorPane;
import ui.event.PlanningPaneEvent;

import java.io.IOException;
import java.net.URL;
import java.time.LocalDate;
import java.util.ResourceBundle;

public class PlanAddingPane extends AnchorPane implements Initializable {
    public PlanAddingPane() {
        FXMLLoader loader = new FXMLLoader(PlanAddingPane.class.getResource("plan adding pane.fxml"));
        loader.setRoot(this);
        loader.setController(this);
        try {
            loader.load();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    @FXML
    TextField _planAddingTitleText;
    @FXML
    TextArea _planAddingDescriptionText;
    @FXML
    DatePicker _planAddingStartDate, _planAddingEndDate;
    @FXML
    Label _planAddingTitleErrorHintLabel;

    public StringProperty titleProperty() {
        if (title == null) {
            title = _planAddingTitleText.textProperty();
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
            description = _planAddingDescriptionText.textProperty();
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
        if (startDate == null) {
            startDate = _planAddingStartDate.valueProperty();
            startDate.addListener((observable, oldValue, newValue) -> {
                if (getEndDate() == null || newValue.isAfter(getEndDate())) {
                    setEndDate(newValue);
                }
            });
        }
        return startDate;
    }
    public void setStartDate(LocalDate startDate) {
        startDateProperty().set(startDate);
    }
    public LocalDate getStartDate() {
        return startDateProperty().get();
    }
    private ObjectProperty<LocalDate> startDate;

    public ObjectProperty<LocalDate> endDateProperty() {
        if (endDate == null) {
            endDate = _planAddingEndDate.valueProperty();
            endDate.addListener((observable, oldValue, newValue) -> {
                if (getStartDate() == null || newValue.isBefore(getStartDate())) {
                    setStartDate(newValue);
                }
            });
        }
        return endDate;
    }
    public void setEndDate(LocalDate endDate) {
        endDateProperty().set(endDate);
    }
    public LocalDate getEndDate() {
        return endDateProperty().get();
    }
    private ObjectProperty<LocalDate> endDate;

    public BooleanProperty titleErrorHintVisibleProperty() {
        if (titleErrorHintVisible == null) {
            titleErrorHintVisible = new SimpleBooleanProperty(PlanAddingPane.this, "titleErrorHintVisible", false);
            _planAddingTitleErrorHintLabel.visibleProperty().bind(titleErrorHintVisible);
        }
        return titleErrorHintVisible;
    }
    public void setTitleErrorHintVisible(boolean titleErrorHintVisible) {
        titleErrorHintVisibleProperty().set(titleErrorHintVisible);
    }
    public boolean getTitleErrorHintVisible() {
        return titleErrorHintVisibleProperty().get();
    }
    private BooleanProperty titleErrorHintVisible;

    @Override
    public void initialize(URL location, ResourceBundle resources) {
        _planAddingStartDate.valueProperty().addListener((observable, oldValue, newValue) -> {
            if (_planAddingEndDate.getValue() == null || newValue.isAfter(_planAddingEndDate.getValue())) {
                _planAddingEndDate.setValue(newValue);
            }
        });
        _planAddingEndDate.valueProperty().addListener((observable, oldValue, newValue) -> {
            if (newValue.isBefore(_planAddingStartDate.getValue())) {
                _planAddingStartDate.setValue(_planAddingEndDate.getValue());
            }
        });
        _planAddingStartDate.setValue(LocalDate.now());
        visibleProperty().addListener((observable, oldValue, newValue) -> {
            if (newValue) {
                _planAddingStartDate.setValue(LocalDate.now());
            }
        });
    }
    @FXML
    private void onCancellingPlanAction() {
        fireEvent(new PlanningPaneEvent(PlanningPaneEvent.Type.CANCELLING, getTitle(), getDescription(), getStartDate(), getEndDate()));
    }
    public ObjectProperty<EventHandler<PlanningPaneEvent>> onCancellingProperty() {
        return onCancelling;
    }
    public void setOnCancelling(final EventHandler<PlanningPaneEvent> value) {
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
            return PlanAddingPane.this;
        }
        @Override
        public String getName() {
            return "onCancelling";
        }
    };
    @FXML
    private void onCreatingPlanAction() {
        if (getTitle().isEmpty()) {
            setTitleErrorHintVisible(true);
            return;
        } else {
            setTitleErrorHintVisible(false);
        }
        fireEvent(new PlanningPaneEvent(PlanningPaneEvent.Type.CREATING, getTitle(), getDescription(), getStartDate(), getEndDate()));
    }
    public ObjectProperty<EventHandler<PlanningPaneEvent>> onCreatingProperty() {
        return onCreating;
    }
    public void setOnCreating(final EventHandler<PlanningPaneEvent> value) {
        onCreatingProperty().set(value);
    }
    public EventHandler<PlanningPaneEvent> getOnCreating() {
        return onCreatingProperty().get();
    }
    private final ObjectProperty<EventHandler<PlanningPaneEvent>> onCreating = new ObjectPropertyBase<EventHandler<PlanningPaneEvent>>() {
        @Override
        protected void invalidated() {
            setEventHandler(PlanningPaneEvent.CREATED, get());
        }
        @Override
        public Object getBean() {
            return PlanAddingPane.this;
        }
        @Override
        public String getName() {
            return "onCreating";
        }
    };
}
