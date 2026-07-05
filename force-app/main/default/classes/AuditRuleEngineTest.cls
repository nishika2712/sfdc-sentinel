@isTest
private class AuditRuleEngineTest {

    @isTest
    static void testRunSingleRule_invalidClassName_returnsFinding() {
        Audit_Rule__mdt fakeRule = new Audit_Rule__mdt(
            MasterLabel = 'Fake Rule',
            Apex_Class_Name__c = 'NonExistentClass99999',
            Severity__c = 'Medium',
            Rule_Category__c = 'Code Quality',
            Description__c = 'Test rule'
        );

        Test.startTest();
        AuditRuleEngine engine = new AuditRuleEngine();
        List<AuditFinding> findings = engine.runSingleRulePublic(fakeRule);
        Test.stopTest();

        System.assertEquals(1, findings.size(), 'Should return one engine error finding');
        System.assertEquals('Engine Error', findings[0].category, 'Category should be Engine Error');
    }

    @isTest
    static void testRunSingleRule_nonIAuditRuleClass_returnsFinding() {
        Audit_Rule__mdt fakeRule = new Audit_Rule__mdt(
            MasterLabel = 'Bad Class Rule',
            Apex_Class_Name__c = 'AuditDashboardController',
            Severity__c = 'Medium',
            Rule_Category__c = 'Code Quality',
            Description__c = 'Test rule pointing to wrong class type'
        );

        Test.startTest();
        AuditRuleEngine engine = new AuditRuleEngine();
        List<AuditFinding> findings = engine.runSingleRulePublic(fakeRule);
        Test.stopTest();

        System.assertEquals(1, findings.size(), 'Should return one engine error finding');
        System.assertEquals('Engine Error', findings[0].category, 'Category should be Engine Error');
    }

    @isTest
    static void testRunAllActiveRules_returnsListWithoutException() {
        Test.setMock(HttpCalloutMock.class, new AuditRuleEngineAllRulesMock());

        Test.startTest();
        AuditRuleEngine engine = new AuditRuleEngine();
        List<AuditFinding> findings = engine.runAllActiveRules();
        Test.stopTest();

        System.assertNotEquals(null, findings, 'Findings should not be null');
    }
}
