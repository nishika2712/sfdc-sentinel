@isTest
private class MissingFLSRuleTest {

    @isTest
    static void testRunCheck_returnsFindings() {
        Test.startTest();
        MissingFLSRule rule = new MissingFLSRule();
        List<AuditFinding> findings = rule.runCheck();
        Test.stopTest();

        System.assertNotEquals(null, findings, 'Findings list should not be null');
    }

    @isTest
    static void testRunCheck_findingStructureIsValid() {
        Test.startTest();
        MissingFLSRule rule = new MissingFLSRule();
        List<AuditFinding> findings = rule.runCheck();
        Test.stopTest();

        for (AuditFinding f : findings) {
            System.assertNotEquals(null, f.ruleName, 'ruleName should be populated');
            System.assertEquals('High', f.severity, 'Severity should be High for FLS issues');
            System.assertEquals('Security', f.category, 'Category should be Security');
            System.assertNotEquals(null, f.objectApiName, 'objectApiName should be populated');
        }
    }
}
