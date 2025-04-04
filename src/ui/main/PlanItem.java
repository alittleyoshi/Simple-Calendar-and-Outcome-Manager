package ui.main;

import database.Plan;
import database.State;
import javafx.beans.property.*;
import javafx.event.EventHandler;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.scene.control.*;
import javafx.scene.input.MouseEvent;
import javafx.scene.paint.Color;
import resource.DatabaseResource;
import resource.UIFileResource;
import ui.event.ItemEvent;

import java.io.IOException;
import java.net.URL;
import java.text.DateFormat;
import java.text.spi.DateFormatProvider;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.ResourceBundle;

public class PlanItem extends ToggleButton implements Initializable, Toggle {
    private final ObjectProperty<Plan> _plan;
    public ReadOnlyObjectProperty<Plan> planProperty() {
        return _plan;
    }
    public Plan getPlan() {
        return _plan.get();
    }
    @FXML
    private Label _statusLabel, _titleLabel, _timeLabel, _descriptionLabel;
    @FXML
    private TextField _titleEditingField;
    @FXML
    private ToggleButton _planButton;
    public PlanItem(Plan plan) {
        _plan = new SimpleObjectProperty<>(getClass(), "plan", plan);
        FXMLLoader loader = new FXMLLoader(UIFileResource.planItemFXML);
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
        setTitle(getPlan().getTitle());
        _titleEditingField.focusedProperty().addListener((observable, oldValue, newValue) -> {
            if (!newValue) {
                onTitleEditedAction();
            }
        });
        _descriptionLabel.setText(getPlan().getDescription());
    }
    public void flushPlanStatus() {
        State planState = getPlan().getState();
        _statusLabel.setText(DatabaseResource.getStatusName(planState));
        Color planStatusColor = DatabaseResource.getStatucsColor(planState);
        _statusLabel.setStyle(String.format("-fx-text-fill: rgba(%f, %f, %f, %f);", planStatusColor.getRed() * 256, planStatusColor.getGreen() * 256, planStatusColor.getBlue() * 256, planStatusColor.getOpacity()));
        DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("MM.dd");
        _timeLabel.setText(dateTimeFormatter.format(getPlan().getStartTime().toInstant().atZone(ZoneId.systemDefault())) + "-" + dateTimeFormatter.format(getPlan().getEndTime().toInstant().atZone(ZoneId.systemDefault())));
    }
    @FXML
    private void onButtonAction() {
        setSelected(!isSelected());
    }
    @FXML
    private void onTitleLabelClicked(MouseEvent mouseEvent) {
        if (mouseEvent.getClickCount() >= 2) {
            onTitleEditingAction();
            mouseEvent.consume();
        }
    }
    @FXML
    private void onTitleEditingAction() {
        _titleEditingField.setText(getPlan().getTitle());
        _titleEditingField.setVisible(true);
        _titleEditingField.requestFocus();
    }
    @FXML
    private void onTitleEditedAction() {
        if (_titleEditingField.getText().trim().isEmpty()) {
            _titleEditingField.setText(getPlan().getTitle());
        }
        _titleEditingField.setVisible(false);
        setTitle(_titleEditingField.getText().trim());
        getPlan().withTitle(getTitle());
    }
    @FXML
    private void onDeletingAction() {
        fireEvent(new ItemEvent(ItemEvent.Type.DELETED));
    }
    @FXML
    private void onEditingAction() {
        fireEvent(new ItemEvent(ItemEvent.Type.EDITING));
    }

    private StringProperty title;
    public String getTitle() {
        return title == null ? null : titleProperty().get();
    }
    public void setTitle(String title) {
        this.titleProperty().set(title);
    }
    public StringProperty titleProperty() {
        if (title == null) {
            title = new StringPropertyBase() {
                @Override
                public Object getBean() {
                    return PlanItem.this;
                }
                @Override
                public String getName() {
                    return "title";
                }
            };
            _titleLabel.textProperty().bind(title);
        }
        return title;
    }

    protected ObjectProperty<EventHandler<ItemEvent>> onEditing;
    public ObjectProperty<EventHandler<ItemEvent>> onEditingProperty() {
        if (onEditing == null) {
            onEditing = new ObjectPropertyBase<EventHandler<ItemEvent>>() {
                @Override
                protected void invalidated() {
                    setEventHandler(ItemEvent.EDITING, get());
                }
                @Override
                public Object getBean() {
                    return PlanItem.this;
                }
                @Override
                public String getName() {
                    return "onEditing";
                }
            };
        }
        return onEditing;
    }
    public EventHandler<ItemEvent> getOnEditing() {
        return onEditing == null ? null : onEditingProperty().get();
    }
    public void setOnEditing(EventHandler<ItemEvent> value) {
        onEditingProperty().set(value);
    }

    protected ObjectProperty<EventHandler<ItemEvent>> onDeleted;
    public ObjectProperty<EventHandler<ItemEvent>> onDeletedProperty() {
        if (onDeleted == null) {
            onDeleted = new ObjectPropertyBase<EventHandler<ItemEvent>>() {
                @Override
                protected void invalidated() {
                    setEventHandler(ItemEvent.DELETED, get());
                }
                @Override
                public Object getBean() {
                    return PlanItem.this;
                }
                @Override
                public String getName() {
                    return "onDeleted";
                }
            };
        }
        return onDeleted;
    }
    public EventHandler<ItemEvent> getOnDeleted() {
        return onDeleted == null ? null : onDeletedProperty().get();
    }
    public void setOnDeleted(EventHandler<ItemEvent> value) {
        onDeletedProperty().set(value);
    }
}
