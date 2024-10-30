package database;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

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
        try {
            Statement statement = _connection.createStatement();
            statement.executeUpdate(command);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
    public static Plan createPlan() {
        Plan plan = new Plan();
        return plan;
    }
    public static Task createTask() {
        Task task = new Task();
        return task;
    }
    private DatabaseManager() {}
}
