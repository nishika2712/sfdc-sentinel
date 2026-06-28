public class UnusedTestCoverageRule implements IAuditRule {

    public List<AuditFinding> runCheck() {
        List<AuditFinding> findings = new List<AuditFinding>();

        String query = 'SELECT ApexClassOrTrigger.Name, NumLinesCovered, NumLinesUncovered ' +
                        'FROM ApexCodeCoverageAggregate';

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Sentinel_Tooling_API/services/data/v60.0/tooling/query/?q=' + EncodingUtil.urlEncode(query, 'UTF-8'));
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            findings.add(new AuditFinding(
                'Unused Test Coverage',
                'Medium',
                'Code Quality',
                'N/A',
                'N/A',
                'Could not retrieve code coverage data. HTTP Status: ' + res.getStatusCode() + ' Body: ' + res.getBody(),
                'Verify Named Credential and OAuth client configuration.'
            ));
            return findings;
        }

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        List<Object> records = (List<Object>) responseMap.get('records');

        for (Object recObj : records) {
            Map<String, Object> rec = (Map<String, Object>) recObj;
            Map<String, Object> classInfo = (Map<String, Object>) rec.get('ApexClassOrTrigger');
            String className = classInfo != null ? (String) classInfo.get('Name') : 'Unknown';

            Integer covered = rec.get('NumLinesCovered') != null ? Integer.valueOf(rec.get('NumLinesCovered')) : 0;
            Integer uncovered = rec.get('NumLinesUncovered') != null ? Integer.valueOf(rec.get('NumLinesUncovered')) : 0;
            Integer total = covered + uncovered;

            Decimal coveragePercent = total > 0 ? (Decimal.valueOf(covered) / Decimal.valueOf(total)) * 100 : 0;

            if (coveragePercent < 75) {
                findings.add(new AuditFinding(
                    'Unused Test Coverage',
                    'Medium',
                    'Code Quality',
                    'ApexClass',
                    className,
                    'Class ' + className + ' has ' + coveragePercent.setScale(1) + '% test coverage, below the 75% threshold.',
                    'Add or improve test methods for ' + className + ' to reach at least 75% coverage.'
                ));
            }
        }

        return findings;
    }
}
