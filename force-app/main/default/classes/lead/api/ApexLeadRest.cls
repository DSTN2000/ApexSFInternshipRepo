@RestResource(urlMapping='/api/lead/*')
global with sharing class ApexLeadRest {
    /**
     * Valid paths:
     * - /api/lead/id/...
     * - /api/lead/email/...
     */
    @HttpGet
    global static Lead getLead() {
        RestRequest request = RestContext.request;
        String afterPrefix = request.requestURI.substringAfter('/api/lead/');
        String fieldKey = afterPrefix.substringBefore('/');
        String value = afterPrefix.substringAfter(fieldKey + '/');

        GetLeadStrategy strategy = GetLeadStrategyFactory.getStrategy(fieldKey);
        return strategy.getLead(value);
    }
}
