@isTest
private class GetLeadByEmailTest {

    @TestSetup
    static void makeData() {
        insert new List<Lead>{
            new Lead(FirstName = 'Alice', LastName = 'Smith',  Email = 'alice@example.com', Company = 'Acme'),
            new Lead(FirstName = 'Bob',   LastName = 'Jones',  Email = 'bob@example.com',   Company = 'Globex')
        };
    }

    @isTest
    static void getLead_validEmail_returnsLead() {
        Test.startTest();
        Lead result = new GetLeadByEmail().getLead('alice@example.com');
        Test.stopTest();

        System.assertNotEquals(null, result, 'Expected a Lead to be returned');
        System.assertEquals('alice@example.com', result.Email, 'Email should match');
        System.assertEquals('Alice', result.FirstName, 'FirstName should match');
    }

    @isTest
    static void getLead_noMatch_throwsNoDataFoundException() {
        Test.startTest();
        try {
            new GetLeadByEmail().getLead('nobody@example.com');
            System.assert(false, 'Expected NoDataFoundException');
        } catch (NoDataFoundException e) {
            System.assert(true, 'NoDataFoundException thrown as expected');
        }
        Test.stopTest();
    }

    @isTest
    static void getLead_multipleMatches_throwsIllegalArgumentException() {
        // Bypass duplicate rules to insert a second Lead with the same email
        Lead dupe = new Lead(FirstName = 'Alice2', LastName = 'Smith2', Email = 'alice@example.com', Company = 'Dupe Co');
        Database.DmlOptions opts = new Database.DmlOptions();
        opts.DuplicateRuleHeader.AllowSave = true;
        Database.insert(dupe, opts);

        Test.startTest();
        try {
            new GetLeadByEmail().getLead('alice@example.com');
            System.assert(false, 'Expected IllegalArgumentException for duplicate emails');
        } catch (IllegalArgumentException e) {
            System.assert(
                e.getMessage().contains('Multiple Leads found'),
                'Exception message should mention multiple leads, got: ' + e.getMessage()
            );
        }
        Test.stopTest();
    }
}
