global class V11_batchOrderUpsertPositions implements Database.Batchable<V11_OrderExportData.SalesOrder>, Database.AllowsCallouts, Database.Stateful{


    Map<String,InboundCall__c> inboundCallsMap = new Map<String,InboundCall__c>();
    List<V11_OrderExportData.SalesOrder> salesOrders;
    List<InboundCall__c> ibcs;
    Set<String> externalProIds = new Set<String>();
    List<String> orderIds;

    public V11_batchOrderUpsertPositions(List<V11_OrderExportData.SalesOrder> salesOrders,List<InboundCall__c> ibcs,List<String> orderIds) {
        this.salesOrders = salesOrders;
        this.ibcs = ibcs;
        this.orderIds = orderIds;
    }

    public List<V11_OrderExportData.SalesOrder> start (Database.BatchableContext bc)
    {
        for(Integer index = 0, size = ibcs.size();index<size;index++){
            inboundCallsMap.put(salesOrders[index].guid,ibcs[index]);
        }
        List<String> prodIds = new List<String>();
        for(V11_OrderExportData.SalesOrder so : salesOrders){
            for(V11_OrderExportData.SalesOrder_Details detail : so.Details){
                prodIds.add(detail.Item.number_x);
            }
        }
        List<Product2> products = [SELECT ExternalId__c FROM Product2 WHERE  ExternalId__c IN:prodIds];
        for(Product2 prod :products){
            externalProIds.add(prod.ExternalId__c);
        }

        return salesOrders;

    }

    public void execute(Database.BatchableContext bc, List<V11_OrderExportData.SalesOrder> scope)
    {


        List<InboundCall__c> inboundCalls = new List<InboundCall__c>();
        List<InboundCall__c> inboundCallsWithErrors = new List<InboundCall__c>();
        List<Order_Position__c> oItemsInsert = new List<Order_Position__c>();

        for(V11_OrderExportData.SalesOrder oed: scope)
        {
            Order order;
            InboundCall__c ibc = inboundCallsMap.get(oed.guid);
            List<Order_Position__c> oItems = new List<Order_Position__c>();

            try{

                order = new Order(ExternalId__c = oed.number_x);
                if(oed.Details==null){
                    continue;
                }
                for(V11_OrderExportData.SalesOrder_Details detail : oed.Details)
                {
                    Order_Position__c oItem = new Order_Position__c();
                    if(externalProIds.contains(detail.Item.number_x)){

                        Product2 pro = new Product2(ExternalId__c = detail.Item.number_x);
                        oItem.Product__r = pro;
                        oItem.Note__c = '';
                    }else{
                        oItem.Note__c = 'Product does not exist in Salesforce!';
                    }
      
                    oItem.Order__r = order;
                    oItem.Name = String.valueOf(detail.number_x);

                    //TODO: Order Positions Mapping
                    oItem.ExternalId__c = detail.guid;                    
                    oItem.DeliveryDate__c = date.newInstance(detail.deliveryDate.year(), detail.deliveryDate.month(), detail.deliveryDate.day());
                    oItem.Quantity__c = Decimal.valueOf(detail.totalQuantity.amount);
                    oItem.GrossPrice__c = Decimal.valueOf(detail.grossPrice.amount);
                    oItem.TotalPrice__c = Decimal.valueOf(detail.totalValues.grossValue.amount);
                    oItem.Status__c = detail.status;//Key Value Map
                    
                    oItems.add(oItem);
        
                }

            }catch(Exception e){

                ibc.Status__c = 'Error';
                ibc.ErrorMessage__c = e.getMessage();
                inboundCallsWithErrors.add(ibc);

            }
            if(ibc.Status__c == 'Pending'){

                for(Order_Position__c item :oItems){
                    inboundCalls.add(ibc);
                    oItemsInsert.add(item);
                }
                
                
            }            

        }

        Schema.SObjectField Idfield = Order_Position__c.Fields.ExternalId__c;
        List<Database.UpsertResult> urList = Database.upsert(oItemsInsert,Idfield,false);
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
                if(index!=0){
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
                    if(urList.size()==1){
                        inboundCallsSet.add(inboundCalls[index]);
                    }
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

    public void finish(Database.BatchableContext bc)
    {
        if(orderIds.size()>0){
            V11_batchOrderUpsert batchhandler = new V11_batchOrderUpsert(orderIds);
            database.executeBatch(batchhandler,200);
        }
    }


}