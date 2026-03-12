@isTest
private class GetLeadByIdTest {

    @TestSetup
    static void makeData() {
        insert new Lead(
            FirstName = 'Alice',
            LastName  = 'Smith',
            Email     = 'alice@example.com',
            Company   = 'Acme'
        );
    }

    private static Lead getAlice() {
        return [SELECT Id, FirstName, LastName, Email FROM Lead WHERE Email = 'alice@example.com' LIMIT 1];
    }

    @isTest
    static void getLead_validId_returnsLead() {
        Lead alice = getAlice();

        Test.startTest();
        Lead result = new GetLeadById().getLead(alice.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Expected a Lead to be returned');
        System.assertEquals(alice.Id, result.Id, 'Lead Id should match');
        System.assertEquals('Alice', result.FirstName, 'FirstName should match');
    }

    @isTest
    static void getLead_invalidId_throwsNoDataFoundException() {
        Test.startTest();
        try {
            new GetLeadById().getLead('00Q000000000001AAA');
            System.assert(false, 'Expected NoDataFoundException');
        } catch (NoDataFoundException e) {
            System.assert(true, 'NoDataFoundException thrown as expected');
        }
        Test.stopTest();
    }
}
