package ui;

import database.DatabaseManager;
import database.Plan;
import database.Task;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.Parent;
import javafx.scene.control.*;
import javafx.scene.effect.GaussianBlur;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.Pane;
import javafx.scene.layout.VBox;
import ui.main.PlanItem;
import ui.main.TaskItem;

import java.net.URL;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Date;
import java.util.ResourceBundle;

public class MainSceneController implements Initializable {
    @FXML
    private ToggleGroup _tabButtonGroup;
    @Override
    public void initialize(URL location, ResourceBundle resources) {
        _tabButtonGroup.selectedToggleProperty().addListener((observable, oldValue, newValue) -> {
            if (newValue == null) {
                oldValue.setSelected(true);
            } else {
                if (oldValue != null) {
                    ((Parent) oldValue.getUserData()).setVisible(false);
                }
                ((Parent) newValue.getUserData()).setVisible(true);
            }
        });

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

        flushPlanList();
    }

    @FXML
    private Pane _taskPane, _planAddingPane, _taskAddingPane, _planEditingPane;
    @FXML
    private void onTaskAddingAction(ActionEvent actionEvent) {
        _taskAddingPane.setVisible(true);
        _taskPane.setEffect(new GaussianBlur(5));
        _taskAddingStartDate.setValue(LocalDate.now());
        _taskAddingEndDate.setValue(LocalDate.now());
    }
    @FXML
    private void onPlanAddingAction(MouseEvent mouseEvent) {
        _taskPane.setVisible(false);
        _taskAddingPane.setVisible(false);
        _planAddingPane.setVisible(true);
        _planEditingPane.setVisible(false);
        _planAddingStartDate.setValue(LocalDate.now());
        _planAddingEndDate.setValue(LocalDate.now());
        mouseEvent.consume();
    }
    @FXML
    private TextInputControl _taskAddingTitleText, _taskAddingDescriptionText, _planAddingTitleText, _planAddingDescriptionText;
    @FXML
    private DatePicker _taskAddingStartDate, _taskAddingEndDate, _planAddingStartDate, _planAddingEndDate;
    @FXML
    private Label _planAddingTitleErrorHintLabel;
    @FXML
    private void onCreatingTaskAction() {
        if (_taskAddingTitleText.getText().isEmpty()) {
            return;
        }
        DatabaseManager.createTask(((PlanItem)_taskPane.getUserData()).getPlan(), _taskAddingTitleText.getText(), _taskAddingDescriptionText.getText(), Date.from(_taskAddingStartDate.getValue().atStartOfDay(ZoneId.systemDefault()).toInstant()), Date.from(_taskAddingEndDate.getValue().atStartOfDay(ZoneId.systemDefault()).toInstant()));
        flushTaskPane((PlanItem) _taskPane.getUserData());
        flushPlanList();
    }
    @FXML
    private void onCreatingPlanAction() {
        if (_planAddingTitleText.getText().isEmpty()) {
            _planAddingTitleErrorHintLabel.setVisible(true);
            return;
        } else {
            _planAddingTitleErrorHintLabel.setVisible(false);
        }
        DatabaseManager.createPlan(_planAddingTitleText.getText(), _planAddingDescriptionText.getText(), Date.from(_planAddingStartDate.getValue().atStartOfDay(ZoneId.systemDefault()).toInstant()), Date.from(_planAddingEndDate.getValue().atStartOfDay(ZoneId.systemDefault()).toInstant()));
        flushPlanList();
    }
    @FXML
    private void onEditedPlanAction() {
    }
    @FXML
    public void onCancellingTaskAction() {
        _taskPane.setEffect(null);
        _taskAddingPane.setVisible(false);
    }
    @FXML
    public void onCancellingPlanAction() {
        _planAddingPane.setVisible(false);
        _planEditingPane.setVisible(false);
    }

    @FXML
    private VBox _planListBox;
    private void flushPlanList() {
        _planListBox.getChildren().clear();
        ToggleGroup _planItemToggleGroup = new ToggleGroup();
        _planItemToggleGroup.selectedToggleProperty().addListener((observable, oldValue, newValue) -> {
            if (newValue instanceof PlanItem) {
                PlanItem planItem = (PlanItem) newValue;
                flushTaskPane(planItem);
                _taskPane.setEffect(null);
                _taskPane.setVisible(true);
                _taskAddingPane.setVisible(false);
                _planAddingPane.setVisible(false);
                _planEditingPane.setVisible(false);
            } else if (newValue == null) {
                oldValue.setSelected(true);
            }
        });
        for (Plan plan : DatabaseManager.getPlans()) {
            PlanItem planItem = new PlanItem(plan);
            _planItemToggleGroup.getToggles().add(planItem);
            _planListBox.getChildren().add(planItem);
        }
    }
    @FXML
    private Label _planTitleLabel;
    @FXML
    private VBox _planTasksBox;
    private void flushTaskPane(PlanItem planItem) {
        _taskPane.setUserData(planItem);
        Plan plan = planItem.getPlan();
        _planTitleLabel.textProperty().bind(planItem.titleProperty());
        _planTasksBox.getChildren().clear();
        for (Task task : plan.getTasks()) {
            TaskItem taskItem = new TaskItem(task);
            taskItem.statusProperty().addListener((observable, oldValue, newValue) -> {
                planItem.flushPlanStatus();
            });
            _planTasksBox.getChildren().add(taskItem);
        }
    }

}
