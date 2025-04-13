package ui.main.planning;

import database.State;
import database.Task;
import javafx.beans.property.ObjectProperty;
import javafx.beans.property.ObjectPropertyBase;
import javafx.event.EventHandler;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.scene.Node;
import javafx.scene.control.*;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.AnchorPane;
import javafx.scene.paint.Color;
import resource.DatabaseResource;
import resource.UIFileResource;
import ui.event.planning.ItemEvent;

import java.io.IOException;
import java.net.URL;
import java.util.ResourceBundle;

public class TaskItem extends AnchorPane implements Initializable {
    private final Task _task;
    public Task getTask() {
        return _task;
    }
    @FXML
    private ToggleButton _unstartedButton, _workingButton, _completedButton;
    @FXML
    private Label _titleLabel;
    @FXML
    private TextField _titleEditingField;
    @FXML
    private ToggleGroup _statusGroup;
    public TaskItem(Task task) {
        _task = task;
        FXMLLoader loader = new FXMLLoader(UIFileResource.taskItemFXML);
        loader.setRoot(this);
        loader.setController(this);
        try {
            loader.load();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
    @Override
    public void initialize(URL location, ResourceBundle resources) {
        _titleEditingField.focusedProperty().addListener((observable, oldValue, newValue) -> {
            if (!newValue) {
                onTitleEditedAction();
            }
        });

        for (Toggle toggle : _statusGroup.getToggles()) {
            if (toggle instanceof Node) {
                Node node = (Node) toggle;
                toggle.selectedProperty().addListener((observable, oldValue, newValue) -> {
                    if (newValue) {
                        Color planStatusColor = DatabaseResource.getStatucsColor(_task.getState());
                        node.setStyle(String.format("-fx-text-fill: rgba(%f, %f, %f, %f);", planStatusColor.getRed() * 256, planStatusColor.getGreen() * 256, planStatusColor.getBlue() * 256, planStatusColor.getOpacity()));
                    } else {
                        node.setStyle(null);
                    }
                });
            }
        }
        _statusGroup.selectedToggleProperty().addListener((observable, oldValue, newValue) -> {
            if (newValue == null) {
                oldValue.setSelected(true);
            } else {
                State state;
                if (newValue == _unstartedButton) {
                    state = State.Unstarted;
                } else if (newValue == _workingButton) {
                    state = State.Working;
                } else if (newValue == _completedButton) {
                    state = State.Completed;
                } else {
                    state = State.Unknown;
                }
                setState(state);
            }
        });
        flushTaskStatus();
    }

    protected void flushTaskStatus() {
        setState(_task.getState());
        _titleLabel.setText(_task.getTitle());
    }

    private ObjectProperty<State> state;
    public State getState() {
        return state == null ? State.Unknown : stateProperty().get();
    }
    public void setState(State state) {
        stateProperty().set(state);
    }
    public ObjectProperty<State> stateProperty() {
        if (state == null) {
            state = new ObjectPropertyBase<State>() {
                @Override
                protected void invalidated() {
                    _task.withState(get());
                    _task.update();
                    switch (get()) {
                        case Unstarted: {
                            _unstartedButton.setSelected(true);
                            break;
                        }
                        case Working: {
                            _workingButton.setSelected(true);
                            break;
                        }
                        case Completed: {
                            _completedButton.setSelected(true);
                            break;
                        }
                        default: {
                            break;
                        }
                    }
                }
                @Override
                public Object getBean() {
                    return TaskItem.this;
                }
                @Override
                public String getName() {
                    return "state";
                }
            };
        }
        return state;
    }
    @FXML
    private void onTitleLabelClicked(MouseEvent mouseEvent) {
        if (mouseEvent.getClickCount() >= 2) {
            onTitleEditingAction();
        }
    }
    @FXML
    private void onTitleEditingAction() {
        _titleEditingField.setText(_task.getTitle());
        _titleEditingField.setVisible(true);
        _titleEditingField.requestFocus();
    }
    @FXML
    private void onTitleEditedAction() {
        if (_titleEditingField.getText().trim().isEmpty()) {
            _titleEditingField.setText(_task.getTitle());
        }
        _titleEditingField.setVisible(false);
        _task.withTitle(_titleEditingField.getText().trim());
        _task.update();
        _titleLabel.setText(_task.getTitle());
    }
    @FXML
    private void onEditingAction() {
        fireEvent(new ItemEvent(ItemEvent.Type.EDITING));
    }
    @FXML

    protected ObjectProperty<EventHandler<ItemEvent>> onEditing;
    public ObjectProperty<EventHandler<ItemEvent>> onEditingProperty() {
        if (onEditing == null) {
            onEditing = new ObjectPropertyBase<EventHandler<ItemEvent>>() {
                @Override
                protected void invalidated() {
                    setEventHandler(ItemEvent.EDITING, get());
                }
                @Override
                public Object getBean() {
                    return TaskItem.this;
                }
                @Override
                public String getName() {
                    return "onEditing";
                }
            };
        }
        return onEditing;
    }
    public EventHandler<ItemEvent> getOnEditing() {
        return onEditing == null ? null : onEditingProperty().get();
    }
    public void setOnEditing(EventHandler<ItemEvent> value) {
        onEditingProperty().set(value);
    }

    private void onDeletingAction() {
        fireEvent(new ItemEvent(ItemEvent.Type.DELETED));
    }

    protected ObjectProperty<EventHandler<ItemEvent>> onDeleted;
    public ObjectProperty<EventHandler<ItemEvent>> onDeletedProperty() {
        if (onDeleted == null) {
            onDeleted = new ObjectPropertyBase<EventHandler<ItemEvent>>() {
                @Override
                protected void invalidated() {
                    setEventHandler(ItemEvent.DELETED, get());
                }
                @Override
                public Object getBean() {
                    return TaskItem.this;
                }
                @Override
                public String getName() {
                    return "onDeleted";
                }
            };
        }
        return onDeleted;
    }
    public EventHandler<ItemEvent> getOnDeleted() {
        return onDeleted == null ? null : onDeletedProperty().get();
    }
    public void setOnDeleted(EventHandler<ItemEvent> value) {
        onDeletedProperty().set(value);
    }
}
