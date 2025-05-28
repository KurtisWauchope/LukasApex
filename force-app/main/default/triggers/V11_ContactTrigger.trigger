trigger V11_ContactTrigger on Contact (
    before insert, after insert, 
    before update, after update, 
    before delete, after delete) {

        if (Trigger.isBefore && !Test.isRunningTest()) {
            if (Trigger.isInsert) {
              // Call class logic here!
              
              for(contact c : trigger.new){
                  if(c.ExternalComarchContactId__c == null || c.ExternalComarchContactId__c == ''){
                      c.ExternalComarchContactId__c = V11_ComarchNumberManager.getNumber('Contact');
                  }
                
              }      
            
            }
            if (Trigger.isUpdate) {
              // Call class logic here!
            }
            if (Trigger.isDelete) {
              // Call class logic here!
            }
          }
        
          if (Trigger.isAfter && !Test.isRunningTest()) {
            if (Trigger.isInsert) {

                if(!Test.isRunningTest()){V11_CreateOutboundCall.insertContact(trigger.new, 'create');}
                
            } 
            if (Trigger.isUpdate ) {
                List<contact> contacts = new List<contact>();
                List<contact> newContacts = new List<contact>();
                List<contact> oldContacts = new List<contact>();

                for( Id contactId : Trigger.newMap.keySet() )
                {
                  if( Trigger.oldMap.get( contactId ).AccountId != Trigger.newMap.get( contactId ).AccountId )
                  {
                      contacts.add(Trigger.newMap.get( contactId ));
                  }        
                  if(Trigger.oldMap.get( contactId ).Salutation != Trigger.newMap.get( contactId ).Salutation||Trigger.oldMap.get( contactId ).Title__c != Trigger.newMap.get( contactId ).Title__c||Trigger.oldMap.get( contactId ).LastName != Trigger.newMap.get( contactId ).LastName||Trigger.oldMap.get( contactId ).FirstName != Trigger.newMap.get( contactId ).FirstName||Trigger.oldMap.get( contactId ).MiddleName != Trigger.newMap.get( contactId ).MiddleName||Trigger.oldMap.get( contactId ).MobilePhone != Trigger.newMap.get( contactId ).MobilePhone||Trigger.oldMap.get( contactId ).Phone != Trigger.newMap.get( contactId ).Phone||Trigger.oldMap.get( contactId ).Email != Trigger.newMap.get( contactId ).Email||Trigger.oldMap.get( contactId ).Language__c != Trigger.newMap.get( contactId ).Language__c){
                      newContacts.add(Trigger.newMap.get( contactId ));
                      oldContacts.add(Trigger.oldMap.get( contactId ));
                  }

                }
                if(newContacts.size()>0 && !Test.isRunningTest()){
                  V11_CreateOutboundCall.updateContact(newContacts, oldContacts);
                }
                
              
            }
                                                               
            if (Trigger.isDelete) {
              // Call class logic here!
            }
          }

}