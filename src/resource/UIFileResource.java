package resource;

import java.net.URL;

public class UIFileResource extends Resource{
    public static final URL
            mainPaneFXML = getResource("/ui/main pane.fxml"),
            planListPaneFXML = getResource("/ui/main/planning/plan list pane.fxml"),
            planItemFXML = getResource("/ui/main/planning/plan item.fxml"),
            taskListPaneFXML = getResource("/ui/main/planning/task list pane.fxml"),
            taskItemFXML = getResource("/ui/main/planning/task item.fxml"),
            functionPaneFXML = getResource("/ui/main/planning/function pane.fxml");

    private UIFileResource() {}
}
