trigger V11_OutboundCallTrigger on  OutboundCall__c (
  before insert, after insert, 
  before update, after update, 
  before delete, after delete) {

  if (Trigger.isBefore) {
    if (Trigger.isInsert) {
      // Call class logic here!
    } 
    if (Trigger.isUpdate) {
      // Call class logic here!
    }
    if (Trigger.isDelete) {
      // Call class logic here!
    }
  }

  if (Trigger.isAfter) {
    if (Trigger.isInsert) {
        V11_CallComarchOutboundCalls.sendObject(trigger.new);

    } 
    if (Trigger.isUpdate) {
      // Call class logic here!
    }
    if (Trigger.isDelete) {
      // Call class logic here!
    }
  }
}