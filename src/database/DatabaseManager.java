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

    private static final String
            idKey = "ID",
            titleKey = "TITLE",
            descriptionKey = "DESCRIPTION",
            startTimeKey = "START_TIME",
            endTimeKey = "END_TIME",
            stateKey = "STATE",
            belongKey = "BELONG",
            tasksTableName = "TASKS",
            plansTableName = "PLANS";

    public static void initialize() {
        try (Statement statement = _connection.createStatement()) {
            statement.executeUpdate("CREATE TABLE IF NOT EXISTS " + tasksTableName + "(" +
                    idKey + "          INTEGER PRIMARY KEY AUTOINCREMENT," +
                    titleKey + "       TEXT    NOT NULL," +
                    descriptionKey + " TEXT," +
                    startTimeKey + "   BIGINT NOT NULL," +
                    endTimeKey + "     BIGINT NOT NULL," +
                    stateKey + "       INTEGER NOT NULL," +
                    belongKey + "      INTEGER NOT NULL" +
                    ");" +
                    "CREATE TABLE IF NOT EXISTS " + plansTableName + "(" +
                    idKey + "          INTEGER PRIMARY KEY AUTOINCREMENT," +
                    titleKey + "       TEXT NOT NULL," +
                    descriptionKey + " TEXT," +
                    startTimeKey + "   BIGINT NOT NULL," +
                    endTimeKey + "     BIGINT NOT NULL" +
                    ");");
            Map<Integer, Plan> map = new TreeMap<>();
            for (ResultSet resultSet = statement.executeQuery("SELECT * FROM " + plansTableName); resultSet.next();) {
                Plan plan = new Plan(
                        resultSet.getInt(1),
                        resultSet.getString(2),
                        resultSet.getString(3),
                        new Date(resultSet.getLong(4)),
                        new Date(resultSet.getLong(5))
                );
                _plans.add(plan);
                map.put(plan.getID(), plan);
            }
            for (ResultSet resultSet = statement.executeQuery("SELECT * FROM " + tasksTableName); resultSet.next();) {
                Plan belongPlan = map.get(resultSet.getInt(7));
                Task task = new Task(
                        resultSet.getInt(1),
                        belongPlan,
                        resultSet.getString(2),
                        resultSet.getString(3),
                        new Date(resultSet.getLong(4)),
                        new Date(resultSet.getLong(5)),
                        State.fromInteger(resultSet.getInt(6))
                );
                _tasks.add(task);
                belongPlan.addTask(task);
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public static Plan createPlan(String title, String description, Date startTime, Date endTime) {
        try (PreparedStatement statement = _connection.prepareStatement(
                "INSERT INTO " + plansTableName + "(" + titleKey + ", " + descriptionKey + ", " + startTimeKey + ", " + endTimeKey + ") VALUES (?, ?, ?, ?)",
                Statement.RETURN_GENERATED_KEYS)
        ) {
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

    public static boolean updatePlan(Plan plan) {
        if (_plans.contains(plan)) {
            try (PreparedStatement statement = _connection.prepareStatement(
                    "UPDATE " + plansTableName + " SET " + titleKey + " = ?, " + descriptionKey + " = ?, " + startTimeKey + " = ?, " + endTimeKey + " = ? WHERE " + idKey + " = ?")
            ) {
                statement.setString(1, plan.getTitle());
                statement.setString(2, plan.getDescription());
                statement.setLong(3, plan.getStartTime().getTime());
                statement.setLong(4, plan.getEndTime().getTime());
                statement.setInt(5, plan.getID());
                statement.executeUpdate();
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
            return true;
        } else {
            return false;
        }
    }

    public static boolean removePlan(Plan plan) {
        _tasks.removeAll(plan.getTasks());
        if (_plans.remove(plan)) {
            try {
                try (PreparedStatement statement = _connection.prepareStatement(
                        "DELETE FROM " + tasksTableName + " WHERE " + belongKey + " = ?")
                ) {
                    statement.setInt(1, plan.getID());
                    statement.executeUpdate();
                }
                try (PreparedStatement statement = _connection.prepareStatement(
                        "DELETE FROM " + plansTableName + " WHERE " + idKey + " = ?")
                ) {
                    statement.setInt(1, plan.getID());
                    statement.executeUpdate();
                }
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
            return true;
        } else {
            return false;
        }
    }

    public static Task createTask(Plan plan, String title, String description, Date startTime, Date endTime) {
        try (PreparedStatement statement = _connection.prepareStatement(
                "INSERT INTO " + tasksTableName + "(" + titleKey + ", " + descriptionKey + ", " + startTimeKey + ", " + endTimeKey + ", " + stateKey +", " + belongKey + ") VALUES (?, ?, ?, ?, ?, ?)",
                Statement.RETURN_GENERATED_KEYS)
        ) {
            statement.setString(1, title);
            statement.setString(2, description);
            statement.setLong(3, startTime.getTime());
            statement.setLong(4, endTime.getTime());
            statement.setInt(5, State.Unstarted.toInteger());
            statement.setInt(6, plan.getID());
            statement.executeUpdate();
            try (ResultSet resultSet = statement.getGeneratedKeys()) {
                Task task = new Task(resultSet.getInt(1), plan, title, description, startTime, endTime, State.Unstarted);
                plan.addTask(task);
                _tasks.add(task);
                return task;
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public static boolean updateTask(Task task) {
        if (_tasks.contains(task)) {
            try (PreparedStatement statement = _connection.prepareStatement(
                    "UPDATE " + tasksTableName + " SET " + titleKey + " = ?, " + descriptionKey + " = ?, " + startTimeKey + " = ?, " + endTimeKey + " = ?, " + stateKey + " = ?, " + belongKey + " = ? WHERE " + idKey + " = ?")
            ) {
                statement.setString(1, task.getTitle());
                statement.setString(2, task.getDescription());
                statement.setLong(3, task.getStartTime().getTime());
                statement.setLong(4, task.getEndTime().getTime());
                statement.setInt(5, task.getState().toInteger());
                statement.setInt(6, task.getPlan().getID());
                statement.setInt(7, task.getID());
                statement.executeUpdate();
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
            return true;
        } else {
            return false;
        }
    }

    public static boolean removeTask(Task task) {
        task.getPlan().removeTask(task);
        if (_tasks.remove(task)) {
            try (PreparedStatement statement = _connection.prepareStatement("DELETE FROM " + tasksTableName + " WHERE " + idKey +" = ?")) {
                statement.setInt(1, task.getID());
                statement.executeUpdate();
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
            return true;
        } else {
            return false;
        }
    }

    private DatabaseManager() {}
}
