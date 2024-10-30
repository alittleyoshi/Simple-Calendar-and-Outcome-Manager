package database;

import java.sql.*;
import java.util.*;
import java.util.Date;

public final class DatabaseManager {
    private static final Connection _connection;
    private static final List<Plan> _plans = new ArrayList<>();
    private static final List<Task> _tasks = new ArrayList<>();
    public List<Plan> getPlans() {
        return Collections.unmodifiableList(_plans);
    }
    public List<Task> getTasks() {
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
                    "START_TIME  TEXT NOT NULL," +
                    "END_TIME    TEXT NOT NULL," +
                    "STATUS      INTEGER NOT NULL," +
                    "BELONG      INTEGER NOT NULL" +
                    ");" +
                    "CREATE TABLE IF NOT EXISTS PLANS(" +
                    "ID          INTEGER PRIMARY KEY AUTOINCREMENT," +
                    "TITLE       TEXT    NOT NULL," +
                    "DESCRIPTION TEXT," +
                    "START_TIME  TEXT NOT NULL," +
                    "END_TIME    TEXT NOT NULL" +
                    ");");
            Map<Integer, Plan> map = new TreeMap<>();
            for (ResultSet resultSet = statement.executeQuery("SELECT * FROM PLANS"); resultSet.next();) {
                Plan plan = new Plan(resultSet.getInt(1), resultSet.getString(2), resultSet.getString(3), resultSet.getTime(4), resultSet.getTime(5));
                _plans.add(plan);
                map.put(plan.getID(), plan);
            }
            for (ResultSet resultSet = statement.executeQuery("SELECT * FROM TASKS"); resultSet.next();) {
                Task task = new Task(resultSet.getInt(1), map.get(resultSet.getInt(resultSet.getInt(7))), resultSet.getString(2), resultSet.getString(3), resultSet.getTime(4), resultSet.getTime(5), TaskStatus.fromInteger(resultSet.getInt(6)));
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
    public static Plan createPlan(String title, String description, Date startTime, Date endTime) {
        try (PreparedStatement statement = _connection.prepareStatement("INSERT INTO PLANS(TITLE, DESCRIPTION, START_TIME, END_TIME) VALUES (?, ?, ?, ?)", Statement.RETURN_GENERATED_KEYS)) {
            statement.setString(1, title);
            statement.setString(2, description);
            statement.setTime(3, new Time(startTime.getTime()));
            statement.setTime(4, new Time(endTime.getTime()));
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
            statement.setTime(3, new Time(plan.getStartTime().getTime()));
            statement.setTime(4, new Time(plan.getEndTime().getTime()));
            statement.setInt(5, plan.getID());
            statement.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
    public static void removePlan(Plan plan) {
        for (Task task : new ArrayList<>(plan.getTasks())) {
            removeTask(task);
        }
        _plans.remove(plan);
        try (PreparedStatement statement = _connection.prepareStatement("DELETE FROM PLANS WHERE ID = ?")) {
            statement.setInt(1, plan.getID());
            statement.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
    public static Task createTask(Plan plan, String title, String description, Date startTime, Date endTime) {
        try (PreparedStatement statement = _connection.prepareStatement("INSERT INTO TASKS(TITLE, DESCRIPTION, START_TIME, END_TIME, STATUS, BELONG) VALUES (?, ?, ?, ?, ?, ?)", Statement.RETURN_GENERATED_KEYS)) {
            statement.setString(1, title);
            statement.setString(2, description);
            statement.setTime(3, new Time(startTime.getTime()));
            statement.setTime(4, new Time(endTime.getTime()));
            statement.setInt(5, TaskStatus.Unstarted.ordinal());
            statement.setInt(6, plan.getID());
            statement.executeUpdate();
            try (ResultSet resultSet = statement.getGeneratedKeys()) {
                Task task = new Task(resultSet.getInt(1), plan, title, description, startTime, endTime, TaskStatus.Unstarted);
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
            statement.setTime(3, new Time(task.getStartTime().getTime()));
            statement.setTime(4, new Time(task.getEndTime().getTime()));
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
