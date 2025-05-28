global class V11_batchEntityExtensionUpsert implements Database.Batchable<V11_EntityExtensionExportData.EntityExtensionHierarchy>, Database.AllowsCallouts, Database.Stateful{

    List<Database.UpsertResult> upsertResults;
    Map<String,InboundCall__c> failedInboundCalls = new Map<String,InboundCall__c>();
    WebserviceLog__c wsLog;
    List<V11_EntityExtensionExportData.EntityExtensionHierarchy> entityExtensions;

    public V11_batchEntityExtensionUpsert (){}
    public V11_batchEntityExtensionUpsert (List<V11_EntityExtensionExportData.EntityExtensionHierarchy> entityExtensions){
        this.entityExtensions = entityExtensions;
        wsLog = new WebserviceLog__c();
    }


    public List<V11_EntityExtensionExportData.EntityExtensionHierarchy> start (Database.BatchableContext bc)
    {
        List<InboundCall__c> ibc = [Select Object_ID__C, Id FROM InboundCall__c WHERE Object__c ='Entity Extension' and Status__c ='Error' and Outdated__c = false];
        for(InboundCall__c call : ibc)
        {
            failedInboundCalls.put(call.Object_ID__C,call);
        }
        if(entityExtensions==null){
            wsLog = new WebserviceLog__c();
            entityExtensions=V11_callComarchImport.importEntityExtension(wsLog);
        }
        
        return entityExtensions;

    }

    public void execute(Database.BatchableContext bc, List<V11_EntityExtensionExportData.EntityExtensionHierarchy> scope)
    {

        List<InboundCall__c> inboundCalls = new List<InboundCall__c>();
        List<InboundCall__c> inboundCallsWithErrors = new List<InboundCall__c>();
        List<InboundCall__c> updateCalls = new List<InboundCall__c>();
        List<KeyValuePair__c> kvpList = new List<KeyValuePair__c>();
        
        

        for(V11_EntityExtensionExportData.EntityExtensionHierarchy entity: scope)
        {

            InboundCall__c inboundCall = new InboundCall__c();
            InboundCall__c updateCall = new InboundCall__c();
            inboundCall.Webservice_Log__c = wsLog.Id;
            KeyValuePair__c kvp = new KeyValuePair__c();

            if(failedInboundCalls.containsKey(entity.guid)){
                updateCall = failedInboundCalls.get(entity.guid);
                updateCall.Outdated__c = true;
                updateCalls.add(updateCall);
            }

            inboundCall.Object__c = 'Entity Extension';
            inboundCall.Status__c = 'Pending';
            inboundCall.Object_ID__C = entity.guid;
            inboundCall.Data__c = JSON.serialize(entity);    

            try{
                if(entity.datatype == 'Oberfläche/Farbe'){
                    kvp.Object__c = 'Product';
                    kvp.Field__c = 'ColorSurface__c';

                }else{
                    switch on entity.datatype{
                        when 'Artikelgruppe'{
                            kvp.Object__c = 'Product';
                            kvp.Field__c = 'ItemGroup__c';
                        }
                        when 'Produktgruppe'{
                            kvp.Object__c = 'Product';
                            kvp.Field__c = 'ProductGroup__c';
                        }
                        when 'Warengruppe'{
                            kvp.Object__c = 'Product';
                            kvp.Field__c = 'MaterialGroup__c';
                        }
                        when 'Werkstoff'{
                            kvp.Object__c = 'Product';
                            kvp.Field__c = 'Material__c';
                        }when else{
                            continue;
                        }
                    }
                }           
              
                kvp.External_Id__c = entity.guid;
                kvp.Key__c = entity.path;
                kvp.Value__c = entity.description.text[0];



            }catch(Exception e){

                inboundCall.Status__c = 'Error';
                inboundCall.ErrorMessage__c = e.getMessage();
                inboundCallsWithErrors.add(inboundCall);

            }
            if(inboundCall.Status__c == 'Pending'){

                inboundCalls.add(inboundCall);
                kvpList.add(kvp);
            }



        }
        Schema.SObjectField Idfield = KeyValuePair__c.Fields.External_Id__c;
        List<Database.UpsertResult> urList = Database.upsert(kvpList,Idfield,false);

        for(Integer index = 0, size = urList.size();index<size;index++)
        {
            if(!urList[index].success)
            {
                inboundCalls[index].Status__c = 'Error';
                String errorMessages;
                for(Database.Error error : urList[index].getErrors()){
                    errorMessages = errorMessages + '\n'+ error.message;
                }
                inboundCalls[index].ErrorMessage__c = errorMessages;
            }else
            {
                inboundCalls[index].Status__c = 'Success';
            }            

        }
        inboundCalls.addAll(inboundCallsWithErrors);
        insert inboundCalls;
        update updateCalls;
    }

    global void finish(Database.BatchableContext bc)
    {

    }
}