package database;

import java.util.Date;
import java.util.Objects;

public class Task extends InformationBase implements TaskImpl {
    protected Plan plan;

    @Override
    public Plan getPlan() {
        return plan;
    }

    @Override
    public Task withPlan(Plan plan) {
        Objects.requireNonNull(plan);
        if (plan != this.plan) {
            if (this.plan != null) {
                this.plan.removeTask(this);
            }
            this.plan = plan;
            this.plan.addTask(this);
        }
        return this;
    }

    Task(int id, Plan plan, String title, String description, Date startTime, Date endTime, State state) {
        super(id, Type.Task, title, description, startTime, endTime, state);
        withPlan(plan);
    }

    @Override
    public void update() {
        DatabaseManager.updateTask(this);
    }
}
