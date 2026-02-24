public with sharing class GetLeadStrategyFactory {
    private static final Map<String, GetLeadStrategy> REGISTRY =
        new Map<String, GetLeadStrategy>{
            'ID'    => new GetLeadById(),
            'EMAIL' => new GetLeadByEmail()
        };

    public static GetLeadStrategy getStrategy(String fieldKey) {
        GetLeadStrategy strategy = REGISTRY.get(fieldKey.toUpperCase());
        if (strategy == null) {
            throw new IllegalArgumentException('Invalid field: ' + fieldKey);
        }
        return strategy;
    }
}
