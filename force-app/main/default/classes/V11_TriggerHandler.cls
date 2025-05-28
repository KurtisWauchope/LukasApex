/**
 * @description       : Interface for all trigger handlers
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-05-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public interface V11_TriggerHandler {
    void beforeInsert(List<SObject> newRecords);
    void afterInsert(List<SObject> newRecords);
    void beforeUpdate(List<SObject> newRecords, Map<Id, SObject> oldRecordsMap);
    void afterUpdate(List<SObject> newRecords, Map<Id, SObject> oldRecordsMap);
    void beforeDelete(List<SObject> oldRecords);
    void afterDelete(List<SObject> oldRecords);
}