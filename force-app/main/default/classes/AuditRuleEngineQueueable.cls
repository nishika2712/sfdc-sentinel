public class AuditRuleEngineQueueable implements Queueable, Database.AllowsCallouts {

    public void execute(QueueableContext context) {
        List<Audit_Rule__mdt> activeRules = [
            SELECT MasterLabel, Apex_Class_Name__c, Severity__c, Rule_Category__c, Description__c
            FROM Audit_Rule__mdt
            WHERE Is_Active__c = true
        ];

        Integer totalRules = activeRules.size();
        Integer completedCount = 0;
        List<Audit_Finding__c> findingsToInsert = new List<Audit_Finding__c>();
        DateTime scanTime = DateTime.now();

        publishProgress('In Progress', completedCount, totalRules, 'Starting scan');

        AuditRuleEngine engine = new AuditRuleEngine();

        for (Audit_Rule__mdt ruleConfig : activeRules) {
            List<AuditFinding> ruleFindings = engine.runSingleRulePublic(ruleConfig);

            for (AuditFinding f : ruleFindings) {
                findingsToInsert.add(new Audit_Finding__c(
                    Rule_Name__c = f.ruleName,
                    Severity__c = f.severity,
                    Category__c = f.category,
                    Object_API_Name__c = f.objectApiName,
                    Field_Or_Component_Name__c = f.fieldOrComponentName,
                    Issue_Description__c = f.issueDescription,
                    Remediation_Guidance__c = f.remediationGuidance,
                    Scan_Date__c = scanTime
                ));
            }

            completedCount++;
            publishProgress('In Progress', completedCount, totalRules, ruleConfig.MasterLabel);
        }

        if (!findingsToInsert.isEmpty()) {
            insert findingsToInsert;
        }

        publishProgress('Completed', completedCount, totalRules, 'Scan finished');
    }

    private void publishProgress(String status, Integer completed, Integer total, String currentRule) {
        Audit_Progress__e progressEvent = new Audit_Progress__e(
            Status__c = status,
            Rules_Completed__c = completed,
            Total_Rules__c = total,
            Current_Rule_Name__c = currentRule
        );
        EventBus.publish(progressEvent);
    }
}
