@isTest
private class FlowNoFaultPathRuleTest {

    @isTest
    static void testRunCheck_flagsFlowMissingFaultConnector() {
        Test.setMock(HttpCalloutMock.class, new FlowNoFaultPathRuleMock());

        Test.startTest();
        FlowNoFaultPathRule rule = new FlowNoFaultPathRule();
        List<AuditFinding> findings = rule.runCheck();
        Test.stopTest();

        System.assertEquals(1, findings.size(), 'Should flag the one flow with missing fault connector');
        System.assertEquals('Test_Flow', findings[0].fieldOrComponentName);
        System.assertEquals('Medium', findings[0].severity);
        System.assertEquals('Automation', findings[0].category);
    }
}
