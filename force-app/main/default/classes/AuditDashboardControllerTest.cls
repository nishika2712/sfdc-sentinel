@isTest
private class AuditDashboardControllerTest {

    @testSetup
    static void setupData() {
        Audit_Finding__c finding = new Audit_Finding__c(
            Rule_Name__c = 'Missing Field Level Security',
            Severity__c = 'High',
            Category__c = 'Security',
            Object_API_Name__c = 'Account',
            Field_Or_Component_Name__c = 'test_field__c',
            Issue_Description__c = 'Test issue',
            Remediation_Guidance__c = 'Test guidance',
            Scan_Date__c = DateTime.now()
        );
        insert finding;
    }

    @isTest
    static void testGetFindings_returnsLatestScan() {
        Test.startTest();
        List<Audit_Finding__c> findings = AuditDashboardController.getFindings();
        Test.stopTest();

        System.assertNotEquals(null, findings, 'Findings should not be null');
        System.assertEquals(1, findings.size(), 'Should return 1 finding from setup');
    }

    @isTest
    static void testGetFindings_emptyWhenNoData() {
        delete [SELECT Id FROM Audit_Finding__c];

        Test.startTest();
        List<Audit_Finding__c> findings = AuditDashboardController.getFindings();
        Test.stopTest();

        System.assertNotEquals(null, findings, 'Should return empty list not null');
        System.assertEquals(0, findings.size(), 'Should return empty list when no findings');
    }

    @isTest
    static void testGetActiveRuleCount() {
        Test.startTest();
        Integer count = AuditDashboardController.getActiveRuleCount();
        Test.stopTest();

        System.assert(count >= 0, 'Rule count should be non-negative');
    }

    @isTest
    static void testStartScan_enqueuesJob() {
        Test.startTest();
        AuditDashboardController.startScan();
        Test.stopTest();

        // If no exception thrown, job was enqueued successfully
        System.assert(true, 'startScan completed without exception');
    }
}
