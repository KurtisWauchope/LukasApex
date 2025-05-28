trigger V11_AccountBuildingProjectRelationTrigger on AccountBuildingProjectRelation__c (
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
        for(AccountBuildingProjectRelation__c abpr : Trigger.new){
            bpIds.add(abpr.BuildingProject__c);
        }
        V11_helperClass.updateBP(bpIds);
        
  
      } 
      if (Trigger.isUpdate) {
        
        List<String> bpIds = new List<String>();
        for(AccountBuildingProjectRelation__c abpr : Trigger.new){
            bpIds.add(abpr.BuildingProject__c);
        }
        V11_helperClass.updateBP(bpIds);
        
      }
      if (Trigger.isDelete) {

        List<String> bpIds = new List<String>();
        for(AccountBuildingProjectRelation__c abpr : Trigger.old){
            bpIds.add(abpr.BuildingProject__c);
        }
        V11_helperClass.updateBP(bpIds);
        // Call class logic here!
      }
    }
}