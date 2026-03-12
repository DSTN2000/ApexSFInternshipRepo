@isTest
private class EOCOJobControllerTest {

    private static final String JOB_NAME = 'Outdated Contact Email Job';
    private static final String CRON_EXPR = '0 0 8 * * ?';

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

    // ── scheduleJob ──────────────────────────────────────────────────────────

    @isTest
    static void scheduleJob_schedulesJobWithGivenCron() {
        Test.startTest();
        EmailOutdatedContactOwnersJobController.scheduleJob(CRON_EXPR);
        Test.stopTest();

        List<CronTrigger> jobs = [
            SELECT Id, CronExpression, State
            FROM CronTrigger
            WHERE CronJobDetail.Name = :JOB_NAME
        ];
        System.assertEquals(1, jobs.size(), 'Exactly one job should be scheduled');
        System.assertEquals(CRON_EXPR, jobs[0].CronExpression, 'Cron expression should match');
    }

    @isTest
    static void scheduleJob_replacesExistingJob() {
        System.schedule(JOB_NAME, '0 0 6 * * ?', new EmailOutdatedContactOwnersJob());

        Test.startTest();
        EmailOutdatedContactOwnersJobController.scheduleJob(CRON_EXPR);
        Test.stopTest();

        List<CronTrigger> jobs = [
            SELECT Id, CronExpression
            FROM CronTrigger
            WHERE CronJobDetail.Name = :JOB_NAME
        ];
        System.assertEquals(1, jobs.size(), 'Should have exactly one job after rescheduling');
        System.assertEquals(CRON_EXPR, jobs[0].CronExpression, 'New cron expression should be used');
    }

    // ── unscheduleJob ────────────────────────────────────────────────────────

    @isTest
    static void unscheduleJob_removesScheduledJob() {
        System.schedule(JOB_NAME, CRON_EXPR, new EmailOutdatedContactOwnersJob());

        Test.startTest();
        EmailOutdatedContactOwnersJobController.unscheduleJob();
        Test.stopTest();

        List<CronTrigger> jobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :JOB_NAME];
        System.assertEquals(0, jobs.size(), 'Job should be removed after unscheduling');
    }

    @isTest
    static void unscheduleJob_noExistingJob_doesNotThrow() {
        Test.startTest();
        EmailOutdatedContactOwnersJobController.unscheduleJob();
        Test.stopTest();

        System.assert(true, 'Unscheduling with no existing job should not throw');
    }

    // ── getJobStatus ─────────────────────────────────────────────────────────

    @isTest
    static void getJobStatus_withScheduledJob_returnsStatusMap() {
        System.schedule(JOB_NAME, CRON_EXPR, new EmailOutdatedContactOwnersJob());

        Test.startTest();
        Map<String, String> status = EmailOutdatedContactOwnersJobController.getJobStatus();
        Test.stopTest();

        System.assertNotEquals(null, status, 'Status should not be null when job is scheduled');
        System.assertNotEquals(null, status.get('id'), 'Status should include job id');
        System.assertEquals(CRON_EXPR, status.get('cronExpression'), 'Cron expression should match');
        System.assertNotEquals(null, status.get('state'), 'Status should include state');
    }

    @isTest
    static void getJobStatus_withNoScheduledJob_returnsNull() {
        Test.startTest();
        Map<String, String> status = EmailOutdatedContactOwnersJobController.getJobStatus();
        Test.stopTest();

        System.assertEquals(null, status, 'Should return null when no job is scheduled');
    }

    // ── sendNow ──────────────────────────────────────────────────────────────

    @isTest
    static void sendNow_withOutdatedContacts_doesNotThrow() {
        Test.startTest();
        EmailOutdatedContactOwnersJobController.sendNow();
        Test.stopTest();

        System.assert(true, 'sendNow should complete without error when outdated contacts exist');
    }

    @isTest
    static void sendNow_noOutdatedContacts_doesNotThrow() {
        List<Contact> all = [SELECT Id, Possible_Outdated__c FROM Contact];
        for (Contact c : all) {
            c.Possible_Outdated__c = false;
        }
        update all;

        Test.startTest();
        EmailOutdatedContactOwnersJobController.sendNow();
        Test.stopTest();

        System.assert(true, 'sendNow should complete without error when no outdated contacts exist');
    }
}
