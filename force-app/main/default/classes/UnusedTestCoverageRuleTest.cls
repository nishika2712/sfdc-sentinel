@isTest
private class UnusedTestCoverageRuleTest {

    @isTest
    static void testRunCheck_flagsLowCoverageClass() {
        Test.setMock(HttpCalloutMock.class, new UnusedTestCoverageRuleMock());

        Test.startTest();
        UnusedTestCoverageRule rule = new UnusedTestCoverageRule();
        List<AuditFinding> findings = rule.runCheck();
        Test.stopTest();

        System.assertEquals(1, findings.size(), 'Should flag the one low-coverage class from mock data');
        System.assertEquals('SomeClass', findings[0].fieldOrComponentName);
        System.assertEquals('Medium', findings[0].severity);
        System.assertEquals('Code Quality', findings[0].category);
    }
}
