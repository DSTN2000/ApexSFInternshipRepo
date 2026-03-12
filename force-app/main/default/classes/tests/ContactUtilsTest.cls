@isTest
private class ContactUtilsTest {

    @TestSetup
    static void makeData() {
        User owner = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'Standard User' LIMIT 1];

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
            ),
            new Contact(
                FirstName = 'Charlie',
                LastName  = 'Current',
                AccountId = acc.Id,
                OwnerId   = owner.Id,
                Possible_Outdated__c = false
            )
        };
    }

    private static User getOwner() {
        return [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'Standard User' LIMIT 1];
    }

    @isTest
    static void getOutdatedOwners_withOutdatedContacts_returnsOwnerMap() {
        Test.startTest();
        Map<Id, List<Contact>> result = ContactUtils.getOutdatedOwners();
        Test.stopTest();

        User owner = getOwner();
        System.assert(result.containsKey(owner.Id), 'Map should contain the owner');
        System.assertEquals(2, result.get(owner.Id).size(), 'Owner should have 2 outdated contacts');
    }

    @isTest
    static void getOutdatedOwners_excludesNonOutdatedContacts() {
        Test.startTest();
        Map<Id, List<Contact>> result = ContactUtils.getOutdatedOwners();
        Test.stopTest();

        Integer total = 0;
        for (List<Contact> contacts : result.values()) {
            total += contacts.size();
        }
        System.assertEquals(2, total, 'Only the 2 outdated contacts should be included');
    }

    @isTest
    static void getOutdatedOwners_noOutdatedContacts_returnsEmptyMap() {
        List<Contact> all = [SELECT Id, Possible_Outdated__c FROM Contact];
        for (Contact c : all) {
            c.Possible_Outdated__c = false;
        }
        update all;

        Test.startTest();
        Map<Id, List<Contact>> result = ContactUtils.getOutdatedOwners();
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Map should be empty when no contacts are outdated');
    }

    @isTest
    static void getOutdatedOwners_keysAreActiveUserIds() {
        Test.startTest();
        Map<Id, List<Contact>> result = ContactUtils.getOutdatedOwners();
        Test.stopTest();

        Set<Id> activeUserIds = new Map<Id, User>([SELECT Id FROM User WHERE IsActive = true]).keySet();
        for (Id ownerId : result.keySet()) {
            System.assert(activeUserIds.contains(ownerId), 'All owner keys should be active users');
        }
    }
}
