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
        String leadFieldStr = request.requestURI.substringAfter('/api/lead/').substringBefore('/');
        LeadField field;
        try {
            field = LeadField.valueOf(leadFieldStr.toUpperCase());
        } catch (NoSuchElementException e) {
            throw new IllegalArgumentException('Invalid field: ' + leadFieldStr);
        }
        String value = request.requestURI.substringAfter('/' + leadFieldStr + '/');
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
        List<Lead> leads = [
            SELECT Id, FirstName, LastName, Email
            FROM Lead
            WHERE Id = :id
            LIMIT 1];
        if (leads.isEmpty()) {
            throw new NoDataFoundException('No Lead found with Id: ' + id);
        }
        return leads[0];
    }

    private static Lead getLeadByEmail(String email) {
        List<Lead> leads = [
            SELECT Id, FirstName, LastName, Email
            FROM Lead
            WHERE Email = :email];
        if (leads.isEmpty()) {
            throw new NoDataFoundException('No Lead found with Email: ' + email);
        }
        if (leads.size() > 1) {
            throw new IllegalArgumentException('Multiple Leads found with Email: ' + email);
        }
        return leads[0];
    }

    private enum LeadField {
        ID,
        EMAIL
    }
}