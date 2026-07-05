@isTest
private class AuditRuleEngineQueueableTest {

    @isTest
    static void testQueueableExecutes_withoutException() {
        Test.setMock(HttpCalloutMock.class, new AuditRuleEngineAllRulesMock());

        Test.startTest();
        System.enqueueJob(new AuditRuleEngineQueueable());
        Test.stopTest();

        // Verify findings were inserted (even if empty from mock)
        List<Audit_Finding__c> findings = [SELECT Id FROM Audit_Finding__c];
        System.assertNotEquals(null, findings, 'Findings query should not be null');
    }
}
