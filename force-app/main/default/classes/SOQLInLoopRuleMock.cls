@isTest
global class SOQLInLoopRuleMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);

        String badBody = 'public class BadClass { void run() { for (Integer i = 0; i < 10; i++) { List<Account> accs = [SELECT Id FROM Account]; } } }';
        String goodBody = 'public class GoodClass { void run() { List<Account> accs = [SELECT Id FROM Account]; for (Account a : accs) { System.debug(a.Id); } } }';

        res.setBody('{"records":[' +
            '{"Name":"BadClass","Body":"' + badBody.replace('"', '\\\\"') + '"},' +
            '{"Name":"GoodClass","Body":"' + goodBody.replace('"', '\\\\"') + '"}' +
        ']}');

        return res;
    }
}
