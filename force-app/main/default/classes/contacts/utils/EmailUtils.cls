public with sharing class EmailUtils {
    private static final String SUBJECT = 'The list of possible outdated Contacts that needs review!';
    private static final String BASE_URL = URL.getOrgDomainUrl().toExternalForm();

    public static List<Messaging.SingleEmailMessage> buildOutdatedContactsEmails(Map<Id, List<Contact>> ownerToContacts) {
        Map<Id, String> ownerEmails = new Map<Id, String>();
        for (User u : [SELECT Id, Email FROM User WHERE Id IN :ownerToContacts.keySet()]) {
            ownerEmails.put(u.Id, u.Email);
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Id ownerId : ownerToContacts.keySet()) {
            String ownerEmail = ownerEmails.get(ownerId);
            if (String.isBlank(ownerEmail)) {
                continue;
            }

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{ ownerEmail });
            email.setSubject(SUBJECT);
            email.setHtmlBody(buildHtmlBody(ownerToContacts.get(ownerId)));
            emails.add(email);
        }

        return emails;
    }

    private static String buildHtmlBody(List<Contact> contacts) {
        String body = '<p>Contacts that need review:</p><ul>';
        for (Contact c : contacts) {
            String contactUrl = BASE_URL + '/' + c.Id;
            body += '<li>Contact <a href="' + contactUrl + '">' + c.Name + '</a></li>';
        }
        body += '</ul>';
        return body;
    }
}
