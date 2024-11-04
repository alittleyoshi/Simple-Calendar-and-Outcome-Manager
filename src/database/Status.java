package database;

public enum Status {
    Unstarted, Working, Completed, Unknown;
    public static Status fromInteger(int status) {
        switch (status) {
            case 0: return Unstarted;
            case 1: return Working;
            case 2: return Completed;
            default: return Unknown;
        }
    }
    public String getName() {
        switch (this) {
            case Unstarted: return "未开始";
            case Working: return "工作中";
            case Completed: return "已完成";
            default: return "未知";
        }
    }
}
