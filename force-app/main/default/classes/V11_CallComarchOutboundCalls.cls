public class V11_CallComarchOutboundCalls {

    public static void sendObject(List<OutboundCall__c> obcList){

        if(!V11_helperClass.getIntegrationStatus('comarch') && !Test.isRunningTest()){
            return;
        }
        
        for(OutboundCall__c obc :obcList){
            if(obc.Object__c =='Account'){
                V11_sendAccountToComarch queue = new V11_sendAccountToComarch(obc.Id,obc.Operation__c);
                System.enqueueJob(queue);
            }else if (obc.Object__c =='Building Project'){
                V11_sendBuildingProjectToComarch queue = new V11_sendBuildingProjectToComarch(obc.Id,obc.Operation__c);
                System.enqueueJob(queue);
            }else if (obc.Object__c =='Contact'){
                V11_sendContactToComarch queue = new V11_sendContactToComarch(obc.Id,obc.Operation__c);
                System.enqueueJob(queue);
            }else if (obc.Object__c =='Account Contact Relation'){
                V11_sendRelationsToComarch queue = new V11_sendRelationsToComarch(obc.Id,obc.Operation__c);
                System.enqueueJob(queue);
            }else if (obc.Object__c =='Outbound Commission Employee'){
                V11_sendCommissionEmployee queue = new V11_sendCommissionEmployee(obc.Id,obc.Operation__c);
                System.enqueueJob(queue);
            }
        }     
    }
    @AuraEnabled(cacheable=false)
    public static void resendObject(Id obcId){

        if(!V11_helperClass.getIntegrationStatus('comarch') && !Test.isRunningTest()){
            return;
        }
        OutboundCall__c obc = [SELECT Id, Object__c,Operation__c FROM OutboundCall__c WHERE Id=:obcId];        

            if(obc.Object__c =='Account'){
                V11_sendAccountToComarch queue = new V11_sendAccountToComarch(obc.Id,obc.Operation__c);
                System.enqueueJob(queue);
            }else if (obc.Object__c =='Building Project'){
                V11_sendBuildingProjectToComarch queue = new V11_sendBuildingProjectToComarch(obc.Id,obc.Operation__c);
                System.enqueueJob(queue);
            }else if (obc.Object__c =='Contact'){
                V11_sendContactToComarch queue = new V11_sendContactToComarch(obc.Id,obc.Operation__c);
                System.enqueueJob(queue);
            }else if (obc.Object__c =='Account Contact Relation'){
                V11_sendRelationsToComarch queue = new V11_sendRelationsToComarch(obc.Id,obc.Operation__c);
                System.enqueueJob(queue);
            }else if (obc.Object__c =='Outbound Commission Employee'){
                V11_sendCommissionEmployee queue = new V11_sendCommissionEmployee(obc.Id,obc.Operation__c);
                System.enqueueJob(queue);
            }
   
    }

}