@RestResource(urlMapping='/api/lead/*')
global with sharing class ApexRest {
    /**
     * Valid paths:
     * - /api/lead/id/...
     * - /api/lead/email/...
     */
    @HttpGet
    global static Lead getLead() {
        RestRequest request = RestContext.request;
        // part of the path after /api/lead/ up to the last slash
        String LeadFieldStr = request.requestURI.substringAfter('/api/lead/').substringBefore('/');
        LeadField field = LeadField.valueOf(LeadFieldStr.toUpperCase());
        String value = request.requestURI.substringAfter('/' + LeadFieldStr + '/');
        return getLeadBy(field, value);
    }

    private static Lead getLeadBy(LeadField field, String value) {
        switch on field {
            when ID {
                return getLeadById(value);
            }
            when EMAIL {
                return getLeadByEmail(value);
            }
            when else {
                throw new IllegalArgumentException('Invalid field: ' + field);
            }
        }
    }

    private static Lead getLeadById(String id) {
        return [
            SELECT Id, FirstName, LastName, Email
            FROM Lead
            WHERE Id = :id];
    }

    private static Lead getLeadByEmail(String email) {
        return [
            SELECT Id, FirstName, LastName, Email
            FROM Lead
            WHERE Email = :email];
    }

    private enum LeadField {
        ID,
        EMAIL
    }
}