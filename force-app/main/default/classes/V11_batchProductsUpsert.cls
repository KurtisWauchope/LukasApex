global class V11_batchProductsUpsert implements Database.Batchable<V11_ProductExportData.Item>, Database.AllowsCallouts, Database.Stateful{

    List<Database.UpsertResult> upsertResults;
    Map<String,InboundCall__c> failedInboundCalls = new Map<String,InboundCall__c>();
    WebserviceLog__c wsLog;
    Map<String,String> keyValues;
    List<Id> insertedProducts = new List<Id>();
    List<V11_ProductExportData.Item> products;

    public V11_batchProductsUpsert(){

    }
    public V11_batchProductsUpsert(List<V11_ProductExportData.Item> products){
        this.products = products;
        wsLog = new WebserviceLog__c();
    }



    public List<V11_ProductExportData.Item> start (Database.BatchableContext bc)
    {
        List<InboundCall__c> ibc = [Select Object_ID__C, Id FROM InboundCall__c WHERE Object__c ='Product' and Status__c ='Error' and Outdated__c = false];
        for(InboundCall__c call : ibc)
        {
            failedInboundCalls.put(call.Object_ID__C,call);
        }
        wsLog = new WebserviceLog__c();
        keyValues = V11_KeyValueMap.createKeyValueMap('Product');
        if(products == null){
            products = V11_callComarchImport.importProducts(wsLog);
        }
        return products;

    }

    public void execute(Database.BatchableContext bc, List<V11_ProductExportData.Item> scope)
    {

        List<InboundCall__c> inboundCalls = new List<InboundCall__c>();
        List<InboundCall__c> inboundCallsWithErrors = new List<InboundCall__c>();
        List<InboundCall__c> updateCalls = new List<InboundCall__c>();
        List<Product2> products = new List<Product2>();
        

        for(V11_ProductExportData.Item ped: scope)
        {

            InboundCall__c inboundCall = new InboundCall__c();
            InboundCall__c updateCall = new InboundCall__c();
            inboundCall.Webservice_Log__c = wsLog.Id;
            Product2 product = new Product2();

            if(failedInboundCalls.containsKey(ped.guid)){
                updateCall = failedInboundCalls.get(ped.guid);
                updateCall.Outdated__c = true;
                updateCalls.add(updateCall);
            }

            inboundCall.Object__c = 'Product';
            inboundCall.Status__c = 'Pending';
            inboundCall.Object_ID__C = ped.guid;
            inboundCall.Data__c = JSON.serialize(ped);

            try{

                product.Name = ped.number_x;
                product.ExternalId__c = ped.number_x;
                product.ProductCode = ped.number_x;
                if(ped.description != null){
                    product.Short_Description_DE__c =ped.description.text[0]; 
                    product.Short_Description_EN__c =ped.description.text[1];
                    product.Short_Description_FR__c =ped.description.text[2];
                }if(ped.longDescription != null){                    
                    product.Long_Description_DE__c =ped.longDescription.text[0];
                    product.Long_Description_EN__c =ped.longDescription.text[1];
                    product.Long_Description_FR__c =ped.longDescription.text[2];
                }

                product.Status__c = keyValues.containsKey('Status__c'+ped.rai_prototypeStatus) ? keyValues.get('Status__c'+ped.rai_prototypeStatus):'';
                product.MaterialGroup__c = keyValues.containsKey('MaterialGroup__c'+ped.EntityExtension.WARENGRUPPE.classification) ?keyValues.get('MaterialGroup__c'+ped.EntityExtension.WARENGRUPPE.classification):'';
                product.ItemGroup__c = keyValues.containsKey('ItemGroup__c'+ped.EntityExtension.ARTIKELGRUPP.classification) ?keyValues.get('ItemGroup__c'+ped.EntityExtension.ARTIKELGRUPP.classification):'';
                product.ProductGroup__c = keyValues.containsKey('ProductGroup__c'+ped.EntityExtension.PRODUKTGRUPPE.classification) ?keyValues.get('ProductGroup__c'+ped.EntityExtension.PRODUKTGRUPPE.classification):'';
                product.ColorSurface__c = keyValues.containsKey('ColorSurface__c'+ped.EntityExtension.OBERFLAECHE_FARBE.classification) ?keyValues.get('ColorSurface__c'+ped.EntityExtension.OBERFLAECHE_FARBE.classification):'';
                product.Material__c = keyValues.containsKey('Material__c'+ped.EntityExtension.WERKSTOFF_NEU.classification) ?keyValues.get('Material__c'+ped.EntityExtension.WERKSTOFF_NEU.classification):'';
                product.BaseUnit__c = ped.Uoms != null? ped.Uoms[0].description.text:'';
                product.NetWeight__c = ped.measurements.netWeight != null? ped.measurements.netWeight.amount:'';
                product.ItemClassification__c = ped.Stc_Material != null? ped.Stc_Material.description.text[0]:'';
                product.LengthMax__c = ped.EntityExtension.LANGEMAXIMAL != null ? ped.EntityExtension.LANGEMAXIMAL.value:'';

            }catch(Exception e){

                inboundCall.Status__c = 'Error';
                inboundCall.ErrorMessage__c = e.getMessage();
                inboundCallsWithErrors.add(inboundCall);

            }
            if(inboundCall.Status__c == 'Pending'){

                inboundCalls.add(inboundCall);
                products.add(product);
            }



        }
        Schema.SObjectField Idfield = Product2.Fields.ExternalId__c;
        List<Database.UpsertResult> urList = Database.upsert(products,Idfield,false);

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
                if(urList[index].created){
                    insertedProducts.add(urList[index].getId());
                }
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