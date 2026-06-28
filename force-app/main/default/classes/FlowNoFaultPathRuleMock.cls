@isTest
global class FlowNoFaultPathRuleMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);

        String endpoint = req.getEndpoint();

        if (endpoint.contains('FlowDefinitionView')) {
            // First callout: list of active flows
            res.setBody('{"records":[{"ApiName":"Test_Flow","ActiveVersionId":"301xx0000000001"}]}');
        } else {
            // Second callout: flow metadata detail - missing fault connector on recordCreates
            res.setBody('{"Metadata":{"recordCreates":[{"name":"Create_Record","faultConnector":null}]}}');
        }

        return res;
    }
}
