public with sharing class EmailOutdatedContactOwnersJob implements Schedulable {
    public void execute(SchedulableContext sc) {
        Map<Id, List<Contact>> ownerToContacts = ContactUtils.getOutdatedOwners();
        List<Messaging.SingleEmailMessage> emails = EmailUtils.buildOutdatedContactsEmails(ownerToContacts);
        sendEmails(emails);
    }
    
    private static void sendEmails(List<Messaging.SingleEmailMessage> emails) {
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails, false);
            System.debug('Sent ' + emails.size() + ' email(s).');
        } else {
            System.debug('No outdated contacts found — no emails sent.');
        }
    }
}