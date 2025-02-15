package ui.main;

import database.DatabaseManager;
import database.Plan;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.scene.control.ToggleGroup;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.VBox;
import ui.event.PlanningPaneEvent;
import ui.main.planning.PlanAddingPane;
import ui.main.planning.TaskAddingPane;

import java.io.IOException;
import java.net.URL;
import java.time.ZoneId;
import java.util.Date;
import java.util.ResourceBundle;

public class PlanListPane extends AnchorPane implements Initializable {
    public PlanListPane() {
        FXMLLoader loader = new FXMLLoader(PlanListPane.class.getResource("/ui/main/plan list pane.fxml"));
        loader.setRoot(this);
        loader.setController(this);
        try {
            loader.load();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
    @FXML
    private PlanAddingPane _planAddingPane;
    @FXML
    private TaskAddingPane _taskAddingPane;
    @FXML
    private TaskListPane _taskListPane;
    @FXML
    private VBox _planListBox;
    @Override
    public void initialize(URL location, ResourceBundle resources) {
        flushPlanList();
    }

    @FXML
    private void onPlanAddingAction() {
        _planAddingPane.setVisible(true);
        _taskAddingPane.setVisible(false);
    }
    @FXML
    private void onCancellingPlanAction() {
        _planAddingPane.setVisible(false);
    }
    @FXML
    private void onCreatingPlanAction(PlanningPaneEvent planningPaneEvent) {
        DatabaseManager.createPlan(
                planningPaneEvent.getTitle(),
                planningPaneEvent.getDescription(),
                Date.from(planningPaneEvent.getStartDate().atStartOfDay(ZoneId.systemDefault()).toInstant()),
                Date.from(planningPaneEvent.getEndDate().atStartOfDay(ZoneId.systemDefault()).toInstant())
        );
        flushPlanList();
    }

    @FXML
    private void onAddingTaskAction() {
        _taskAddingPane.setVisible(true);
        _planAddingPane.setVisible(false);
    }
    @FXML
    private void onCancellingTaskAction() {
        _taskAddingPane.setVisible(false);
    }
    @FXML
    private void onCreatingTaskAction(PlanningPaneEvent planningPaneEvent) {
        DatabaseManager.createTask(
                _taskListPane.getPlan(),
                planningPaneEvent.getTitle(),
                planningPaneEvent.getDescription(),
                Date.from(planningPaneEvent.getStartDate().atStartOfDay(ZoneId.systemDefault()).toInstant()),
                Date.from(planningPaneEvent.getEndDate().atStartOfDay(ZoneId.systemDefault()).toInstant())
        );
        _taskListPane.flushTaskList();
    }

    private void flushPlanList() {
        _planListBox.getChildren().clear();
        ToggleGroup _planItemToggleGroup = new ToggleGroup();
        _planItemToggleGroup.selectedToggleProperty().addListener((observable, oldValue, newValue) -> {
            if (newValue instanceof PlanItem) {
                PlanItem planItem = (PlanItem) newValue;
//                flushTaskPane(planItem);
//                _taskPane.setEffect(null);
//                _taskPane.setVisible(true);
                _taskAddingPane.setVisible(false);
                _planAddingPane.setVisible(false);
                _taskListPane.setPlan(planItem.getPlan());
                _taskListPane.setVisible(true);
//                _planEditingPane.setVisible(false);
            } else if (newValue == null) {
                oldValue.setSelected(true);
                _taskAddingPane.setVisible(false);
                _planAddingPane.setVisible(false);
                _taskListPane.setVisible(true);
            }
        });
        for (Plan plan : DatabaseManager.getPlans()) {
            PlanItem planItem = new PlanItem(plan);
            planItem.setOnDeleted(event -> {
                DatabaseManager.removePlan(plan);
                flushPlanList();
            });
            _planItemToggleGroup.getToggles().add(planItem);
            _planListBox.getChildren().add(planItem);
        }
    }
}
