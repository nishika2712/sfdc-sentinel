public class TestCoverageRefreshQueueable implements Queueable, Database.AllowsCallouts {

    public void execute(QueueableContext context) {
        TestCoverageService.runAllTestsAsync();
    }
}
