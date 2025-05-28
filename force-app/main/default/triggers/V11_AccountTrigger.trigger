trigger V11_AccountTrigger on Account (
  before insert, after insert, 
  before update, after update, 
  before delete, after delete) {

  if (Trigger.isBefore && !Test.isRunningTest()) {
    if (Trigger.isInsert) {

      for(Account acc : trigger.new){

        if(acc.ComarchAccountNumber__c == null || acc.ComarchAccountNumber__c == ''){
            acc.ComarchAccountNumber__c = V11_ComarchNumberManager.getNumber('Account');
        }

      }
      

      // Call class logic here!
    } 
    if (Trigger.isUpdate) {
      /*for(Account acc:Trigger.new){
        if((acc.Name != trigger.oldMap.get(acc.Id).Name 
        || acc.BillingCity != trigger.oldMap.get(acc.Id).BillingCity 
        || acc.BillingCountryCode != trigger.oldMap.get(acc.Id).BillingCountryCode
        || acc.BillingStreet != trigger.oldMap.get(acc.Id).BillingStreet 
        || acc.BillingPostalCode != trigger.oldMap.get(acc.Id).BillingPostalCode
        || acc.ComarchAccountNumber__c != trigger.oldMap.get(acc.Id).ComarchAccountNumber__c) && !FeatureManagement.checkPermission('Change_Account')){
          acc.addError('This data can only be changed in comarch!');
        }
      }*/
      // Call class logic here!
    }
    if (Trigger.isDelete) {
      // Call class logic here!
    }
  }

  if (Trigger.isAfter && !Test.isRunningTest()) {
    if (Trigger.isInsert) {
      
        V11_AccountOwnerAssigner assigner = new V11_AccountOwnerAssigner(Trigger.new);
        assigner.assignAccountOwners();
        
        if(!Test.isRunningTest()){
            for(Account acc:Trigger.new){
              if(V11_helperClass.getIntegrationStatus('enaio')){
                V11_sendObjectToEnaio queue = new V11_sendObjectToEnaio(acc);
                System.enqueueJob(queue);
              }
              V11_CreateOutboundCall.insertAccount(acc.Id, 'create');
            }
        }
    } 
    if (Trigger.isUpdate) {
      for(Account acc : Trigger.new){
        if((acc.Phone != Trigger.oldMap.get(acc.Id).Phone ||
        acc.Fax != Trigger.oldMap.get(acc.Id).Fax ||  
        acc.Website != Trigger.oldMap.get(acc.Id).Website || 
        acc.Email__c != Trigger.oldMap.get(acc.Id).Email__c || 
        acc.Language__c != Trigger.oldMap.get(acc.Id).Language__c) && !FeatureManagement.checkPermission('Change_Account')){
          V11_CreateOutboundCall.updateAccount(acc, Trigger.oldMap.get(acc.Id));
        }
      }

    }
    if (Trigger.isDelete) {
      // Call class logic here!
    }
  }
}