public with sharing class EmailOutdatedContactOwnersJobController {
    private static final String JOB_NAME = 'Outdated Contact Email Job';

    @AuraEnabled(cacheable=false)
    public static Map<String, String> getJobStatus() {
        CronTrigger job = [
            SELECT Id, CronExpression, State, NextFireTime
            FROM CronTrigger
            WHERE CronJobDetail.Name = :JOB_NAME
            LIMIT 1
        ];

        if (job == null) {
            return null;
        }

        return new Map<String, String>{
            'id'           => job.Id,
            'cronExpression' => job.CronExpression,
            'state'        => job.State,
            'nextFireTime' => job.NextFireTime != null ? String.valueOf(job.NextFireTime) : null
        };
    }

    @AuraEnabled
    public static void scheduleJob(String cronExpression) {
        abortExistingJob();
        System.schedule(JOB_NAME, cronExpression, new EmailOutdatedContactOwnersJob());
    }

    @AuraEnabled
    public static void unscheduleJob() {
        abortExistingJob();
    }

    @AuraEnabled
    public static void sendNow() {
        Map<Id, List<Contact>> ownerToContacts = ContactUtils.getOutdatedOwners();
        List<Messaging.SingleEmailMessage> emails = EmailUtils.buildOutdatedContactsEmails(ownerToContacts);
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails, false);
        }
    }

    private static void abortExistingJob() {
        List<CronTrigger> jobs = [
            SELECT Id FROM CronTrigger
            WHERE CronJobDetail.Name = :JOB_NAME
        ];
        for (CronTrigger job : jobs) {
            System.abortJob(job.Id);
        }
    }
}
