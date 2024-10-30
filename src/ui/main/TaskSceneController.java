package ui.main;

import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.HBox;

import java.net.URL;
import java.util.ResourceBundle;

public class TaskSceneController implements Initializable {
    @FXML
    private HBox _itemHBox;

    @Override
    public void initialize(URL location, ResourceBundle resources) {
        _itemHBox.focusedProperty().addListener((observable, oldValue, newValue) -> {
            if (newValue) {
                System.out.println("show context" + TaskSceneController.this);
            } else {
                System.out.println("hide context" + TaskSceneController.this);
            }
        });
    }
}
