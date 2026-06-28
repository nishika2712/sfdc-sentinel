public with sharing class AuditDashboardController {

    @AuraEnabled
    public static void startScan() {
        try {
            System.enqueueJob(new AuditRuleEngineQueueable());
        } catch (Exception e) {
            throw new AuraHandledException('Failed to start scan: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Audit_Finding__c> getFindings() {
        List<AggregateResult> latestScan = [
            SELECT MAX(Scan_Date__c) latestDate
            FROM Audit_Finding__c
        ];

        DateTime mostRecentScanDate = (DateTime) latestScan[0].get('latestDate');

        if (mostRecentScanDate == null) {
            return new List<Audit_Finding__c>();
        }

        return [
            SELECT Id, Rule_Name__c, Severity__c, Category__c, Object_API_Name__c,
                   Field_Or_Component_Name__c, Issue_Description__c, Remediation_Guidance__c, Scan_Date__c
            FROM Audit_Finding__c
            WHERE Scan_Date__c = :mostRecentScanDate
            ORDER BY Severity__c ASC
            LIMIT 200
        ];
    }

    @AuraEnabled
    public static Integer getActiveRuleCount() {
        return [SELECT COUNT() FROM Audit_Rule__mdt WHERE Is_Active__c = true];
    }
}
