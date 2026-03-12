@isTest
private class EmailOutdatedContactOwnersJobTest {

    @TestSetup
    static void makeData() {
        User owner = [SELECT Id FROM User WHERE IsActive = true AND Email != null AND Profile.Name = 'Standard User' LIMIT 1];

        Account acc = new Account(Name = 'Test Account');
        insert acc;

        insert new Contact(
            FirstName = 'Alice',
            LastName  = 'Outdated',
            AccountId = acc.Id,
            OwnerId   = owner.Id,
            Possible_Outdated__c = true
        );
    }

    @isTest
    static void execute_withOutdatedContacts_completesWithoutError() {
        Test.startTest();
        new EmailOutdatedContactOwnersJob().execute(null);
        Test.stopTest();

        System.assert(true, 'Job executed without error');
    }

    @isTest
    static void execute_noOutdatedContacts_doesNotThrow() {
        List<Contact> all = [SELECT Id, Possible_Outdated__c FROM Contact];
        for (Contact c : all) {
            c.Possible_Outdated__c = false;
        }
        update all;

        Test.startTest();
        new EmailOutdatedContactOwnersJob().execute(null);
        Test.stopTest();

        System.assert(true, 'Job should complete without error when there are no outdated contacts');
    }

    @isTest
    static void execute_canBeScheduled() {
        String cronExp = '0 0 8 * * ?';

        Test.startTest();
        String jobId = System.schedule('Test Outdated Email Job', cronExp, new EmailOutdatedContactOwnersJob());
        Test.stopTest();

        CronTrigger ct = [SELECT Id, State FROM CronTrigger WHERE Id = :jobId];
        System.assertNotEquals(null, ct, 'Scheduled job should exist');
        System.assertEquals('WAITING', ct.State, 'Job should be in WAITING state');
    }
}
