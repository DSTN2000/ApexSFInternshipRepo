for (CronTrigger job : [SELECT Id, CronJobDetail.Name FROM CronTrigger]) {
    System.debug('Aborting: ' + job.CronJobDetail.Name + ' (' + job.Id + ')');
    System.abortJob(job.Id);
}
