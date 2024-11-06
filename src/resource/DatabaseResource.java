package resource;

import database.Status;
import javafx.scene.paint.Color;

public class DatabaseResource extends Resource {
    public static String getStatusName(Status status) {
        switch (status) {
            case Unstarted: return "未开始";
            case Working: return "进行中";
            case Completed: return "已完成";
            default: return "未知";
        }
    }
    public static Color getStatucsColor(Status status) {
        switch (status) {
            case Unstarted: return Color.RED;
            case Working: return Color.YELLOW;
            case Completed: return Color.GREEN;
            default: return Color.color(1, 1, 1, 0);
        }
    }
    private DatabaseResource() {}
}
