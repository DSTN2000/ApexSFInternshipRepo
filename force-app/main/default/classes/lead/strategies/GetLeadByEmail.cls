public with sharing class GetLeadByEmail implements GetLeadStrategy {
    public Lead getLead(String value) {
        List<Lead> leads = [
            SELECT Id, FirstName, LastName, Email
            FROM Lead
            WHERE Email = :value];
        if (leads.isEmpty()) {
            throw new NoDataFoundException();
        }
        if (leads.size() > 1) {
            throw new IllegalArgumentException('Multiple Leads found with Email: ' + value);
        }
        return leads[0];
    }
}
