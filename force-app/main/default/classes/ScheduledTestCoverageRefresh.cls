public class ScheduledTestCoverageRefresh implements Schedulable {

    public void execute(SchedulableContext context) {
        // Enqueue the Queueable to run tests via Tooling API
        System.enqueueJob(new TestCoverageRefreshQueueable());
    }

    // Schedule this class from Setup → Apex Classes → Schedule Apex
    // Recommended: Weekly, Sunday midnight
    // Or via Anonymous Apex:
    // System.schedule('Weekly Test Coverage Refresh', '0 0 0 ? * SUN', new ScheduledTestCoverageRefresh());
}
