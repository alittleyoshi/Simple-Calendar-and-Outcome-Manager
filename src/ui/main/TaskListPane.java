package ui.main;

import database.Plan;
import database.Task;
import javafx.beans.property.ObjectProperty;
import javafx.beans.property.ObjectPropertyBase;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.VBox;
import ui.event.TaskListEvent;

import java.net.URL;
import java.util.ResourceBundle;

public class TaskListPane extends AnchorPane implements Initializable {
    protected ObjectProperty<Plan> plan = new ObjectPropertyBase<Plan>() {
        @Override
        protected void invalidated() {
            flushTaskList();
        }
        @Override
        public Object getBean() {
            return TaskListPane.this;
        }
        @Override
        public String getName() {
            return "plan";
        }
    };;
    public ObjectProperty<Plan> planProperty() {
        return plan;
    }
    public Plan getPlan() {
        return planProperty().get();
    }
    public void setPlan(Plan plan) {
        planProperty().set(plan);
    }
    @FXML
    private VBox _planTasksBox;
    public TaskListPane() {
        FXMLLoader fxmlLoader = new FXMLLoader(TaskListPane.class.getResource("/ui/main/task list pane.fxml"));
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
        if (getPlan() == null) {
            return;
        }
        for (Task task : getPlan().getTasks()) {
            TaskItem taskItem = new TaskItem(task);
            _planTasksBox.getChildren().add(taskItem);
        }
    }

    @FXML
    private void onTaskAddingAction() {
        fireEvent(new TaskListEvent(TaskListEvent.Type.ADDING));
    }
    protected final ObjectProperty<EventHandler<TaskListEvent>> onAdding = new ObjectPropertyBase<EventHandler<TaskListEvent>>() {
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
    public final ObjectProperty<EventHandler<TaskListEvent>> onAddingProperty() {
        return onAdding;
    }
    public final void setOnAdding(EventHandler<TaskListEvent> value) {
        onAddingProperty().set(value);
    }
    public final EventHandler<TaskListEvent> getOnAdding() {
        return onAddingProperty().get();
    }
}
