Map<Id, List<Contact>> ownerToContacts = ContactUtils.getOutdatedOwners();
System.debug('Owners with outdated contacts: ' + ownerToContacts.size());

List<Messaging.SingleEmailMessage> emails = EmailUtils.buildOutdatedContactsEmails(ownerToContacts);

for (Messaging.SingleEmailMessage email : emails) {
    System.debug('|EMAIL|');
    System.debug('To: ' + email.getToAddresses());
    System.debug('Subject: ' + email.getSubject());
    System.debug('Body: ' + email.getHtmlBody());
}

if (!emails.isEmpty()) {
    Messaging.sendEmail(emails, false);
    System.debug('Sent ' + emails.size() + ' email(s).');
} else {
    System.debug('No outdated contacts found — no emails sent.');
}
