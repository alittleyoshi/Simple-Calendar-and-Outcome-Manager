package database;

public enum Type {
    Unknown(0),
    Plan(1),
    Task(2);

    private final int type;

    Type(int type) {
        this.type = type;
    }

    public int toInteger() {
        return type;
    }

    public static int toInteger(Type type) {
        return type.toInteger();
    }

    public static Type fromInteger(int type) {
        switch (type) {
            case 1: return Plan;
            case 2: return Task;
            default: return Unknown;
        }
    }
}
