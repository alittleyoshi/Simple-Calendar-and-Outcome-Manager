package database;

interface TaskImpl extends Information {
    Plan getPlan();

    Information withPlan(Plan plan);
}
