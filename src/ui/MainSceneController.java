package ui;

import database.DatabaseManager;
import database.Plan;
import javafx.event.ActionEvent;
import javafx.event.Event;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.Parent;
import javafx.scene.control.*;
import javafx.scene.effect.GaussianBlur;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.VBox;
import ui.main.PlanControl;

import java.io.IOException;
import java.net.URL;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Date;
import java.util.ResourceBundle;

public class MainSceneController implements Initializable {
    @FXML
    private ToggleGroup _tabButtonGroup;
    @FXML
    private VBox _planListVBox;

    @Override
    public void initialize(URL location, ResourceBundle resources) {
        _tabButtonGroup.selectedToggleProperty().addListener((observable, oldValue, newValue) -> {
//            System.out.println("oldValue: " + oldValue + " oldUserData: " + oldValue.getUserData() + " newValue: " + newValue + " newUserData: " + newValue.getUserData());
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
    private Parent _tasksPane, _planAddingPane, _taskAddingPane;
    @FXML
    private void onTaskAddingAction(ActionEvent actionEvent) {
        _taskAddingPane.setVisible(true);
        _tasksPane.setEffect(new GaussianBlur(5));
        _taskAddingStartDate.setValue(LocalDate.now());
        _taskAddingEndDate.setValue(LocalDate.now());
    }
    @FXML
    private void onPlanAddingAction(MouseEvent mouseEvent) {
        _tasksPane.setVisible(false);
        _taskAddingPane.setVisible(false);
        _planAddingPane.setVisible(true);
        _planAddingStartDate.setValue(LocalDate.now());
        _planAddingEndDate.setValue(LocalDate.now());
        mouseEvent.consume();
    }
    @FXML
    private TextInputControl _taskAddingTitleText, _taskAddingDescriptionText, _planAddingTitleText, _planAddingDescriptionText;
    @FXML
    private DatePicker _taskAddingStartDate, _taskAddingEndDate, _planAddingStartDate, _planAddingEndDate;
    @FXML
    private void onCreatingTaskAction(ActionEvent actionEvent) {
    }
    @FXML
    private void onCreatingPlanAction(ActionEvent actionEvent) {
        if (_planAddingTitleText.getText().isEmpty()) {
            return;
        }
        DatabaseManager.createPlan(_planAddingTitleText.getText(), _planAddingDescriptionText.getText(), Date.from(_planAddingStartDate.getValue().atStartOfDay(ZoneId.systemDefault()).toInstant()), Date.from(_planAddingEndDate.getValue().atStartOfDay(ZoneId.systemDefault()).toInstant()));
        flushPlanList();
    }

    @FXML
    private VBox _planListBox;
    private void flushPlanList() {
        _planListBox.getChildren().clear();
        for (Plan plan : DatabaseManager.getPlans()) {
            PlanControl planControl = new PlanControl(plan);
//            planControl.setOnMouseClicked();
            _planListBox.getChildren().add(planControl);
        }
    }
}
