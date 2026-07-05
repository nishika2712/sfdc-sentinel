@isTest
global class AuditRuleEngineAllRulesMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);

        String endpoint = req.getEndpoint();

        if (endpoint.contains('ApexCodeCoverageAggregate')) {
            res.setBody('{"records":[]}');
        } else if (endpoint.contains('FlowDefinitionView')) {
            res.setBody('{"records":[]}');
        } else if (endpoint.contains('ApexClass')) {
            res.setBody('{"records":[]}');
        } else if (endpoint.contains('tooling/sobjects/Flow')) {
            res.setBody('{"Metadata":{"recordCreates":[]}}');
        } else {
            res.setBody('{"records":[]}');
        }

        return res;
    }
}
