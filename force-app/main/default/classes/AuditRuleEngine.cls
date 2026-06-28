public class AuditRuleEngine {

    public List<AuditFinding> runAllActiveRules() {
        List<AuditFinding> allFindings = new List<AuditFinding>();

        List<Audit_Rule__mdt> activeRules = [
            SELECT MasterLabel, Apex_Class_Name__c, Severity__c, Rule_Category__c, Description__c
            FROM Audit_Rule__mdt
            WHERE Is_Active__c = true
        ];

        for (Audit_Rule__mdt ruleConfig : activeRules) {
            List<AuditFinding> ruleFindings = runSingleRulePublic(ruleConfig);
            allFindings.addAll(ruleFindings);
        }

        return allFindings;
    }

    public List<AuditFinding> runSingleRulePublic(Audit_Rule__mdt ruleConfig) {
        List<AuditFinding> findings = new List<AuditFinding>();

        try {
            Type ruleType = Type.forName(ruleConfig.Apex_Class_Name__c);

            if (ruleType == null) {
                findings.add(new AuditFinding(
                    ruleConfig.MasterLabel,
                    'Medium',
                    'Engine Error',
                    'N/A',
                    ruleConfig.Apex_Class_Name__c,
                    'Could not find Apex class: ' + ruleConfig.Apex_Class_Name__c,
                    'Verify the Apex_Class_Name__c value on the Audit_Rule__mdt record matches an existing class implementing IAuditRule.'
                ));
                return findings;
            }

            Object instance = ruleType.newInstance();

            if (!(instance instanceof IAuditRule)) {
                findings.add(new AuditFinding(
                    ruleConfig.MasterLabel,
                    'Medium',
                    'Engine Error',
                    'N/A',
                    ruleConfig.Apex_Class_Name__c,
                    'Class ' + ruleConfig.Apex_Class_Name__c + ' does not implement IAuditRule.',
                    'Ensure the class implements the IAuditRule interface.'
                ));
                return findings;
            }

            IAuditRule rule = (IAuditRule) instance;
            findings = rule.runCheck();

        } catch (Exception e) {
            findings.add(new AuditFinding(
                ruleConfig.MasterLabel,
                'Medium',
                'Engine Error',
                'N/A',
                ruleConfig.Apex_Class_Name__c,
                'Rule execution failed: ' + e.getMessage(),
                'Check the Apex class for runtime errors and verify org configuration (e.g. Named Credentials).'
            ));
        }

        return findings;
    }
}
