public class SOQLInLoopRule implements IAuditRule {

    public List<AuditFinding> runCheck() {
        List<AuditFinding> findings = new List<AuditFinding>();

        String query = 'SELECT Name, Body FROM ApexClass WHERE NamespacePrefix = null';

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Sentinel_Tooling_API/services/data/v60.0/tooling/query/?q=' + EncodingUtil.urlEncode(query, 'UTF-8'));
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            findings.add(new AuditFinding(
                'SOQL In Loop',
                'High',
                'Code Quality',
                'N/A',
                'N/A',
                'Could not retrieve Apex class bodies. HTTP Status: ' + res.getStatusCode() + ' Body: ' + res.getBody(),
                'Verify Named Credential and Tooling API access for ApexClass.'
            ));
            return findings;
        }

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        List<Object> records = (List<Object>) responseMap.get('records');

        // Matches for/while loop opening, then checks if a SOQL keyword appears before the matching loop closes.
        // Simplified heuristic: flag if '[SELECT' or '[select' appears anywhere within ~300 chars after a loop opening brace.
        Pattern loopPattern = Pattern.compile('(?i)(for|while)\\s*\\([^)]*\\)\\s*\\{');

        for (Object recObj : records) {
            Map<String, Object> rec = (Map<String, Object>) recObj;
            String className = (String) rec.get('Name');
            String body = (String) rec.get('Body');

            if (String.isBlank(body)) continue;
            if (className.endsWith('Test') || className.endsWith('Mock')) continue; // skip test/mock classes

            Matcher loopMatcher = loopPattern.matcher(body);

            while (loopMatcher.find()) {
                Integer loopStart = loopMatcher.end();
                Integer windowEnd = Math.min(loopStart + 300, body.length());
                String windowText = body.substring(loopStart, windowEnd);

                if (windowText.containsIgnoreCase('[select') || windowText.containsIgnoreCase('[ select')) {
                    findings.add(new AuditFinding(
                        'SOQL In Loop',
                        'High',
                        'Code Quality',
                        'ApexClass',
                        className,
                        'Class ' + className + ' appears to have a SOQL query inside a for/while loop, risking governor limit exceptions.',
                        'Move the SOQL query outside the loop and use a Map or collection to look up data instead.'
                    ));
                    break; // one finding per class is enough
                }
            }
        }

        return findings;
    }
}
