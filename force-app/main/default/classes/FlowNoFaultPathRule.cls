public class FlowNoFaultPathRule implements IAuditRule {

    public List<AuditFinding> runCheck() {
        List<AuditFinding> findings = new List<AuditFinding>();

        String query = 'SELECT Id, ApiName, Label, ActiveVersionId ' +
                'FROM FlowDefinitionView WHERE IsActive = true AND ProcessType = \'Flow\'';

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Sentinel_Tooling_API/services/data/v60.0/query/?q=' + EncodingUtil.urlEncode(query, 'UTF-8'));
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            findings.add(new AuditFinding(
                'Flow No Fault Path',
                'Medium',
                'Automation',
                'N/A',
                'N/A',
                'Could not retrieve Flow data. HTTP Status: ' + res.getStatusCode() + ' Body: ' + res.getBody(),
                'Verify Named Credential and Tooling API access for FlowDefinitionView.'
            ));
            return findings;
        }

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        List<Object> records = (List<Object>) responseMap.get('records');

        for (Object recObj : records) {
            Map<String, Object> rec = (Map<String, Object>) recObj;
            String flowApiName = (String) rec.get('ApiName');
            String activeVersionId = (String) rec.get('ActiveVersionId');

            if (activeVersionId == null) continue;

            // Fetch the full Flow metadata for this version to inspect elements
            Boolean hasRiskyElementWithoutFault = checkFlowVersionForFaultPaths(activeVersionId);

            if (hasRiskyElementWithoutFault) {
                findings.add(new AuditFinding(
                    'Flow No Fault Path',
                    'Medium',
                    'Automation',
                    'Flow',
                    flowApiName,
                    'Flow ' + flowApiName + ' has one or more Record/Action elements with no fault connector defined.',
                    'Add a fault path to handle errors gracefully (e.g., log to a custom object or notify an admin) instead of failing silently.'
                ));
            }
        }

        return findings;
    }

    private Boolean checkFlowVersionForFaultPaths(String flowVersionId) {
        String endpoint = 'callout:Sentinel_Tooling_API/services/data/v60.0/tooling/sobjects/Flow/' + flowVersionId;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            return false;
        }

        Map<String, Object> flowData = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        Map<String, Object> metadata = (Map<String, Object>) flowData.get('Metadata');
        if (metadata == null) return false;

        List<String> riskyElementKeys = new List<String>{
            'recordCreates', 'recordUpdates', 'recordDeletes', 'actionCalls'
        };

        for (String key : riskyElementKeys) {
            Object elementsObj = metadata.get(key);
            if (elementsObj == null) continue;

            List<Object> elements = (List<Object>) elementsObj;
            for (Object elObj : elements) {
                Map<String, Object> element = (Map<String, Object>) elObj;
                if (!element.containsKey('faultConnector') || element.get('faultConnector') == null) {
                    return true;
                }
            }
        }

        return false;
    }
}
