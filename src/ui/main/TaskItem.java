package ui.main;

import database.DatabaseManager;
import database.Status;
import database.Task;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.scene.Node;
import javafx.scene.Parent;
import javafx.scene.control.*;
import javafx.scene.input.MouseButton;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.HBox;
import javafx.scene.paint.Color;
import resource.DatabaseResource;

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
        FXMLLoader loader = new FXMLLoader(TaskItem.class.getResource("/ui/main/task scene.fxml"));
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
        _titleLabel.setText(_task.getTitle());
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
                        Color planStatusColor = DatabaseResource.getStatucsColor(_task.getStatus());
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
                Status status;
                if (newValue == _unstartedButton) {
                    status = Status.Unstarted;
                } else if (newValue == _workingButton) {
                    status = Status.Working;
                } else if (newValue == _completedButton) {
                    status = Status.Completed;
                } else {
                    status = Status.Unknown;
                }
                _task.setStatus(status);
            }
        });
        switch (_task.getStatus()) {
            case Working: {
                _workingButton.setSelected(true);
                break;
            }
            case Completed: {
                _completedButton.setSelected(true);
                break;
            }
            default: {
                _unstartedButton.setSelected(true);
                break;
            }
        }
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
        _task.setTitle(_titleEditingField.getText().trim());
        _titleLabel.setText(_task.getTitle());
    }
    @FXML
    private void onTaskDeletingAction() {
        DatabaseManager.removeTask(_task);
    }
}
