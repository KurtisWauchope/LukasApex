/**
 * @description       : Trigger for Opportunity object
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-05-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * uploaded to git
**/
trigger V11_OpportunityTrigger on Opportunity (
    before insert, after insert, 
    before update, after update,
    before delete, after delete
) {
    // Create handler instance
    V11_OpportunityTriggerHandler handler = new V11_OpportunityTriggerHandler();
    
    // Call appropriate methods based on trigger context
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            handler.beforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            handler.beforeUpdate(Trigger.new, Trigger.oldMap);
        } else if (Trigger.isDelete) {
            handler.beforeDelete(Trigger.old);
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.afterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            handler.afterUpdate(Trigger.new, Trigger.oldMap);
        } else if (Trigger.isDelete) {
            handler.afterDelete(Trigger.old);
        }
    }
}