public with sharing class ContactUtils {
    public static Map<Id, List<Contact>> getOutdatedOwners() {
        Map<Id, List<Contact>> userToOutdatedContacts = new Map<Id, List<Contact>>();
        for (Contact c : [SELECT Id, Name, AccountId, OwnerId
                          FROM Contact
                          WHERE Possible_Outdated__c = true
                          AND OwnerId IN (SELECT Id FROM User WHERE IsActive = true)]) {
            if (!userToOutdatedContacts.containsKey(c.OwnerId)) {
                userToOutdatedContacts.put(c.OwnerId, new List<Contact>());
            }
            userToOutdatedContacts.get(c.OwnerId).add(c);
        }

        return userToOutdatedContacts;
    }

}