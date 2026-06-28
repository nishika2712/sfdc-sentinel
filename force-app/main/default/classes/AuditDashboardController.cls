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
        return [
            SELECT Id, Rule_Name__c, Severity__c, Category__c, Object_API_Name__c,
                   Field_Or_Component_Name__c, Issue_Description__c, Remediation_Guidance__c, Scan_Date__c
            FROM Audit_Finding__c
            ORDER BY Scan_Date__c DESC, Severity__c ASC
            LIMIT 200
        ];
    }

    @AuraEnabled
    public static Integer getActiveRuleCount() {
        return [SELECT COUNT() FROM Audit_Rule__mdt WHERE Is_Active__c = true];
    }
}
