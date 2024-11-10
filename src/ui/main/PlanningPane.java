package ui.main;

import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.scene.layout.AnchorPane;
import ui.main.planning.PlanAddingPane;

import java.io.IOException;
import java.net.URL;
import java.util.ResourceBundle;

public class PlanningPane extends AnchorPane implements Initializable {
    public PlanningPane() {
        FXMLLoader loader = new FXMLLoader(PlanningPane.class.getResource("planning pane.fxml"));
        loader.setRoot(this);
        loader.setController(this);
        try {
            loader.load();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
    @FXML
    PlanAddingPane _planAddingPane;
    @Override
    public void initialize(URL location, ResourceBundle resources) {

    }
    @FXML
    private void onPlanAddingAction() {

    }
    @FXML
    private void onCancellingPlanAction() {

    }
    @FXML
    private void onCreatingPlanAction() {

    }
}
