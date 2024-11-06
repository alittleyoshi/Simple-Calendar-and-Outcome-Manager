package ui.control;

import javafx.beans.property.BooleanProperty;
import javafx.beans.property.ObjectProperty;
import javafx.fxml.Initializable;
import javafx.scene.control.Toggle;
import javafx.scene.control.ToggleGroup;
import javafx.scene.layout.AnchorPane;

import java.net.URL;
import java.util.ResourceBundle;

public class SwitchBox extends AnchorPane implements Initializable, Toggle {
    public SwitchBox() {}
    public SwitchBox(String text) {

    }
    @Override
    public void initialize(URL location, ResourceBundle resources) {

    }
    @Override
    public ToggleGroup getToggleGroup() {
        return null;
    }
    @Override
    public void setToggleGroup(ToggleGroup toggleGroup) {

    }
    @Override
    public ObjectProperty<ToggleGroup> toggleGroupProperty() {
        return null;
    }
    @Override
    public boolean isSelected() {
        return false;
    }
    @Override
    public void setSelected(boolean selected) {

    }
    @Override
    public BooleanProperty selectedProperty() {
        return null;
    }
}
