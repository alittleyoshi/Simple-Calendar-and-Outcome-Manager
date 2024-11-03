package ui.main;

import database.Plan;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.scene.control.Label;
import javafx.scene.layout.AnchorPane;

import java.io.IOException;
import java.net.URL;
import java.util.ResourceBundle;

public class PlanControl extends AnchorPane implements Initializable {
    private final Plan _plan;
    @FXML
    private Label _titleLabel, _descriptionLabel;
    public PlanControl(Plan plan) {
        _plan = plan;
        FXMLLoader loader = new FXMLLoader(PlanControl.class.getResource("/ui/main/plan scene.fxml"));
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
        _titleLabel.setText(_plan.getTitle());
        _descriptionLabel.setText(_plan.getDescription());
    }
}
