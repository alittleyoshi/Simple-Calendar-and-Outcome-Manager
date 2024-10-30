package ui;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.Parent;
import javafx.scene.control.ToggleGroup;
import javafx.scene.layout.VBox;

import java.net.URL;
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

    }

    @FXML
    private void onTaskAddingAction(ActionEvent actionEvent) {
    }
}
