@isTest
private class AuditFindingTest {

    @isTest
    static void testAuditFindingConstructor_setsAllFields() {
        Test.startTest();
        AuditFinding finding = new AuditFinding(
            'Test Rule',
            'High',
            'Security',
            'Account',
            'test_field__c',
            'Test issue description',
            'Test remediation guidance'
        );
        Test.stopTest();

        System.assertEquals('Test Rule', finding.ruleName);
        System.assertEquals('High', finding.severity);
        System.assertEquals('Security', finding.category);
        System.assertEquals('Account', finding.objectApiName);
        System.assertEquals('test_field__c', finding.fieldOrComponentName);
        System.assertEquals('Test issue description', finding.issueDescription);
        System.assertEquals('Test remediation guidance', finding.remediationGuidance);
    }
}
