UnusedTestCoverageRule rule = new UnusedTestCoverageRule();
List<AuditFinding> findings = rule.runCheck();
System.debug('Total findings: ' + findings.size());
for (AuditFinding f : findings) {
    System.debug(f.fieldOrComponentName + ' -> ' + f.issueDescription);
}
