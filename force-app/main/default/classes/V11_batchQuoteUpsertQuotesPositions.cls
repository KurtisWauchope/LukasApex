global class V11_batchQuoteUpsertQuotesPositions implements Database.Batchable<V11_QuoteExportData.CustomerProposal>, Database.AllowsCallouts, Database.Stateful {

    Map<String,InboundCall__c> inboundCallsMap = new Map<String,InboundCall__c>();
    List<V11_QuoteExportData.CustomerProposal> cProps;
    List<InboundCall__c> ibcs;
    Map<String,String> keyValues;
    Set<String> externalProIds = new Set<String>();

    public V11_batchQuoteUpsertQuotesPositions(List<V11_QuoteExportData.CustomerProposal> cProps, List<InboundCall__c> ibcs){
        this.cProps = cProps;
        this.ibcs = ibcs;
    }


    public List<V11_QuoteExportData.CustomerProposal> start (Database.BatchableContext bc)
    {
        for(Integer index = 0, size = ibcs.size();index<size;index++){
            inboundCallsMap.put(cProps[index].guid,ibcs[index]);
        }
        List<String> prodIds = new List<String>();
        for(V11_QuoteExportData.CustomerProposal cprop : Cprops){
            for(V11_QuoteExportData.CustomerProposal_Details detail : cprop.Details){
                prodIds.add(detail.Item.number_x);
            }
        }
        List<Product2> products = [SELECT ExternalId__c FROM Product2 WHERE  ExternalId__c IN:prodIds];
        for(Product2 prod :products){
            externalProIds.add(prod.ExternalId__c);
        }
        keyValues = V11_KeyValueMap.createKeyValueMap('Quote Position');
        return cProps;

    }

    
    public void execute(Database.BatchableContext bc, List<V11_QuoteExportData.CustomerProposal> scope)
    {

        List<InboundCall__c> inboundCalls = new List<InboundCall__c>();
        List<InboundCall__c> inboundCallsWithErrors = new List<InboundCall__c>();
        List<Quote_Position__c> qlis = new List<Quote_Position__c>();
    
        

        for(V11_QuoteExportData.CustomerProposal qed: scope)
        {

            InboundCall__c ibc = inboundCallsMap.get(qed.guid);
            List<Quote_Position__c> qItems = new List<Quote_Position__c>();

            try{

                if(qed.Details != null){
                    Quote quote = new Quote(Name = qed.number_x);

                    for(V11_QuoteExportData.CustomerProposal_Details detail : qed.Details){

                        Quote_Position__c item = new Quote_Position__c(ExternalId__c = detail.guid);

                        if(externalProIds.contains(detail.Item.number_x)){

                            Product2 pro = new Product2(ExternalId__c = detail.Item.number_x);
                            item.Product__r = pro;
                            item.Note__c = '';

                        }else{
                            item.Note__c = 'Product does not exist in Salesforce!';
                        }

                        item.Quote__r = quote;                    
                        item.Name = String.valueOf(detail.number_x);
                        
                        item.Quantity__c = Decimal.valueOf(detail.totalQuantity.amount);
                        item.DeliveryDate__c = date.newInstance(detail.deliveryDate.year(), detail.deliveryDate.month(), detail.deliveryDate.day());
                        list<string> preferredDate = detail.preferredDate.value.split('#');
                        item.PreferredDate__c = date.newInstance(Integer.valueOf(preferredDate[2]), Integer.valueOf(preferredDate[1]), Integer.valueOf(preferredDate[0]));
                        item.TotalPrice__c = Decimal.valueOf(detail.totalValues.grossValue.amount);
                        item.GrossPrice__c = Decimal.valueOf(detail.grossPrice.amount);
                        item.Type__c = keyValues.get('Type__c'+detail.rai_positionType); //STANDARD & ALTERNATIVE
                        
                        qItems.add(item);
                    } 
                }
           

            }catch(Exception e){

                ibc.Status__c = 'Error';
                ibc.ErrorMessage__c = ' | C3 Quote Positions | '+ e.getLineNumber()+' | '+e.getMessage();
                inboundCallsWithErrors.add(ibc);

            }
            if(ibc.Status__c == 'Pending'){

                for(Quote_Position__c item :qItems){
                    inboundCalls.add(ibc);
                    qlis.add(item);
                }
            }




        }


        Schema.SObjectField Idfield = Quote_Position__c.Fields.ExternalId__c;
        List<Database.UpsertResult> urList = Database.upsert(qlis,Idfield,false);
        Set<InboundCall__c> inboundCallsSet = new Set<InboundCall__c>();
        Set<InboundCall__c> ibcSuccess = new Set<InboundCall__c>();
        List<InboundCall__c> inboundCallsToUpdate = new List<InboundCall__c>();

        for(Integer index = 0, size = urList.size();index<size;index++)
        {
            if(!urList[index].success)
            {
                inboundCalls[index].Status__c = 'Error';
                String errorMessages = 'Position'+(index+1)+': ';
                for(Database.Error error : urList[index].getErrors()){
                    errorMessages = errorMessages + '\n'+ error.message;
                }
                if(index-1>=0){
                    if(inboundCalls[index-1].Id == inboundCalls[index].Id ){
                        inboundCalls[index].ErrorMessage__c = inboundCalls[index-1].ErrorMessage__c + errorMessages;
                        if(index == urList.size()-1){
                            inboundCallsSet.add(inboundCalls[index]);
                        }
    
                    }else{                        
                        inboundCalls[index].ErrorMessage__c = errorMessages;
                        inboundCallsSet.add(inboundCalls[index-1]);
                    }
                }else{
                    inboundCalls[index].ErrorMessage__c = errorMessages;
                }
            }else{
                inboundCalls[index].Status__c = 'Success';
                ibcSuccess.add(inboundCalls[index]);
            }
        }

        inboundCallsSet.addAll(inboundCallsWithErrors);
        inboundCallsSet.addAll(ibcSuccess);
        inboundCallsToUpdate.addAll(inboundCallsSet);
        update inboundCallsToUpdate;

    }
    global void finish(Database.BatchableContext bc)
    {
        
    }

}