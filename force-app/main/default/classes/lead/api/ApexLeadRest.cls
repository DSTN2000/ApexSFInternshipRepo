/**
 * Valid paths:
 * - GET  /api/lead/id/{id}
 * - GET  /api/lead/email/{email}
 * - POST /api/lead/id/{id}/tasks
 * - POST /api/lead/email/{email}/tasks
 */
@RestResource(urlMapping='/api/lead/*')
global with sharing class ApexLeadRest {

    @HttpGet
    global static Lead getLead() {
        String afterPrefix = RestContext.request.requestURI.substringAfter('/api/lead/');
        String fieldKey = afterPrefix.substringBefore('/');
        String value = afterPrefix.substringAfter(fieldKey + '/').substringBefore('/');
        return GetLeadStrategyFactory.getStrategy(fieldKey).getLead(value);
    }

    @HttpPost
    global static Task createLeadTask() {
        Lead lead = getLead();

        TaskRequest taskRequest = (TaskRequest) JSON.deserialize(
            RestContext.request.requestBody.toString(),
            TaskRequest.class
        );

        Task t = new Task(
            WhoId = lead.Id,
            Subject = taskRequest.subject,
            Description = taskRequest.description,
            ActivityDate = taskRequest.activityDate,
            Priority = String.isBlank(taskRequest.priority) ? 'Normal' : taskRequest.priority
        );
        insert t;
        return t;
    }

    private class TaskRequest {
        String subject;
        String description;
        Date activityDate;
        String priority;
    }
}
