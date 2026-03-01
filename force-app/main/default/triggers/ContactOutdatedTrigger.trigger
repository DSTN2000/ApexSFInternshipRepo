trigger ContactOutdatedTrigger on Contact (after insert) {
    
    // Collect all Account IDs from newly inserted Contacts
    Set<Id> accountIds = new Set<Id>();
    for (Contact c : Trigger.new) {
        if (c.AccountId != null) {
            accountIds.add(c.AccountId);
        }
    }
    
    if (accountIds.isEmpty()) return;
    
    // Query all Contacts for those Accounts, ordered by CreatedDate (newest first)
    Map<Id, List<Contact>> accountContactsMap = new Map<Id, List<Contact>>();
    for (Contact c : [
        SELECT Id, AccountId, CreatedDate, Possible_Outdated__c 
        FROM Contact 
        WHERE AccountId IN :accountIds 
        ORDER BY CreatedDate DESC
    ]) {
        if (!accountContactsMap.containsKey(c.AccountId)) {
            accountContactsMap.put(c.AccountId, new List<Contact>());
        }
        accountContactsMap.get(c.AccountId).add(c);
    }
    
    List<Contact> contactsToUpdate = new List<Contact>();
    
    for (Id accId : accountContactsMap.keySet()) {
        List<Contact> contacts = accountContactsMap.get(accId);
        
        // Only process if more than 4 contacts
        if (contacts.size() <= 4) continue;
        
        // Contacts are ordered newest first
        // First 4 (newest) should NOT be marked outdated
        // Remaining (oldest) SHOULD be marked outdated
        for (Integer i = 0; i < contacts.size(); i++) {
            Contact c = contacts[i];
            if (i < 4) {
                // Newest 4 — unmark if previously marked
                if (c.Possible_Outdated__c == true) {
                    contactsToUpdate.add(new Contact(
                        Id = c.Id, 
                        Possible_Outdated__c = false
                    ));
                }
            } else {
                // Older than the 4 newest — mark as outdated
                if (c.Possible_Outdated__c == false) {
                    contactsToUpdate.add(new Contact(
                        Id = c.Id, 
                        Possible_Outdated__c = true
                    ));
                }
            }
        }
    }
    
    if (!contactsToUpdate.isEmpty()) {
        update contactsToUpdate;
    }
}