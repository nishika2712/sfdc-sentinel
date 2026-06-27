public class AuditFinding {
    public String ruleName;
    public String severity;
    public String category;
    public String objectApiName;
    public String fieldOrComponentName;
    public String issueDescription;
    public String remediationGuidance;

    public AuditFinding(String ruleName, String severity, String category, String objectApiName,
                         String fieldOrComponentName, String issueDescription, String remediationGuidance) {
        this.ruleName = ruleName;
        this.severity = severity;
        this.category = category;
        this.objectApiName = objectApiName;
        this.fieldOrComponentName = fieldOrComponentName;
        this.issueDescription = issueDescription;
        this.remediationGuidance = remediationGuidance;
    }
}
