package ui.main.planning;

import database.Type;
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
import resource.UIFileResource;
import ui.event.PlanningPaneEvent;

import java.io.IOException;
import java.net.URL;
import java.time.LocalDate;
import java.util.ResourceBundle;

public class FunctionPane extends AnchorPane implements Initializable {
    public FunctionPane() {
        FXMLLoader loader = new FXMLLoader(UIFileResource.functionPaneFXML);
        loader.setRoot(this);
        loader.setController(this);
        try {
            loader.load();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
    @FXML
    private TextField _titleText;
    @FXML
    private TextArea _descriptionText;
    @FXML
    private DatePicker _startDate, _endDate;
    @FXML
    private Label _functionLabel, _typeLabel, _titleErrorHintLabel;

    public ObjectProperty<FunctionType> functionTypeProperty() {
        if (functionType == null) {
            functionType = new ObjectPropertyBase<FunctionType>() {
                {
                    set(FunctionType.Unknown);
                }
                @Override
                protected void invalidated() {
                    final FunctionType t = get();
                    if (get() == null) {
                        set(FunctionType.Unknown);
                    } else {
                        switch(t) {
                            case Add: {
                                _functionLabel.setText("添加");
                                break;
                            }
                            case Edit: {
                                _functionLabel.setText("编辑");
                                break;
                            }
                            default: {
                                _functionLabel.setText("");
                                break;
                            }
                        }
                    }
                }
                @Override
                public Object getBean() {
                    return FunctionPane.this;
                }
                @Override
                public String getName() {
                    return "functionType";
                }
            };
        }
        return functionType;
    }
    public FunctionType getFunctionType() {
        return functionType == null ? FunctionType.Unknown : functionTypeProperty().get();
    }
    public void setFunctionType(FunctionType type) {
        functionTypeProperty().set(type);
    }
    protected ObjectProperty<FunctionType> functionType;

    public ObjectProperty<Type> informationTypeProperty() {
        if (informationType == null) {
            informationType = new ObjectPropertyBase<Type>() {
                {
                    set(Type.Unknown);
                }
                @Override
                protected void invalidated() {
                    final Type t = get();
                    if (get() == null) {
                        set(Type.Unknown);
                    } else {
                        switch(t) {
                            case Plan: {
                                _typeLabel.setText("计划");
                                break;
                            }
                            case Task: {
                                _typeLabel.setText("任务");
                                break;
                            }
                            default: {
                                _typeLabel.setText("");
                                break;
                            }
                        }
                    }
                }
                @Override
                public Object getBean() {
                    return FunctionPane.this;
                }
                @Override
                public String getName() {
                    return "informationType";
                }
            };
        }
        return informationType;
    }
    public Type getInformationType() {
        return informationType == null ? Type.Unknown : informationTypeProperty().get();
    }
    public void setInformationType(Type type) {
        informationTypeProperty().set(type);
    }
    protected ObjectProperty<Type> informationType;

    public StringProperty titleProperty() {
        if (title == null) {
            title = new StringPropertyBase() {
                {
                    set(_titleText.getText());
                    _titleText.textProperty().addListener((observable, oldValue, newValue) -> {
                        if (!newValue.equals(getTitle())) {
                            set(newValue);
                        }
                    });
                }
                @Override
                protected void invalidated() {
                    if (!_titleText.getText().equals(get())) {
                        _titleText.setText(get());
                    }
                }
                @Override
                public Object getBean() {
                    return FunctionPane.this;
                }
                @Override
                public String getName() {
                    return "description";
                }
            };
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
            description = new StringPropertyBase() {
                {
                    set(_descriptionText.getText());
                    _descriptionText.textProperty().addListener((observable, oldValue, newValue) -> {
                        if (!newValue.equals(getDescription())) {
                            set(newValue);
                        }
                    });
                }
                @Override
                protected void invalidated() {
                    if (!_descriptionText.getText().equals(get())) {
                        _descriptionText.setText(get());
                    }
                }
                @Override
                public Object getBean() {
                    return FunctionPane.this;
                }
                @Override
                public String getName() {
                    return "description";
                }
            };
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
            startDate = new ObjectPropertyBase<LocalDate>() {
                {
                    set(_startDate.getValue());
                    _startDate.valueProperty().addListener((observable, oldValue, newValue) -> {
                        final LocalDate ld = get(), sd = _startDate.getValue();
                        if (sd == null ? ld != null : (ld == null || !sd.isEqual(ld))) {
                            set(sd);
                        }
                    });
                }
                @Override
                protected void invalidated() {
                    final LocalDate ld = get(), sd = _startDate.getValue();
                    if (ld == null ? sd != null : (sd == null || !ld.isEqual(sd))) {
                        _startDate.setValue(ld);
                    }
                }
                @Override
                public Object getBean() {
                    return FunctionPane.this;
                }
                @Override
                public String getName() {
                    return "startDate";
                }
            };
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
            endDate = new ObjectPropertyBase<LocalDate>() {
                {
                    set(_endDate.getValue());
                    _endDate.valueProperty().addListener((observable, oldValue, newValue) -> {
                        final LocalDate ld = get(), ed = _endDate.getValue();
                        if (ed == null ? ld != null : (ld == null || !ed.isEqual(ld))) {
                            set(ed);
                        }
                    });
                }
                @Override
                protected void invalidated() {
                    final LocalDate ld = get(), ed = _endDate.getValue();
                    if (ld == null ? ed != null : (ed == null || !ld.isEqual(ed))) {
                        _endDate.setValue(ld);
                    }
                }
                @Override
                public Object getBean() {
                    return FunctionPane.this;
                }
                @Override
                public String getName() {
                    return "endDate";
                }
            };
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

    @Override
    public void initialize(URL location, ResourceBundle resources) {}

    public BooleanProperty titleErrorHintVisibleProperty() {
        if (titleErrorHintVisible == null) {
            titleErrorHintVisible = new SimpleBooleanProperty(this, "titleErrorHintVisible", false);
            _titleErrorHintLabel.visibleProperty().bind(titleErrorHintVisible);
        }
        return titleErrorHintVisible;
    }
    public void setTitleErrorHintVisible(boolean titleErrorHintVisible) {
        titleErrorHintVisibleProperty().set(titleErrorHintVisible);
    }
    public boolean getTitleErrorHintVisible() {
        return titleErrorHintVisible != null && titleErrorHintVisibleProperty().get();
    }
    private BooleanProperty titleErrorHintVisible;

    @FXML
    public void onCancellingAction() {
        fireEvent(new PlanningPaneEvent(PlanningPaneEvent.Type.CANCELLING, getTitle(), getDescription(), getStartDate(), getEndDate()));
    }
    public ObjectProperty<EventHandler<PlanningPaneEvent>> onCancellingProperty() {
        if (onCancelling == null) {
            onCancelling = new ObjectPropertyBase<EventHandler<PlanningPaneEvent>>() {
                @Override
                protected void invalidated() {
                    setEventHandler(PlanningPaneEvent.CANCELED, get());
                }
                @Override
                public Object getBean() {
                    return FunctionPane.this;
                }
                @Override
                public String getName() {
                    return "onCancelling";
                }
            };
        }
        return onCancelling;
    }
    public void setOnCancelling(EventHandler<PlanningPaneEvent> value) {
        onCancellingProperty().set(value);
    }
    public EventHandler<PlanningPaneEvent> getOnCancelling() {
        return onCancelling == null ? null : onCancellingProperty().get();
    }
    private ObjectProperty<EventHandler<PlanningPaneEvent>> onCancelling;
    @FXML
    public void onConfirmedAction() {
        if (getTitle().isEmpty()) {
            setTitleErrorHintVisible(true);
        } else {
            setTitleErrorHintVisible(false);
            fireEvent(new PlanningPaneEvent(PlanningPaneEvent.Type.CONFIRMED, getTitle(), getDescription(), getStartDate(), getEndDate()));
        }
    }
    private ObjectProperty<EventHandler<PlanningPaneEvent>> onConfirmed;
    public ObjectProperty<EventHandler<PlanningPaneEvent>> onConfirmedProperty() {
        if (onConfirmed == null) {
            onConfirmed = new ObjectPropertyBase<EventHandler<PlanningPaneEvent>>() {
                @Override
                protected void invalidated() {
                    setEventHandler(PlanningPaneEvent.CONFIRMED, get());
                }
                @Override
                public Object getBean() {
                    return FunctionPane.this;
                }
                @Override
                public String getName() {
                    return "onCreated";
                }
            };
        }
        return onConfirmed;
    }
    public void setOnConfirmed(EventHandler<PlanningPaneEvent> value) {
        onConfirmedProperty().set(value);
    }
    public EventHandler<PlanningPaneEvent> getOnConfirmed() {
        return onConfirmed == null ? null : onConfirmedProperty().get();
    }

    public enum FunctionType {
        Unknown, Add, Edit
    }
}
