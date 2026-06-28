@isTest
private class SOQLInLoopRuleTest {

    @isTest
    static void testRunCheck_flagsOnlyClassWithSoqlInLoop() {
        Test.setMock(HttpCalloutMock.class, new SOQLInLoopRuleMock());

        Test.startTest();
        SOQLInLoopRule rule = new SOQLInLoopRule();
        List<AuditFinding> findings = rule.runCheck();
        Test.stopTest();

        System.assertEquals(1, findings.size(), 'Should flag only BadClass, not GoodClass');
        System.assertEquals('BadClass', findings[0].fieldOrComponentName);
        System.assertEquals('High', findings[0].severity);
        System.assertEquals('Code Quality', findings[0].category);
    }
}
