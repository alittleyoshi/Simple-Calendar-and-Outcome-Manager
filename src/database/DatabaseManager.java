package database;

import java.sql.*;
import java.util.*;
import java.util.Date;

public final class DatabaseManager {
    private static final Connection _connection;
    private static final List<Plan> _plans = new ArrayList<>();
    private static final List<Task> _tasks = new ArrayList<>();
    public static List<Plan> getPlans() {
        return Collections.unmodifiableList(_plans);
    }
    public static List<Task> getTasks() {
        return Collections.unmodifiableList(_tasks);
    }
    static {
        try {
            Class.forName("org.sqlite.JDBC");
            _connection = DriverManager.getConnection("jdbc:sqlite:test.db");
        } catch (ClassNotFoundException | SQLException e) {
            throw new RuntimeException(e);
        }
    }
    public static void initialize() {
        try (Statement statement = _connection.createStatement()) {
            statement.executeUpdate("CREATE TABLE IF NOT EXISTS TASKS(" +
                    "ID          INTEGER PRIMARY KEY AUTOINCREMENT," +
                    "TITLE       TEXT    NOT NULL," +
                    "DESCRIPTION TEXT," +
                    "START_TIME  BIGINT NOT NULL," +
                    "END_TIME    BIGINT NOT NULL," +
                    "STATUS      INTEGER NOT NULL," +
                    "BELONG      INTEGER NOT NULL" +
                    ");" +
                    "CREATE TABLE IF NOT EXISTS PLANS(" +
                    "ID          INTEGER PRIMARY KEY AUTOINCREMENT," +
                    "TITLE       TEXT    NOT NULL," +
                    "DESCRIPTION TEXT," +
                    "START_TIME  BIGINT NOT NULL," +
                    "END_TIME    BIGINT NOT NULL" +
                    ");");
            Map<Integer, Plan> map = new TreeMap<>();
            for (ResultSet resultSet = statement.executeQuery("SELECT * FROM PLANS"); resultSet.next();) {
                Plan plan = new Plan(resultSet.getInt(1), resultSet.getString(2), resultSet.getString(3), new Date(resultSet.getLong(4)), new Date(resultSet.getLong(5)));
                _plans.add(plan);
                map.put(plan.getID(), plan);
            }
            for (ResultSet resultSet = statement.executeQuery("SELECT * FROM TASKS"); resultSet.next();) {
                Plan belongPlan = map.get(resultSet.getInt(7));
                Task task = new Task(resultSet.getInt(1), belongPlan, resultSet.getString(2), resultSet.getString(3), new Date(resultSet.getLong(4)), new Date(resultSet.getLong(5)), Status.fromInteger(resultSet.getInt(6)));
                _tasks.add(task);
                belongPlan.addTask(task);
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
    public static Plan createPlan(String title, String description, Date startTime, Date endTime) {
        try (PreparedStatement statement = _connection.prepareStatement("INSERT INTO PLANS(TITLE, DESCRIPTION, START_TIME, END_TIME) VALUES (?, ?, ?, ?)", Statement.RETURN_GENERATED_KEYS)) {
            statement.setString(1, title);
            statement.setString(2, description);
            statement.setLong(3, startTime.getTime());
            statement.setLong(4, endTime.getTime());
            statement.executeUpdate();
            try (ResultSet resultSet = statement.getGeneratedKeys()) {
                Plan plan = new Plan(resultSet.getInt(1), title, description, startTime, endTime);
                _plans.add(plan);
                return plan;
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
    public static void updatePlan(Plan plan) {
        try (PreparedStatement statement = _connection.prepareStatement("UPDATE PLANS SET TITLE = ?, DESCRIPTION = ?, START_TIME = ?, END_TIME = ? WHERE id = ?")) {
            statement.setString(1, plan.getTitle());
            statement.setString(2, plan.getDescription());
            statement.setLong(3, plan.getStartTime().getTime());
            statement.setLong(4, plan.getEndTime().getTime());
            statement.setInt(5, plan.getID());
            statement.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
    public static void removePlan(Plan plan) {
        _tasks.removeAll(plan.getTasks());
        _plans.remove(plan);
        try {
            try (PreparedStatement statement = _connection.prepareStatement("DELETE FROM TASKS WHERE BELONG = ?")) {
                statement.setInt(1, plan.getID());
                statement.executeUpdate();
            }
            try (PreparedStatement statement = _connection.prepareStatement("DELETE FROM PLANS WHERE ID = ?")) {
                statement.setInt(1, plan.getID());
                statement.executeUpdate();
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
    public static Task createTask(Plan plan, String title, String description, Date startTime, Date endTime) {
        try (PreparedStatement statement = _connection.prepareStatement("INSERT INTO TASKS(TITLE, DESCRIPTION, START_TIME, END_TIME, STATUS, BELONG) VALUES (?, ?, ?, ?, ?, ?)", Statement.RETURN_GENERATED_KEYS)) {
            statement.setString(1, title);
            statement.setString(2, description);
            statement.setLong(3, startTime.getTime());
            statement.setLong(4, endTime.getTime());
            statement.setInt(5, Status.Unstarted.ordinal());
            statement.setInt(6, plan.getID());
            statement.executeUpdate();
            try (ResultSet resultSet = statement.getGeneratedKeys()) {
                Task task = new Task(resultSet.getInt(1), plan, title, description, startTime, endTime, Status.Unstarted);
                plan.addTask(task);
                _tasks.add(task);
                return task;
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
    public static void updateTask(Task task) {
        try (PreparedStatement statement = _connection.prepareStatement("UPDATE TASKS SET TITLE = ?, DESCRIPTION = ?, START_TIME = ?, END_TIME = ?, STATUS = ?, BELONG = ? WHERE id = ?")) {
            statement.setString(1, task.getTitle());
            statement.setString(2, task.getDescription());
            statement.setLong(3, task.getStartTime().getTime());
            statement.setLong(4, task.getEndTime().getTime());
            statement.setInt(5, task.getStatus().ordinal());
            statement.setInt(6, task.getPlan().getID());
            statement.setInt(7, task.getID());
            statement.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
    public static void removeTask(Task task) {
        task.getPlan().removeTask(task);
        _tasks.remove(task);
        try (PreparedStatement statement = _connection.prepareStatement("DELETE FROM TASKS WHERE ID = ?")) {
            statement.setInt(1, task.getID());
            statement.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
    private DatabaseManager() {}
}
