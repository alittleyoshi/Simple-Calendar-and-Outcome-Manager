package ui.main;

import database.DatabaseManager;
import database.Task;
import javafx.beans.property.ObjectProperty;
import javafx.beans.property.ObjectPropertyBase;
import javafx.event.EventHandler;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.scene.control.Label;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.VBox;
import resource.UIFileResource;
import ui.event.TaskListEvent;

import java.net.URL;
import java.util.ResourceBundle;

public class TaskListPane extends AnchorPane implements Initializable {
    @FXML
    private Label _planTitleLabel;
    protected ObjectProperty<PlanItem> planItem;
    public ObjectProperty<PlanItem> planItemProperty() {
        if (planItem == null) {
            planItem = new ObjectPropertyBase<PlanItem>() {
                @Override
                protected void invalidated() {
                    flushTaskList();
                    _planTitleLabel.setText(get().getTitle());
                }
                @Override
                public Object getBean() {
                    return TaskListPane.this;
                }
                @Override
                public String getName() {
                    return "planItem";
                }
            };
        }
        return planItem;
    }
    public PlanItem getPlanItem() {
        return planItemProperty().get();
    }
    public void setPlanItem(PlanItem planItem) {
        planItemProperty().set(planItem);
    }
    @FXML
    private VBox _planTasksBox;
    public TaskListPane() {
        FXMLLoader fxmlLoader = new FXMLLoader(UIFileResource.taskListPaneFXML);
        fxmlLoader.setRoot(this);
        fxmlLoader.setController(this);
        try {
            fxmlLoader.load();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
    @Override
    public void initialize(URL location, ResourceBundle resources) {
        flushTaskList();
    }

    protected void flushTaskList() {
        _planTasksBox.getChildren().clear();
        if (getPlanItem() == null) {
            return;
        }
        for (Task task : getPlanItem().getPlan().getTasks()) {
            addTask(task);
        }
    }
    protected TaskItem addTask(Task task) {
        TaskItem taskItem = new TaskItem(task);
        taskItem.stateProperty().addListener(observable -> getPlanItem().flushPlanStatus());
        taskItem.setOnDeleted(event -> {
            _planTasksBox.getChildren().remove(taskItem);
            DatabaseManager.removeTask(task);
            getPlanItem().flushPlanStatus();
        });
        _planTasksBox.getChildren().add(taskItem);
        return taskItem;
    }

    @FXML
    private void onTaskAddingAction() {
        fireEvent(new TaskListEvent(TaskListEvent.Type.ADDING));
    }

    protected ObjectProperty<EventHandler<TaskListEvent>> onAdding;
    public final ObjectProperty<EventHandler<TaskListEvent>> onAddingProperty() {
        if (onAdding == null) {
            onAdding = new ObjectPropertyBase<EventHandler<TaskListEvent>>() {
                @Override
                protected void invalidated() {
                    setEventHandler(TaskListEvent.ADDING, get());
                }
                @Override
                public Object getBean() {
                    return TaskListPane.this;
                }
                @Override
                public String getName() {
                    return "onAdding";
                }
            };
        }
        return onAdding;
    }
    public final void setOnAdding(EventHandler<TaskListEvent> value) {
        onAddingProperty().set(value);
    }
    public final EventHandler<TaskListEvent> getOnAdding() {
        return onAddingProperty().get();
    }
}
