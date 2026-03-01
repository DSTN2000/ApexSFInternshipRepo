public with sharing class ContactUtils {
    public static Map<Id, List<Contact>> getOutdatedOwners() {
        Set<Id> activeUserIds = new Set<Id>();
        for (User u : [SELECT Id FROM User WHERE IsActive = true]) {
            activeUserIds.add(u.Id);
        }
        
        Map<Id, List<Contact>> userToOutdatedContacts = new Map<Id, List<Contact>>();
        for (Contact c : [SELECT Id, Name, AccountId, OwnerId, Possible_Outdated__c 
                      FROM Contact 
                      WHERE OwnerId IN :activeUserIds]) {
            if (c.Possible_Outdated__c == true) {
                if (!userToOutdatedContacts.containsKey(c.OwnerId)) {
                    userToOutdatedContacts.put(c.OwnerId, new List<Contact>());
                }
                userToOutdatedContacts.get(c.OwnerId).add(c);
            }
        }
        
        return userToOutdatedContacts;
    }
    
}