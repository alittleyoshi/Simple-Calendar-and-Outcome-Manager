package ui.main;

import database.Task;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.HBox;

import java.io.IOException;
import java.net.URL;
import java.util.ResourceBundle;

public class TaskItem extends AnchorPane implements Initializable {
    private final Task _task;
    public Task getTask() {
        return _task;
    }
    @FXML
    private HBox _itemHBox;
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
        _itemHBox.focusedProperty().addListener((observable, oldValue, newValue) -> {
            if (newValue) {
                System.out.println("show context" + TaskItem.this);
            } else {
                System.out.println("hide context" + TaskItem.this);
            }
        });
    }
}
