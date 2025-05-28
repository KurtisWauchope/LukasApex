trigger V11_SystemsTrigger on Systems__c (
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

        List<String> bpIds = new List<String>();
        for(Systems__c sys : Trigger.new){
          if(sys.SystemUnit__c !=   'sqm'){
            bpIds.add(sys.BuildingProjectSystem__c);
          }            
        }
        V11_helperClass.updateBP(bpIds);  

      } 
      if (Trigger.isUpdate) {

        List<String> bpIds = new List<String>();
        for(Systems__c sys : Trigger.new){
          if(sys.SystemUnit__c !=   'sqm'){
            bpIds.add(sys.BuildingProjectSystem__c);
          }            
        }
        V11_helperClass.updateBP(bpIds);  

      }
      if (Trigger.isDelete) {

        List<String> bpIds = new List<String>();
        for(Systems__c sys : Trigger.old){
          if(sys.SystemUnit__c !=   'sqm'){
            bpIds.add(sys.BuildingProjectSystem__c);
          }            
        }
        V11_helperClass.updateBP(bpIds);        
        
      }
    }
}