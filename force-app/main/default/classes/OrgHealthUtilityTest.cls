@isTest
private class OrgHealthUtilityTest {

    @isTest
    static void testGetActiveUserCount() {
        Test.startTest();
        Integer count = OrgHealthUtility.getActiveUserCount();
        Test.stopTest();
        System.assert(count >= 0, 'User count should be non-negative');
    }

    @isTest
    static void testGetCustomObjectCount() {
        Test.startTest();
        Integer count = OrgHealthUtility.getCustomObjectCount();
        Test.stopTest();
        System.assert(count >= 0, 'Object count should be non-negative');
    }

    // getRecordCountsByObject, generateHealthSummary, isOrgHealthy intentionally not tested
    // This gives ~40% coverage - demonstrating what SFDC Sentinel flags
}
