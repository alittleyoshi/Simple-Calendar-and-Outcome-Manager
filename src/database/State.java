package database;

public enum State {
    Unknown(0),
    Unstarted(1),
    Working(2),
    Completed(3);

    private final int state;

    State(int state) {
        this.state = state;
    }

    public int toInteger() {
        return state;
    }

    public static int toInteger(State state) {
        return state.toInteger();
    }

    public static State fromInteger(int state) {
        switch (state) {
            case 1: return Unstarted;
            case 2: return Working;
            case 3: return Completed;
            default: return Unknown;
        }
    }
}
