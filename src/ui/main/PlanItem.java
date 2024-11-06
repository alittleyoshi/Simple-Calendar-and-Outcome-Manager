package ui.main;

import database.Plan;
import database.Status;
import javafx.beans.property.BooleanProperty;
import javafx.beans.property.BooleanPropertyBase;
import javafx.beans.property.ObjectProperty;
import javafx.beans.property.ObjectPropertyBase;
import javafx.beans.value.ChangeListener;
import javafx.css.PseudoClass;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.scene.AccessibleAttribute;
import javafx.scene.control.Label;
import javafx.scene.control.Toggle;
import javafx.scene.control.ToggleGroup;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.AnchorPane;
import javafx.scene.paint.Color;
import resource.DatabaseResource;

import java.io.IOException;
import java.net.URL;
import java.util.ResourceBundle;

public class PlanItem extends AnchorPane implements Initializable, Toggle {
    private final Plan _plan;
    public Plan getPlan() {
        return _plan;
    }
    @FXML
    private Label _statusLabel, _titleLabel, _descriptionLabel;
    public PlanItem(Plan plan) {
        _plan = plan;
        FXMLLoader loader = new FXMLLoader(PlanItem.class.getResource("/ui/main/plan scene.fxml"));
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
        Status planStatus = _plan.getStatus();
        _statusLabel.setText(DatabaseResource.getStatusName(planStatus));
        Color planStatusColor = DatabaseResource.getStatucsColor(planStatus);
//        _statusLabel.setStyle("-fx-text-fill: rgba(1.0, 0.0, 0.0, 1.0);");
        _statusLabel.setStyle(String.format("-fx-text-fill: rgba(%f, %f, %f, %f);", planStatusColor.getRed() * 256, planStatusColor.getGreen() * 256, planStatusColor.getBlue() * 256, planStatusColor.getOpacity()));
        _titleLabel.setText(_plan.getTitle());
        _descriptionLabel.setText(_plan.getDescription());
        this.setOnMouseClicked((MouseEvent mouseEvent) -> {
            setSelected(!isSelected());
            mouseEvent.consume();
        });
    }
    private ObjectProperty<ToggleGroup> toggleGroup;
    @Override
    public ToggleGroup getToggleGroup() {
        return toggleGroup == null ? null : toggleGroup.get();
    }
    @Override
    public void setToggleGroup(ToggleGroup toggleGroup) {
        toggleGroupProperty().set(toggleGroup);
    }
    @Override
    public ObjectProperty<ToggleGroup> toggleGroupProperty() {
        if (toggleGroup == null) {
            toggleGroup = new ObjectPropertyBase<ToggleGroup>() {
                private ToggleGroup toggleGroup;
                private final ChangeListener<Toggle> changeListener = (observable, oldValue, newValue) -> {
                    System.out.printf("[observable: %s][oldValue: %s][newValue: %s]\n", observable, oldValue, newValue);
                };
                @Override
                protected void invalidated() {
                    ToggleGroup tg = get();
                    if (tg != null && !tg.getToggles().contains(PlanItem.this)) {
                        if (toggleGroup != null) {
                            toggleGroup.getToggles().remove(PlanItem.this);
                        }
                        tg.getToggles().add(PlanItem.this);
                        tg.selectedToggleProperty().addListener(changeListener);
                    } else if (tg == null) {
                        toggleGroup.selectedToggleProperty().removeListener(changeListener);
                        toggleGroup.getToggles().remove(PlanItem.this);
                    }
                    toggleGroup = tg;
                }
                @Override
                public Object getBean() {
                    return PlanItem.this;
                }
                @Override
                public String getName() {
                    return "toggleGroup";
                }
            };
        }
        return toggleGroup;
    }
    private BooleanProperty selected;
    @Override
    public boolean isSelected() {
        return selected != null && selected.get();
    }
    @Override
    public void setSelected(boolean selected) {
        selectedProperty().set(selected);
    }
    @Override
    public BooleanProperty selectedProperty() {
        if (selected == null) {
            selected = new BooleanPropertyBase() {
                @Override
                protected void invalidated() {
                    boolean selected = get();
                    ToggleGroup toggleGroup = getToggleGroup();
                    pseudoClassStateChanged(PseudoClass.getPseudoClass("selected"), selected);
                    notifyAccessibleAttributeChanged(AccessibleAttribute.SELECTED);
                    if (toggleGroup != null) {
                        if (selected) {
                            toggleGroup.selectToggle(PlanItem.this);
                        } else if (toggleGroup.getSelectedToggle() == PlanItem.this) {
                            toggleGroup.selectToggle(null);
                        }
                    }
                }
                @Override
                public Object getBean() {
                    return PlanItem.this;
                }
                @Override
                public String getName() {
                    return "toggleGroup";
                }
            };
        }
        return selected;
    }
}
