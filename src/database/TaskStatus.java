package database;

public enum TaskStatus {
    Unstarted, Working, Completed, Unknown;
    public static TaskStatus fromInteger(int status) {
        switch (status) {
            case 0: return Unstarted;
            case 1: return Working;
            case 2: return Completed;
            default: return Unknown;
        }
    }
}
