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
}
