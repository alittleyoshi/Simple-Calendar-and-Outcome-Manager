package ui.main;

import database.DatabaseManager;
import database.Plan;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.scene.control.ToggleGroup;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.VBox;
import ui.event.PlanningEvent;
import ui.main.planning.PlanAddingPane;
import ui.main.planning.TaskAddingPane;

import java.io.IOException;
import java.net.URL;
import java.time.ZoneId;
import java.util.Date;
import java.util.ResourceBundle;

public class PlanningPane extends AnchorPane implements Initializable {
    public PlanningPane() {
        FXMLLoader loader = new FXMLLoader(PlanningPane.class.getResource("/ui/main/planning pane.fxml"));
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
    private VBox _planListBox;
    @Override
    public void initialize(URL location, ResourceBundle resources) {
        flushPlanList();
    }

    @FXML
    private void onPlanAddingAction() {
        _planAddingPane.setVisible(true);
    }
    @FXML
    private void onCancellingPlanAction() {
        _planAddingPane.setVisible(false);
    }
    @FXML
    private void onCreatingPlanAction(PlanningEvent planningEvent) {
        DatabaseManager.createPlan(planningEvent.getTitle(), planningEvent.getDescription(), Date.from(planningEvent.getStartDate().atStartOfDay(ZoneId.systemDefault()).toInstant()), Date.from(planningEvent.getEndDate().atStartOfDay(ZoneId.systemDefault()).toInstant()));
        flushPlanList();
    }

    @FXML
    private void onTaskAddingAction() {
        _taskAddingPane.setVisible(true);
    }
    @FXML
    private void onCancellingTaskAction() {
        _taskAddingPane.setVisible(false);
    }
    @FXML
    private void onCreatingTaskAction(PlanningEvent planningEvent) {

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
//                _planEditingPane.setVisible(false);
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
}
