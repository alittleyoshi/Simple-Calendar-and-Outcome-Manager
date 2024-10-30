package database;

import java.sql.*;

public final class DatabaseManager {
    private static final Connection _connection;
    static {
        try {
            Class.forName("org.sqlite.JDBC");
            _connection = DriverManager.getConnection("jdbc:sqlite:test.db");
        } catch (ClassNotFoundException | SQLException e) {
            throw new RuntimeException(e);
        }
    }
    public static void initialize() {
        execute("CREATE TABLE IF NOT EXISTS TASKS(" +
                "ID          INTEGER PRIMARY KEY AUTOINCREMENT," +
                "TITLE       TEXT    NOT NULL," +
                "DESCRIPTION TEXT," +
                "START_TIME  BIGINT NOT NULL," +
                "END_TIME    BIGINT NOT NULL," +
                "STATUS      INTEGER NOT NULL," +
                "BELONG      INTEGER NOT NULL" +
                ");");
        execute("CREATE TABLE IF NOT EXISTS PLANS(" +
                "ID          INTEGER PRIMARY KEY AUTOINCREMENT," +
                "TITLE       TEXT    NOT NULL," +
                "DESCRIPTION TEXT," +
                "START_TIME  BIGINT NOT NULL," +
                "END_TIME    BIGINT NOT NULL" +
                ");");
    }
    private static void execute(String command) {
        try (Statement statement = _connection.createStatement()) {
            statement.executeUpdate(command);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
    public static Plan createPlan(String title, String description, long startTime, long endTime) {
        try (PreparedStatement statement = _connection.prepareStatement("INSERT INTO PLANS(TITLE, DESCRIPTION, START_TIME, END_TIME) VALUES (?, ?, ?, ?)", Statement.RETURN_GENERATED_KEYS)) {
            statement.setString(1, title);
            statement.setString(2, description);
            statement.setLong(3, startTime);
            statement.setLong(4, endTime);
            statement.executeUpdate();
            try (ResultSet resultSet = statement.getGeneratedKeys()) {
                while (resultSet.next()) {
                    System.out.println(resultSet.getInt(1));
                }
            }
            return new Plan(0, title, description, startTime, endTime);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
    public static void removePlan(Plan plan) {
        for (Task task : plan.getTasks()) {
            removeTask(task);
        }

    }
    public static Task createTask(Plan plan, String title, String description, long startTime, long endTime) {
        try (PreparedStatement statement = _connection.prepareStatement("INSERT INTO TASKS(TITLE, DESCRIPTION, START_TIME, END_TIME, BELONG) VALUES (?, ?, ?, ?, ?)", Statement.RETURN_GENERATED_KEYS)) {
            statement.setString(1, title);
            statement.setString(2, description);
            statement.setLong(3, startTime);
            statement.setLong(4, endTime);
            statement.setInt(5, plan.getID());
            statement.executeUpdate();
            try (ResultSet resultSet = statement.getGeneratedKeys()) {
                while (resultSet.next()) {
                    System.out.println(resultSet.getInt("ID"));
                }
            }
            return new Task(0, plan, title, description, startTime, endTime);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
    public static void removeTask(Task task) {

    }
    private DatabaseManager() {}
}
