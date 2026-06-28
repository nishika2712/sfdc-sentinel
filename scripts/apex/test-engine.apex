AuditRuleEngine engine = new AuditRuleEngine();
List<AuditFinding> findings = engine.runAllActiveRules();
System.debug('TOTAL FINDINGS ACROSS ALL RULES: ' + findings.size());
for (AuditFinding f : findings) {
    System.debug(f.ruleName + ' | ' + f.severity + ' | ' + f.objectApiName + '.' + f.fieldOrComponentName + ' -> ' + f.issueDescription);
}
