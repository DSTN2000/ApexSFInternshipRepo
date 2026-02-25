@isTest
private class ApexLeadRestTest {

    /**
     * Inserts shared Lead test data used across all test methods.
     */
    @TestSetup
    static void makeData() {
        List<Lead> leads = new List<Lead>{
            new Lead(
                FirstName = 'Alice',
                LastName  = 'Smith',
                Email     = 'alice@example.com',
                Company   = 'Acme'
            ),
            new Lead(
                FirstName = 'Bob',
                LastName  = 'Jones',
                Email     = 'bob@example.com',
                Company   = 'Globex'
            )
        };
        insert leads;
    }

    /**
     * Builds a RestRequest and wires it into RestContext.
     *
     * @param method HTTP method (GET, POST, etc.)
     * @param uri    Request URI
     * @param body   Request body JSON, or null
     */
    private static void setRequest(String method, String uri, String body) {
        RestRequest req  = new RestRequest();
        req.httpMethod   = method;
        req.requestURI   = uri;
        if (body != null) {
            req.requestBody = Blob.valueOf(body);
        }
        RestContext.request  = req;
        RestContext.response = new RestResponse();
    }

    /** @return Alice's Lead record. */
    private static Lead getAlice() {
        return [SELECT Id, FirstName, LastName, Email FROM Lead WHERE Email = 'alice@example.com' LIMIT 1];
    }

    /** @return Bob's Lead record. */
    private static Lead getBob() {
        return [SELECT Id, FirstName, LastName, Email FROM Lead WHERE Email = 'bob@example.com' LIMIT 1];
    }

    @isTest
    static void getLead_byId_returnsCorrectLead() {
        Lead alice = getAlice();
        setRequest('GET', '/api/lead/id/' + alice.Id, null);

        Test.startTest();
        Lead result = ApexLeadRest.getLead();
        Test.stopTest();

        System.assertNotEquals(null, result, 'Expected a Lead to be returned');
        System.assertEquals(alice.Id, result.Id, 'Lead Id should match');
        System.assertEquals('Alice', result.FirstName, 'FirstName should be Alice');
    }

    @isTest
    static void getLead_byEmail_returnsCorrectLead() {
        setRequest('GET', '/api/lead/email/alice@example.com', null);

        Test.startTest();
        Lead result = ApexLeadRest.getLead();
        Test.stopTest();

        System.assertNotEquals(null, result, 'Expected a Lead to be returned');
        System.assertEquals('alice@example.com', result.Email, 'Email should match');
    }

    @isTest
    static void getLead_invalidFieldKey_throwsIllegalArgumentException() {
        setRequest('GET', '/api/lead/phone/5551234567', null);

        Test.startTest();
        try {
            ApexLeadRest.getLead();
            System.assert(false, 'Expected IllegalArgumentException to be thrown');
        } catch (IllegalArgumentException e) {
            System.assert(
                e.getMessage().contains('Invalid field'),
                'Exception message should reference invalid field, got: ' + e.getMessage()
            );
        }
        Test.stopTest();
    }

    @isTest
    static void getLead_byId_notFound_throwsNoDataFoundException() {
        setRequest('GET', '/api/lead/id/00Q000000000001AAA', null);

        Test.startTest();
        try {
            ApexLeadRest.getLead();
            System.assert(false, 'Expected NoDataFoundException to be thrown');
        } catch (NoDataFoundException e) {
            System.assert(true, 'NoDataFoundException was thrown as expected');
        }
        Test.stopTest();
    }

    @isTest
    static void createLeadTask_byId_insertsTaskWithCorrectWhoId() {
        Lead alice = getAlice();
        String body = JSON.serialize(new Map<String, Object>{
            'subject'      => 'Follow up call',
            'description'  => 'Discuss the proposal',
            'activityDate' => '2026-03-01',
            'priority'     => 'High'
        });
        setRequest('POST', '/api/lead/id/' + alice.Id + '/tasks', body);

        Test.startTest();
        Task result = ApexLeadRest.createLeadTask();
        Test.stopTest();

        System.assertNotEquals(null, result, 'Expected a Task to be returned');
        System.assertNotEquals(null, result.Id, 'Task should have been inserted');
        System.assertEquals(alice.Id, result.WhoId, 'WhoId should match the Lead Id');
        System.assertEquals('Follow up call', result.Subject, 'Subject should match');
        System.assertEquals('High', result.Priority, 'Priority should match');
    }

    @isTest
    static void createLeadTask_byEmail_insertsTask() {
        Lead bob = getBob();
        String body = JSON.serialize(new Map<String, Object>{
            'subject'      => 'Intro meeting',
            'description'  => 'Initial contact',
            'activityDate' => '2026-03-15',
            'priority'     => 'Normal'
        });
        setRequest('POST', '/api/lead/email/bob@example.com/tasks', body);

        Test.startTest();
        Task result = ApexLeadRest.createLeadTask();
        Test.stopTest();

        System.assertNotEquals(null, result.Id, 'Task should have been inserted');
        System.assertEquals(bob.Id, result.WhoId, 'WhoId should match Bob\'s Lead Id');
        System.assertEquals('Intro meeting', result.Subject, 'Subject should match');
    }

    @isTest
    static void createLeadTask_priorityOmitted_defaultsToNormal() {
        Lead alice = getAlice();
        String body = JSON.serialize(new Map<String, Object>{
            'subject'     => 'No priority task',
            'description' => 'Should default to Normal'
        });
        setRequest('POST', '/api/lead/id/' + alice.Id + '/tasks', body);

        Test.startTest();
        Task result = ApexLeadRest.createLeadTask();
        Test.stopTest();

        System.assertEquals('Normal', result.Priority, 'Priority should default to Normal when omitted');
    }

    @isTest
    static void createLeadTask_invalidFieldKey_throwsIllegalArgumentException() {
        String body = JSON.serialize(new Map<String, Object>{
            'subject' => 'Should not be created'
        });
        setRequest('POST', '/api/lead/phone/5551234567/tasks', body);

        Test.startTest();
        try {
            ApexLeadRest.createLeadTask();
            System.assert(false, 'Expected IllegalArgumentException to be thrown');
        } catch (IllegalArgumentException e) {
            System.assert(
                e.getMessage().contains('Invalid field'),
                'Exception message should reference invalid field, got: ' + e.getMessage()
            );
        }
        Test.stopTest();
    }
}
