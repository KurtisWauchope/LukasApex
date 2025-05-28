/**
 * @description       : Helper class for triggers to prevent recursion
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-05-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class V11_TriggerHelper {
    // Set to track which trigger operations have been processed in the current transaction
    private static Set<String> processedOperations = new Set<String>();
    
    /**
     * Mark a trigger operation as processed to prevent recursion
     * @param operationName The name of the operation to mark as processed
     */
    public static void markAsProcessed(String operationName) {
        System.debug('🔒 Marking trigger operation as processed: ' + operationName);
        processedOperations.add(operationName);
    }
    
    /**
     * Check if a trigger operation has already been processed
     * @param operationName The name of the operation to check
     * @return True if the operation has already been processed, false otherwise
     */
    public static Boolean hasAlreadyProcessed(String operationName) {
        Boolean processed = processedOperations.contains(operationName);
        if (processed) {
            System.debug('⚠️ Skipping already processed trigger operation: ' + operationName);
        }
        return processed;
    }
    
    /**
     * Reset all processed operations (useful for test methods)
     */
    public static void resetProcessedOperations() {
        System.debug('🔄 Resetting all processed trigger operations');
        processedOperations.clear();
    }
    
    /**
     * Alias for resetProcessedOperations - used in V11_BuildingProjectResetService
     */
    public static void clearProcessed() {
        resetProcessedOperations();
    }
    
    /**
     * Check if all records in a list have the same value for a specified field
     * @param recordList The list of records to check
     * @param fieldName The name of the field to check
     * @return True if all records have the same value for the field, false otherwise
     */
    public static Boolean allRecordsHaveSameFieldValue(List<SObject> recordList, String fieldName) {
        if (recordList == null || recordList.isEmpty()) {
            System.debug('⚠️ No records to check for field value: ' + fieldName);
            return true;
        }
        
        Object firstValue = recordList[0].get(fieldName);
        System.debug('🔍 Checking if all records have same value for ' + fieldName + ': ' + firstValue);
        
        for (SObject record : recordList) {
            if (record.get(fieldName) != firstValue) {
                System.debug('❌ Found different value for ' + fieldName + ': ' + record.get(fieldName));
                return false;
            }
        }
        
        System.debug('✅ All records have same value for ' + fieldName + ': ' + firstValue);
        return true;
    }
    
    /**
     * Track a field change between old and new versions of records
     * @param newRecords List of new SObject records (e.g., Trigger.new)
     * @param oldRecordsMap Map of old SObject records by ID (e.g., Trigger.oldMap)
     * @param fieldName Name of the field to track changes for
     * @return Map with record IDs as keys and a list of old and new values as values (List[0] = old, List[1] = new)
     */
    public static Map<Id, List<Object>> trackFieldChanges(List<SObject> newRecords, Map<Id, SObject> oldRecordsMap, String fieldName) {
        Map<Id, List<Object>> changesMap = new Map<Id, List<Object>>();
        
        for (SObject newRecord : newRecords) {
            Id recordId = (Id)newRecord.get('Id');
            SObject oldRecord = oldRecordsMap.get(recordId);
            
            if (oldRecord != null) {
                Object oldValue = oldRecord.get(fieldName);
                Object newValue = newRecord.get(fieldName);
                
                if (oldValue != newValue) {
                    changesMap.put(recordId, new List<Object>{oldValue, newValue});
                    System.debug('📝 Field ' + fieldName + ' changed for record ' + recordId + ': ' + oldValue + ' -> ' + newValue);
                }
            }
        }
        
        System.debug('🔄 Tracked ' + changesMap.size() + ' changes for field: ' + fieldName);
        return changesMap;
    }
}