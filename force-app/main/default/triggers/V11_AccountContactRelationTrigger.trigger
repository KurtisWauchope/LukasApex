trigger V11_AccountContactRelationTrigger on AccountContactRelation (
    before insert, after insert, 
    before update, after update, 
    before delete, after delete) {
  
    if (Trigger.isBefore) {
      if (Trigger.isInsert) {

      } 
      if (Trigger.isUpdate) {
        // Call class logic here!
        for(AccountContactRelation acr : Trigger.new){
          if(!acr.IsActive){
            List<AccountContactRelation> contactsACR = [SELECT Id FROM AccountContactRelation WHERE ContactId =: acr.ContactId AND IsActive = true];          
            if(contactsACR.size()<=1){
              acr.addError('There needs to be at least one active Account Contact Relation for the Contact!');
            }
          }
        }
      }
      if (Trigger.isDelete) {
        // Call class logic here!
      }
    }
  
    if (Trigger.isAfter) {

      if(!Test.isRunningTest()){
        if (Trigger.isInsert) {
          V11_CreateOutboundCall.insertAccountContactRelation(Trigger.new, 'create');
        } 
        if (Trigger.isUpdate) {
  
          V11_CreateOutboundCall.updateAccountContactRelation(Trigger.new, Trigger.oldMap);  
        }
        if (Trigger.isDelete) {
          V11_CreateOutboundCall.insertAccountContactRelation(Trigger.old, 'delete');
        }
            
      }

      

    }
}