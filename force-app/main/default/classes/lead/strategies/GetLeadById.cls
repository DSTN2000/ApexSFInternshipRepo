public with sharing class GetLeadById implements GetLeadStrategy {
    public Lead getLead(String value) {
        List<Lead> leads = [
            SELECT Id, FirstName, LastName, Email
            FROM Lead
            WHERE Id = :value
            LIMIT 1];
        if (leads.isEmpty()) {
            throw new NoDataFoundException();
        }
        return leads[0];
    }
}
