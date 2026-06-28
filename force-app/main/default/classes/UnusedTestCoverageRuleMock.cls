@isTest
global class UnusedTestCoverageRuleMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody('{"records":[{"ApexClassOrTrigger":{"Name":"SomeClass"},"NumLinesCovered":2,"NumLinesUncovered":8}]}');
        return res;
    }
}
