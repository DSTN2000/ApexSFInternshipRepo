@isTest
private class GetLeadStrategyFactoryTest {

    @isTest
    static void getStrategy_idKey_returnsGetLeadById() {
        Test.startTest();
        GetLeadStrategy strategy = GetLeadStrategyFactory.getStrategy('id');
        Test.stopTest();

        System.assertNotEquals(null, strategy, 'Strategy should not be null for key "id"');
        System.assert(strategy instanceof GetLeadById, 'Strategy should be GetLeadById');
    }

    @isTest
    static void getStrategy_emailKey_returnsGetLeadByEmail() {
        Test.startTest();
        GetLeadStrategy strategy = GetLeadStrategyFactory.getStrategy('email');
        Test.stopTest();

        System.assertNotEquals(null, strategy, 'Strategy should not be null for key "email"');
        System.assert(strategy instanceof GetLeadByEmail, 'Strategy should be GetLeadByEmail');
    }

    @isTest
    static void getStrategy_caseInsensitive_returnsStrategy() {
        Test.startTest();
        GetLeadStrategy byUpperId    = GetLeadStrategyFactory.getStrategy('ID');
        GetLeadStrategy byMixedEmail = GetLeadStrategyFactory.getStrategy('Email');
        Test.stopTest();

        System.assert(byUpperId instanceof GetLeadById,       'Uppercase ID should resolve to GetLeadById');
        System.assert(byMixedEmail instanceof GetLeadByEmail, 'Mixed-case Email should resolve to GetLeadByEmail');
    }

    @isTest
    static void getStrategy_invalidKey_throwsIllegalArgumentException() {
        Test.startTest();
        try {
            GetLeadStrategyFactory.getStrategy('phone');
            System.assert(false, 'Expected IllegalArgumentException for unknown key');
        } catch (IllegalArgumentException e) {
            System.assert(
                e.getMessage().contains('Invalid field'),
                'Exception message should reference invalid field, got: ' + e.getMessage()
            );
        }
        Test.stopTest();
    }
}
