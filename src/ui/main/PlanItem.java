package ui.main;

import database.DatabaseManager;
import database.Plan;
import database.Status;
import javafx.beans.property.*;
import javafx.beans.value.ChangeListener;
import javafx.collections.ObservableList;
import javafx.css.PseudoClass;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.geometry.Side;
import javafx.scene.AccessibleAttribute;
import javafx.scene.Node;
import javafx.scene.control.*;
import javafx.scene.input.ContextMenuEvent;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.AnchorPane;
import javafx.scene.paint.Color;
import resource.DatabaseResource;

import java.io.IOException;
import java.net.URL;
import java.util.List;
import java.util.ListIterator;
import java.util.ResourceBundle;

public class PlanItem extends AnchorPane implements Initializable, Toggle {
    private final Plan _plan;
    public Plan getPlan() {
        return _plan;
    }
    @FXML
    private Label _statusLabel, _titleLabel, _descriptionLabel;
    @FXML
    private TextField _titleEditingField;
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
        flushPlanStatus();
        setTitle(_plan.getTitle());
        _titleEditingField.focusedProperty().addListener((observable, oldValue, newValue) -> {
            if (!newValue) {
                onTitleEditedAction();
            }
        });
        _descriptionLabel.setText(_plan.getDescription());
        this.setOnMouseClicked((MouseEvent mouseEvent) -> {
            setSelected(!isSelected());
            mouseEvent.consume();
        });
    }
    public void flushPlanStatus() {
        Status planStatus = _plan.getStatus();
        _statusLabel.setText(DatabaseResource.getStatusName(planStatus));
        Color planStatusColor = DatabaseResource.getStatucsColor(planStatus);
        _statusLabel.setStyle(String.format("-fx-text-fill: rgba(%f, %f, %f, %f);", planStatusColor.getRed() * 256, planStatusColor.getGreen() * 256, planStatusColor.getBlue() * 256, planStatusColor.getOpacity()));
    }
    @FXML
    private void onTitleLabelClicked(MouseEvent mouseEvent) {
        if (mouseEvent.getClickCount() >= 2) {
            onTitleEditingAction();
        }
    }
    @FXML
    private void onTitleEditingAction() {
        _titleEditingField.setText(_plan.getTitle());
        _titleEditingField.setVisible(true);
        _titleEditingField.requestFocus();
    }
    @FXML
    private void onTitleEditedAction() {
        if (_titleEditingField.getText().trim().isEmpty()) {
            _titleEditingField.setText(_plan.getTitle());
        }
        _titleEditingField.setVisible(false);
        setTitle(_titleEditingField.getText().trim());
        _plan.setTitle(getTitle());
    }
    @FXML
    private void onPlanDeletingAction() {
        DatabaseManager.removePlan(_plan);
    }
    @FXML
    private void onPlanContextMenuRequested(ContextMenuEvent contextMenuEvent) {
        _titleLabel.getContextMenu().show((Node) contextMenuEvent.getSource(), null, contextMenuEvent.getX(), contextMenuEvent.getY());
        contextMenuEvent.consume();
    }
    @FXML
    private void onPlanEditingAction() {
        System.out.println("onPlanEditingAction");
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
                @Override
                protected void invalidated() {
                    ToggleGroup tg = get();
                    if (tg != null && !tg.getToggles().contains(PlanItem.this)) {
                        if (toggleGroup != null) {
                            toggleGroup.getToggles().remove(PlanItem.this);
                        }
                        tg.getToggles().add(PlanItem.this);
                    } else if (tg == null) {
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
    private StringProperty title;
    public String getTitle() {
        return title == null ? null : title.get();
    }
    public void setTitle(String title) {
        this.titleProperty().set(title);
    }
    public StringProperty titleProperty() {
        if (title == null) {
            title = new StringPropertyBase() {
                @Override
                protected void invalidated() {
                    _titleLabel.setText(get());
                }
                @Override
                public Object getBean() {
                    return PlanItem.this;
                }
                @Override
                public String getName() {
                    return "String";
                }
            };
        }
        return title;
    }
}
