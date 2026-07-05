public with sharing class TestCoverageService {

    @AuraEnabled
    public static String runAllTestsAsync() {
        try {
            // Use Tooling API to enqueue an async test run for all test classes
            String endpoint = 'callout:Sentinel_Tooling_API/services/data/v60.0/tooling/runTestsAsynchronous/';

            // Get all test class IDs in the org
            HttpRequest listReq = new HttpRequest();
            listReq.setEndpoint('callout:Sentinel_Tooling_API/services/data/v60.0/tooling/query/?q=' +
                EncodingUtil.urlEncode(
                    'SELECT Id, Name FROM ApexClass WHERE NamespacePrefix = null AND Name LIKE \'%Test%\'',
                    'UTF-8'
                )
            );
            listReq.setMethod('GET');
            listReq.setHeader('Content-Type', 'application/json');

            Http http = new Http();
            HttpResponse listRes = http.send(listReq);

            if (listRes.getStatusCode() != 200) {
                throw new AuraHandledException('Could not retrieve test classes: ' + listRes.getBody());
            }

            Map<String, Object> listData = (Map<String, Object>) JSON.deserializeUntyped(listRes.getBody());
            List<Object> records = (List<Object>) listData.get('records');

            List<String> classIds = new List<String>();
            for (Object rec : records) {
                Map<String, Object> recMap = (Map<String, Object>) rec;
                classIds.add((String) recMap.get('Id'));
            }

            if (classIds.isEmpty()) {
                return 'No test classes found in org.';
            }

            // Build the async test run request body
            Map<String, Object> requestBody = new Map<String, Object>{
                'classids' => String.join(classIds, ',')
            };

            HttpRequest runReq = new HttpRequest();
            runReq.setEndpoint(endpoint);
            runReq.setMethod('POST');
            runReq.setHeader('Content-Type', 'application/json');
            runReq.setBody(JSON.serialize(requestBody));

            HttpResponse runRes = http.send(runReq);

            if (runRes.getStatusCode() == 200 || runRes.getStatusCode() == 201) {
                String testRunId = runRes.getBody().replaceAll('"', '');
                return testRunId;
            } else {
                throw new AuraHandledException('Test run failed: ' + runRes.getBody());
            }

        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException('Unexpected error: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static String checkTestRunStatus(String testRunId) {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Sentinel_Tooling_API/services/data/v60.0/tooling/query/?q=' +
                EncodingUtil.urlEncode(
                    'SELECT Id, Status, ClassesCompleted, ClassesEnqueued, MethodsCompleted, MethodsFailed ' +
                    'FROM ApexTestRunResult WHERE AsyncApexJobId = \'' + testRunId + '\'',
                    'UTF-8'
                )
            );
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() != 200) {
                return 'ERROR';
            }

            Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> records = (List<Object>) data.get('records');

            if (records == null || records.isEmpty()) return 'Queued';

            Map<String, Object> result = (Map<String, Object>) records[0];
            return (String) result.get('Status');

        } catch (Exception e) {
            return 'ERROR';
        }
    }
}
