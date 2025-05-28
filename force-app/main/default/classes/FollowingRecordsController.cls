public with sharing class FollowingRecordsController {

    @AuraEnabled(cacheable=true)
    public static List<String> getSObjectFields(String objectName) {
        if (String.isBlank(objectName)) {
            throw new AuraHandledException('Object name cannot be empty');
        }

        DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        Map<String, SObjectField> fieldsMap = describeResult.fields.getMap();
        return new List<String>(fieldsMap.keySet());
    }

    @AuraEnabled(cacheable=true)
    public static List<SObject> getFollowingRecords(String objectName, List<String> fields, Map<String, String> filters) {
        if (fields == null || fields.isEmpty() || String.isBlank(objectName)) {
            throw new AuraHandledException('Fields or object name cannot be empty');
        }

        // Join fields into a single string for the SOQL query
        String fieldsQuery = String.join(fields, ', ');
        String currentUserId = UserInfo.getUserId(); // Fetch current user ID

        // Construct the base SOQL query
        String query = 'SELECT ' + fieldsQuery +
                       ' FROM ' + objectName +
                       ' WHERE Id IN (SELECT ParentId FROM EntitySubscription WHERE SubscriberId = :currentUserId)';

        // Append filter criteria to the WHERE clause dynamically
        if (filters != null && !filters.isEmpty()) {
            for (String field : filters.keySet()) {
                String filterValue = filters.get(field);
                if (!String.isEmpty(filterValue)) {
                    query += ' AND ' + field + ' = \'' + String.escapeSingleQuotes(filterValue) + '\'';
                }
            }
        }

        // Log the constructed query
        System.debug('Constructed SOQL Query: ' + query);

        // Execute the query
        List<SObject> records = Database.query(query);

        // Log the fetched records
        System.debug('Fetched Records: ' + records);

        return records;
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getPicklistValues(String objectName, String fieldName) {
        if (String.isBlank(objectName) || String.isBlank(fieldName)) {
            throw new AuraHandledException('Object name or field name cannot be empty');
        }
    
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe()
        .get(objectName)
        .getDescribe()
        .fields
        .getMap()
        .get(fieldName)
        .getDescribe();
    
    List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
    List<Map<String, String>> picklistValues = new List<Map<String, String>>();
    
    for (Schema.PicklistEntry entry : picklistEntries) {
        picklistValues.add(new Map<String, String>{
            'label' => entry.getLabel(),
            'value' => entry.getValue()
        });
    }
    return picklistValues;
}

    @AuraEnabled
    public static void unfollowRecord(String recordId) {
        if (String.isBlank(recordId)) {
            throw new AuraHandledException('Record ID cannot be null or empty.');
        }
    
        try {
            // Query the EntitySubscription for the current user and the given record
            List<EntitySubscription> subscriptions = [
                SELECT Id
                FROM EntitySubscription
                WHERE ParentId = :recordId 
                AND SubscriberId = :UserInfo.getUserId()
            ];
    
            if (!subscriptions.isEmpty()) {
                delete subscriptions; // Delete the subscriptions
            } else {
                throw new AuraHandledException('No subscription found for this record.');
            }
        } catch (DmlException e) {
            throw new AuraHandledException('Failed to unfollow record: ' + e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Unexpected error while unfollowing record: ' + e.getMessage());
        }
    }
}