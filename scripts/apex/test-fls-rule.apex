MissingFLSRule rule = new MissingFLSRule();
List<AuditFinding> findings = rule.runCheck();
System.debug('Total findings: ' + findings.size());
for (AuditFinding f : findings) {
    System.debug(f.objectApiName + '.' + f.fieldOrComponentName + ' -> ' + f.issueDescription);
}
