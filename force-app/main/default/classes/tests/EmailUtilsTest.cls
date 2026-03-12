@isTest
private class EmailUtilsTest {

    @TestSetup
    static void makeData() {
        User owner = [SELECT Id FROM User WHERE IsActive = true AND Email != null AND Profile.Name = 'Standard User' LIMIT 1];

        Account acc = new Account(Name = 'Test Account');
        insert acc;

        insert new List<Contact>{
            new Contact(
                FirstName = 'Alice',
                LastName  = 'Outdated',
                AccountId = acc.Id,
                OwnerId   = owner.Id,
                Possible_Outdated__c = true
            ),
            new Contact(
                FirstName = 'Bob',
                LastName  = 'Outdated',
                AccountId = acc.Id,
                OwnerId   = owner.Id,
                Possible_Outdated__c = true
            )
        };
    }

    private static User getOwner() {
        return [SELECT Id, Email FROM User WHERE IsActive = true AND Email != null AND Profile.Name = 'Standard User' LIMIT 1];
    }

    private static Map<Id, List<Contact>> buildOwnerToContacts() {
        User owner = getOwner();
        List<Contact> contacts = [SELECT Id, Name, AccountId, OwnerId FROM Contact WHERE OwnerId = :owner.Id];
        return new Map<Id, List<Contact>>{ owner.Id => contacts };
    }

    @isTest
    static void buildOutdatedContactsEmails_withContacts_returnsOneEmailPerOwner() {
        Map<Id, List<Contact>> ownerToContacts = buildOwnerToContacts();

        Test.startTest();
        List<Messaging.SingleEmailMessage> emails = EmailUtils.buildOutdatedContactsEmails(ownerToContacts);
        Test.stopTest();

        System.assertEquals(1, emails.size(), 'Should produce one email for the one owner');
    }

    @isTest
    static void buildOutdatedContactsEmails_emailAddressedToOwner() {
        User owner = getOwner();
        Map<Id, List<Contact>> ownerToContacts = buildOwnerToContacts();

        Test.startTest();
        List<Messaging.SingleEmailMessage> emails = EmailUtils.buildOutdatedContactsEmails(ownerToContacts);
        Test.stopTest();

        System.assertEquals(owner.Email, emails[0].getToAddresses()[0], 'Email should be sent to the owner');
    }

    @isTest
    static void buildOutdatedContactsEmails_bodyContainsContactNames() {
        Map<Id, List<Contact>> ownerToContacts = buildOwnerToContacts();

        Test.startTest();
        List<Messaging.SingleEmailMessage> emails = EmailUtils.buildOutdatedContactsEmails(ownerToContacts);
        Test.stopTest();

        String body = emails[0].getHtmlBody();
        System.assert(body.contains('Alice Outdated'), 'Body should contain Alice\'s name');
        System.assert(body.contains('Bob Outdated'), 'Body should contain Bob\'s name');
    }

    @isTest
    static void buildOutdatedContactsEmails_bodyContainsContactLinks() {
        User owner = getOwner();
        List<Contact> contacts = [SELECT Id FROM Contact WHERE OwnerId = :owner.Id];
        Map<Id, List<Contact>> ownerToContacts = buildOwnerToContacts();

        Test.startTest();
        List<Messaging.SingleEmailMessage> emails = EmailUtils.buildOutdatedContactsEmails(ownerToContacts);
        Test.stopTest();

        String body = emails[0].getHtmlBody();
        for (Contact c : contacts) {
            System.assert(body.contains(c.Id), 'Body should contain a link with contact Id ' + c.Id);
        }
    }

    @isTest
    static void buildOutdatedContactsEmails_emptyMap_returnsEmptyList() {
        Test.startTest();
        List<Messaging.SingleEmailMessage> emails = EmailUtils.buildOutdatedContactsEmails(new Map<Id, List<Contact>>());
        Test.stopTest();

        System.assertEquals(0, emails.size(), 'Should return no emails for empty input');
    }

    @isTest
    static void buildOutdatedContactsEmails_subjectIsSet() {
        Map<Id, List<Contact>> ownerToContacts = buildOwnerToContacts();

        Test.startTest();
        List<Messaging.SingleEmailMessage> emails = EmailUtils.buildOutdatedContactsEmails(ownerToContacts);
        Test.stopTest();

        System.assertNotEquals(null, emails[0].getSubject(), 'Email subject should be set');
        System.assert(emails[0].getSubject().length() > 0, 'Email subject should not be empty');
    }

    @isTest
    static void buildOutdatedContactsEmails_ownerWithNoEmail_skipsOwner() {
        // Use a fake/non-existent owner Id so the User email lookup returns nothing,
        // causing String.isBlank(null) to be true and hitting the continue branch.
        Contact c = [SELECT Id, Name, OwnerId FROM Contact LIMIT 1];
        Id fakeOwnerId = '005000000000001AAA'; // valid Id format but no matching User
        Map<Id, List<Contact>> ownerToContacts = new Map<Id, List<Contact>>{
            fakeOwnerId => new List<Contact>{ c }
        };

        Test.startTest();
        List<Messaging.SingleEmailMessage> emails = EmailUtils.buildOutdatedContactsEmails(ownerToContacts);
        Test.stopTest();

        System.assertEquals(0, emails.size(), 'Should skip owners with no email and return empty list');
    }
}
