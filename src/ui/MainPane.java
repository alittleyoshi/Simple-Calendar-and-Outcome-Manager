package ui;

import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.scene.Parent;
import javafx.scene.control.ToggleButton;
import javafx.scene.control.ToggleGroup;
import javafx.scene.layout.AnchorPane;
import resource.UIFileResource;

import java.io.IOException;
import java.net.URL;
import java.util.ResourceBundle;

public class MainPane extends AnchorPane implements Initializable {
    @FXML
    private ToggleGroup _tabButtonGroup;
    @FXML
    private ToggleButton _planningTabButton, _calendarTabButton, _settingTabButton;
    @FXML
    private AnchorPane _planningPane, _calendarPane, _settingPane;
    public MainPane() {
        FXMLLoader loader = new FXMLLoader(UIFileResource.mainPaneFXML);
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
        _planningTabButton.setUserData(_planningPane);
        _calendarTabButton.setUserData(_calendarPane);
        _settingTabButton.setUserData(_settingPane);
        _tabButtonGroup.selectedToggleProperty().addListener((observable, oldValue, newValue) -> {
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
}
