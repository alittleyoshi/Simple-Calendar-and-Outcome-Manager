package database;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;

public class Plan extends InformationBase implements PlanImpl {
    protected final List<Task> _tasks = new ArrayList<>();

    @Override
    public State getState() {
        boolean hasUnstarted = false, hasCompleted = false;
        for (Task task : _tasks) {
            switch (task.getState()) {
                case Working:
                    return State.Working;
                case Unstarted:
                    hasUnstarted = true;
                    break;
                case Completed:
                    hasCompleted = true;
                    break;
                default:
                    break;
            }
        }
        if (hasUnstarted) {
            if (hasCompleted) {
                return State.Working;
            } else {
                return State.Unstarted;
            }
        } else {
            if (hasCompleted) {
                return State.Completed;
            } else {
                return State.Unstarted;
            }
        }
    }

    @Override
    public Information withState(State state) {
        return this;
    }

    @Override
    public List<Task> getTasks() {
        return Collections.unmodifiableList(_tasks);
    }

    void addTask(Task task) {
        _tasks.add(task);
        if (task.getPlan() != this) {
            task.withPlan(this);
        }
    }

    void removeTask(Task task) {
        _tasks.remove(task);
    }

    Plan(int id, String title, String description, Date startTime, Date endTime) {
        super(id, Type.Plan, title, description, startTime, endTime, State.Unknown);
    }

    @Override
    public void update() {
        DatabaseManager.updatePlan(this);
    }
}
