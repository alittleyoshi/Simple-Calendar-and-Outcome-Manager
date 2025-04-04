package ui.main;

import database.DatabaseManager;
import database.Plan;
import database.Task;
import database.Type;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.scene.control.ToggleGroup;
import javafx.scene.effect.GaussianBlur;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.VBox;
import resource.UIFileResource;
import ui.event.PlanningPaneEvent;
import ui.main.planning.FunctionPane;

import java.io.IOException;
import java.net.URL;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Date;
import java.util.ResourceBundle;

public class PlanListPane extends AnchorPane implements Initializable {
    public PlanListPane() {
        FXMLLoader loader = new FXMLLoader(UIFileResource.planListPaneFXML);
        loader.setRoot(this);
        loader.setController(this);
        try {
            loader.load();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
    @FXML
    private FunctionPane _functionPane;
    @FXML
    private TaskListPane _taskListPane;
    @FXML
    private VBox _planListBox;
    private ToggleGroup _planItemToggleGroup;
    @Override
    public void initialize(URL location, ResourceBundle resources) {
        _planItemToggleGroup = new ToggleGroup();
        _planItemToggleGroup.selectedToggleProperty().addListener((observable, oldValue, newValue) -> {
            if (newValue instanceof PlanItem) {
                PlanItem planItem = (PlanItem) newValue;
                _functionPane.setVisible(false);
                _taskListPane.setPlanItem(planItem);
                _taskListPane.setVisible(true);
                _taskListPane.setEffect(null);
            } else if (newValue == null) {
                _functionPane.setVisible(false);
                _taskListPane.setVisible(false);
            }
        });
        for (Plan plan : DatabaseManager.getPlans()) {
            addPlanItem(plan);
        }
    }

    @FXML
    private void onPlanAddingAction() {
        _planItemToggleGroup.selectToggle(null);
        _functionPane.setFunctionType(FunctionPane.FunctionType.Add);
        _functionPane.setInformationType(Type.Plan);
        _functionPane.setTitle("新的计划");
        _functionPane.setTitleErrorHintVisible(false);
        _functionPane.setDescription("待执行的计划");
        _functionPane.setStartDate(LocalDate.now());
        _functionPane.setEndDate(LocalDate.now());
        _functionPane.setVisible(true);
    }
    @FXML
    private void onCancellingAction() {
        _functionPane.setVisible(false);
        if (_functionPane.getInformationType() == Type.Task) {
            _taskListPane.setEffect(null);
        } else if (_functionPane.getInformationType() == Type.Plan && _functionPane.getFunctionType() == FunctionPane.FunctionType.Edit) {
            ((PlanItem) _functionPane.getUserData()).setSelected(true);
            _functionPane.setUserData(null);
        }
    }
    protected PlanItem addPlanItem(Plan plan) {
        PlanItem planItem = new PlanItem(plan);
        _planItemToggleGroup.getToggles().add(planItem);
        _planListBox.getChildren().add(planItem);
        planItem.setOnDeleted(event -> {
            _planItemToggleGroup.getToggles().remove(planItem);
            _planListBox.getChildren().remove(planItem);
            if (_functionPane.getUserData() == planItem) {
                _functionPane.setVisible(false);
                _functionPane.setUserData(null);
            }
            DatabaseManager.removePlan(plan);
        });
        planItem.setOnEditing(event -> {
            _planItemToggleGroup.selectToggle(null);
            _functionPane.setTitle(plan.getTitle());
            _functionPane.setDescription(plan.getDescription());
            _functionPane.setStartDate(LocalDate.from(plan.getStartTime().toInstant().atZone(ZoneId.systemDefault())));
            _functionPane.setEndDate(LocalDate.from(plan.getEndTime().toInstant().atZone(ZoneId.systemDefault())));
            _functionPane.setFunctionType(FunctionPane.FunctionType.Edit);
            _functionPane.setInformationType(Type.Plan);
            _functionPane.setVisible(true);
            _functionPane.setUserData(planItem);
        });
        return planItem;
    }
    @FXML
    private void onTaskAddingAction() {
        _functionPane.setFunctionType(FunctionPane.FunctionType.Add);
        _functionPane.setInformationType(Type.Task);
        _functionPane.setTitle("新的任务");
        _functionPane.setTitleErrorHintVisible(false);
        _functionPane.setDescription("待执行的任务");
        _functionPane.setStartDate(LocalDate.now());
        _functionPane.setEndDate(LocalDate.now());
        _functionPane.setVisible(true);
        _taskListPane.setEffect(new GaussianBlur(5));
    }
    @FXML
    private void onConfirmedAction(PlanningPaneEvent planningPaneEvent) {
        if (_functionPane.getFunctionType() == FunctionPane.FunctionType.Add) {
            if (_functionPane.getInformationType() == Type.Plan) {
                createdPlan(planningPaneEvent);
            } else if (_functionPane.getInformationType() == Type.Task) {
                createdTask(planningPaneEvent);
            }
        } else if (_functionPane.getFunctionType() == FunctionPane.FunctionType.Edit) {
            if (_functionPane.getInformationType() == Type.Plan) {
                editedPlan(planningPaneEvent);
            } else if (_functionPane.getInformationType() == Type.Task) {
                editedTask(planningPaneEvent);
            }
        }
    }
    private void createdPlan(PlanningPaneEvent planningPaneEvent) {
        Plan plan = DatabaseManager.createPlan(
                planningPaneEvent.getTitle(),
                planningPaneEvent.getDescription(),
                Date.from(planningPaneEvent.getStartDate().atStartOfDay(ZoneId.systemDefault()).toInstant()),
                Date.from(planningPaneEvent.getEndDate().atStartOfDay(ZoneId.systemDefault()).toInstant())
        );
        addPlanItem(plan).setSelected(true);
    }
    private void createdTask(PlanningPaneEvent planningPaneEvent) {
        Task task = DatabaseManager.createTask(
                _taskListPane.getPlanItem().getPlan(),
                planningPaneEvent.getTitle(),
                planningPaneEvent.getDescription(),
                Date.from(planningPaneEvent.getStartDate().atStartOfDay(ZoneId.systemDefault()).toInstant()),
                Date.from(planningPaneEvent.getEndDate().atStartOfDay(ZoneId.systemDefault()).toInstant())
        );
        _taskListPane.addTask(task);
        _taskListPane.setEffect(null);
        _functionPane.setVisible(false);
    }
    private void editedPlan(PlanningPaneEvent planningPaneEvent) {
        PlanItem planItem = (PlanItem) _functionPane.getUserData();
        _functionPane.setUserData(null);
        planItem.getPlan()
                .withTitle(planningPaneEvent.getTitle())
                .withDescription(planningPaneEvent.getDescription())
                .withStartTime(Date.from(planningPaneEvent.getStartDate().atStartOfDay(ZoneId.systemDefault()).toInstant()))
                .withEndTime(Date.from(planningPaneEvent.getEndDate().atStartOfDay(ZoneId.systemDefault()).toInstant()))
                .update();
        planItem.flushPlanStatus();
        planItem.setSelected(true);
    }
    private void editedTask(PlanningPaneEvent planningPaneEvent) {
        TaskItem taskItem = (TaskItem) _functionPane.getUserData();
        _functionPane.setUserData(null);
        taskItem.getTask()
                .withTitle(planningPaneEvent.getTitle())
                .withDescription(planningPaneEvent.getDescription())
                .withStartTime(Date.from(planningPaneEvent.getStartDate().atStartOfDay(ZoneId.systemDefault()).toInstant()))
                .withEndTime(Date.from(planningPaneEvent.getEndDate().atStartOfDay(ZoneId.systemDefault()).toInstant()))
                .update();
        taskItem.flushTaskStatus();
        _taskListPane.setEffect(null);
        _functionPane.setVisible(false);
    }
}
