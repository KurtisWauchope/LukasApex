trigger V11_BuildingProjectTeamTrigger on Building_Project_Team__c (
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
        
        for (Building_Project_Team__c bpTeam : Trigger.old)
        {
          if(bpTeam.Entitled_to_Commission__c){

              V11_CreateOutboundCall.insertCommissionEmployee(bpTeam, 'delete');
            
            }
        }

      }
    }
  
    if (Trigger.isAfter) {

      if (Trigger.isInsert) {

        
          for (Building_Project_Team__c bpTeam : Trigger.new)
          {
  
            if(bpTeam.Entitled_to_Commission__c){

              V11_CreateOutboundCall.insertCommissionEmployee(bpTeam, 'create');
            
            }
          }
        
        

        
      } 
      if (Trigger.isUpdate) {

        if(!Test.isRunningTest()){
          
          for (Building_Project_Team__c bpTeam : Trigger.new)
          {
            Building_Project_Team__c oldBpTeam = Trigger.OldMap.get(bpTeam.Id);          
          
            if(bpTeam.Entitled_to_Commission__c != oldBpTeam.Entitled_to_Commission__c ){

              V11_CreateOutboundCall.insertCommissionEmployee(bpTeam, 'create');
           
            }else if(bpTeam.Entitled_to_Commission__c && oldBpTeam.Entitled_to_Commission__c && bpTeam.User__c != oldBpTeam.User__c){
              
              V11_CreateOutboundCall.insertCommissionEmployee(bpTeam, 'update');

            }
              
            
          }
        }
        // Call class logic here!
      }
      if (Trigger.isDelete) {
             
        // Call class logic here!
      }
    }
}