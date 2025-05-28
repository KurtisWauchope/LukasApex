global class V11_batchOrderUpsert implements Database.Batchable<V11_OrderExportData.SalesOrder>, Database.AllowsCallouts, Database.Stateful {

    Map<String,InboundCall__c> failedInboundCalls = new Map<String,InboundCall__c>();
    WebserviceLog__c wsLog;    
    List<V11_OrderExportData.SalesOrder> salesOrders = new List<V11_OrderExportData.SalesOrder>();
    List<InboundCall__c> ibcs = new List<InboundCall__c>();
    List<V11_OrderExportData.SalesOrder> orders;
    List<String> orderIds = new List<String>();

    Map<String,Opportunity> existingOpps = new Map<String,Opportunity>();
    Set<String> existingQuotes = new Set<String>();
    Set<String> activeUsers = new Set<String>();
    Set<String> existingContacts = new Set<String>();
    Set<String> existingBPs = new Set<String>();

    public V11_batchOrderUpsert(){}

    public V11_batchOrderUpsert(List<string> orderIds){
        this.orderIds = orderIds;
    }
    public V11_batchOrderUpsert(List<V11_OrderExportData.SalesOrder> orders){
        this.orders = orders;
        wsLog = new WebserviceLog__c();
    }

    public List<V11_OrderExportData.SalesOrder> start (Database.BatchableContext bc)
    {
        List<InboundCall__c> ibc = [Select Object_ID__C, Id FROM InboundCall__c WHERE Object__c ='Order' and Status__c ='Error' and Outdated__c = false];
        for(InboundCall__c call : ibc)
        {
            failedInboundCalls.put(call.Object_ID__C,call);
        }        

        if(orders == null){
            List<String> tempIds = new List<String>();
            tempIds.addAll(orderIds);
            string orderList = '';
            Integer counter = 0;
            for(string id :tempIds){
                if(counter>9){
                    break;
                }
                orderList = orderList + '\'' + id +'\',';
                orderIds.remove(0);
                counter++;
            }
            wsLog = new WebserviceLog__c();
            orders = V11_callComarchImport.importOrders(wsLog,orderList.substring(0,orderList.length()-1));
        }      
        List<String> OppIds = new List<String>();
        List<String> QuoteIds = new List<String>();
        List<String> ContactIds = new List<String>();
        List<String> bpIds = new List<String>();
        for(V11_OrderExportData.SalesOrder order:orders){
            if(order.customerData.CustomerPartner!=null&&order.Rai_Opportunity!=null){
                String extId = order.customerData.CustomerPartner.number_x+order.Rai_Opportunity.number_x;
                OppIds.add(extId);
            }
            if(order.CustomerProposal!=null){
                String extId = order.CustomerProposal.number_x;
                QuoteIds.add(extId);
            }
            if(order.customerData.CareOfPartner!=null){
                String extId = order.customerData.CareOfPartner.number_x;
                ContactIds.add(extId);
            }
            if(order.Rai_Opportunity != null){
                String extId = order.Rai_Opportunity.number_x;
                bpIds.add(extId);
            }

        }
        List<Quote> quotes = [SELECT ID,External_Id__c FROM Quote WHERE External_Id__c in :QuoteIds];
        List<Opportunity> opps = [SELECT ID,External_Id__c FROM Opportunity WHERE External_Id__c in :OppIds];
        List<User> users = [SELECT Comarch_External_UserID__c FROM User WHERE IsActive = true AND Comarch_External_UserID__c !=''];
        List<Contact> contacts = [SELECT ExternalComarchContactId__c FROM Contact WHERE ExternalComarchContactId__c in :ContactIds];
        List<BuildingProject__c> bps = [SELECT ComarchBuildingProjectNumber__c FROM BuildingProject__c WHERE ComarchBuildingProjectNumber__c in :bpIds];

        for(Opportunity opp :opps){
            existingOpps.put(opp.External_Id__c, opp);
        }
        for(Quote q : quotes){
            existingQuotes.add(q.External_Id__c);
        }
        for(User u : users){
            activeUsers.add(u.Comarch_External_UserID__c);
        }
        for(Contact c : contacts){
            existingContacts.add(c.ExternalComarchContactId__c);
        }
        for(BuildingProject__c b : bps){
            existingBPs.add(b.ComarchBuildingProjectNumber__c);
        }


        return orders;

    }

    
    public void execute(Database.BatchableContext bc, List<V11_OrderExportData.SalesOrder> scope)
    {

        List<InboundCall__c> inboundCalls = new List<InboundCall__c>();
        List<InboundCall__c> inboundCallsWithErrors = new List<InboundCall__c>();
        List<InboundCall__c> updateCalls = new List<InboundCall__c>();
        List<Order> orders = new List<Order>();
        List<OrderItem> orderItems = new List<OrderItem>();
        List<V11_OrderExportData.SalesOrder> salesOrdersTemp = new List<V11_OrderExportData.SalesOrder>();

        

        for(V11_OrderExportData.SalesOrder oed: scope)
        { 

            InboundCall__c inboundCall = new InboundCall__c();
            InboundCall__c updateCall = new InboundCall__c();
            inboundCall.Webservice_Log__c = wsLog.Id;
            Order order = new Order();
            List<OrderItem> oItems = new List<OrderItem>();
            

            if(failedInboundCalls.containsKey(oed.guid)){

                updateCall = failedInboundCalls.get(oed.guid);
                updateCall.Outdated__c = true;
                updateCalls.add(updateCall);
            }

                inboundCall.Object__c = 'Order';
                inboundCall.Status__c = 'Pending';
                inboundCall.Object_ID__C = oed.guid;
                String dataJSON = JSON.serialize(oed);
                if(dataJSON.length()>130000){
                    inboundCall.Data__c = dataJSON.substring(0, 130000);
                    if(dataJSON.length()>260000){
                        inboundCall.Data_2__c = dataJSON.substring(130000, 260000);
                        if(dataJSON.length()>390000){
                            inboundCall.Data_3__c = dataJSON.substring(260000, 390000);
                            if(dataJSON.length()>520000){
                                inboundCall.Data_4__c = dataJSON.substring(390000, 520000);
                            }else{
                                inboundCall.Data_4__c = dataJSON.substring(390000, dataJSON.length());
                            }
                        }else{
                            inboundCall.Data_3__c = dataJSON.substring(260000, dataJSON.length());
                        }
                    }else{
                        inboundCall.Data_2__c = dataJSON.substring(130000, dataJSON.length());
                    }
                }else{
                    inboundCall.Data__c = dataJSON.substring(0, dataJSON.length());
                }
                

            try{

                if(oed.customerData.CustomerPartner == null){
                    continue;
                }
                if(oed.customerData.CustomerPartner.number_x.startsWith('98')){
                    Account acc = new Account(ComarchAccountNumber__c = '910000');
                    order.Account = acc;
                }else{
                    Account acc = new Account(ComarchAccountNumber__c = oed.customerData.CustomerPartner.number_x);
                    order.Account = acc;
                }                

                if(oed.Rai_Opportunity != null){
                    if(existingBPs.contains(oed.Rai_Opportunity.number_x)){
                    BuildingProject__c bp = new BuildingProject__c(ComarchBuildingProjectNumber__c = oed.Rai_Opportunity.number_x);
                    order.BuildingProject__r = bp;
                    }
                    
                } 
                if(oed.Rai_Opportunity!=null){
                    if(existingOpps.containsKey(oed.customerData.CustomerPartner.number_x+oed.Rai_Opportunity.number_x)){
                        order.Opportunity = existingOpps.get(oed.customerData.CustomerPartner.number_x+oed.Rai_Opportunity.number_x);
                    }
                }             

                if(oed.CustomerProposal != null){

                    if(existingQuotes.contains(oed.CustomerProposal.number_x)){
                        Quote q = new Quote(External_Id__c=oed.CustomerProposal.number_x);
                        order.Quote = q;
                    }

                }
                if(oed.customerData.CareOfPartner != null){

                    if(existingContacts.contains(oed.customerData.CareOfPartner.number_x)){
                        Contact con = new Contact(ExternalComarchContactId__c = oed.customerData.CareOfPartner.number_x);
                        order.ContactId__r = con;
                    }


                }if(oed.SalesRepresentatives != null){

                    if(activeUsers.contains(oed.SalesRepresentatives[0].number_x)){
                        User u = new User(Comarch_External_UserID__c=oed.SalesRepresentatives[0].number_x);
                        order.SalesRepresentative__r =  u;
                    }

                }
                 //Außendienst

                
                order.Name = oed.number_x;
                order.ExternalId__c = oed.number_x;
                if(oed.Type_x_SalesOrder != null){order.OrderType__c = oed.Type_x_SalesOrder.code+ ' | '+ oed.Type_x_SalesOrder.description;}                
                order.Status = 'Draft';               
                order.EffectiveDate = date.newInstance(oed.date_x.year(), oed.date_x.month(), oed.date_x.day());
                
                order.Responsible_Employee__c = oed.ResponsiblePartner != null ? oed.ResponsiblePartner.name:''; //Zuständiger Mitarbeiter(Innendienst)
                
                order.Supervisor__c = oed.Rai_ResponsibleEmployee != null ? oed.Rai_ResponsibleEmployee.name:''; //Betreuer
                
                
                order.Product_Group__c = oed.classification1 != null ? oed.classification1.description : '';               
                order.Information__c = oed.rai_infoText;
                order.Description = oed.rai_objectName != null ? oed.rai_objectName:'';
                //Lieferempfänger (Reiter):
                order.ShippingRecipient__c = oed.deliveryCustomerData != null ? oed.deliveryCustomerData.name : '';

                if(oed.deliveryCustomerData.addressData!=null){
                    
                    /*order.ShippingStreet = oed.deliveryCustomerData.addressData.street;
                    order.ShippingCity = oed.deliveryCustomerData.addressData.city;
                    order.ShippingPostalCode = oed.deliveryCustomerData.addressData.postalCode;
                    order.ShippingCountryCode = oed.deliveryCustomerData.addressData.Country.isoCode;*/

                    String address = oed.deliveryCustomerData.addressData.street + '\n' + oed.deliveryCustomerData.addressData.postalCode + ' ' + oed.deliveryCustomerData.addressData.city + '\n' + oed.deliveryCustomerData.addressData.Country.isoCode;
                    order.Address__c = address;
                }


                //Lieferkonditionen (Reiter)
                order.DeliveryConditions__c = oed.deliveryData.DeliveryTerms != null ? oed.deliveryData.DeliveryTerms.description : '';
                order.ShippingConditions__c = oed.deliveryData.ShippingTerms != null ? oed.deliveryData.ShippingTerms.description : '';

                //Rechnungskonditionen (Reiter):
                order.PriceListing__c = oed.PriceListing != null ? oed.PriceListing.description : '';
                order.Percent1__c = Decimal.valueOf(oed.discounts[0].value);
                order.Percent2__c = Decimal.valueOf(oed.discounts[1].value);
                order.Percent3__c = Decimal.valueOf(oed.discounts[2].value);
                order.Percent4__c = Decimal.valueOf(oed.discounts[3].value);
                order.PaymentCondition__c = oed.InvoicingData.PaymentTerms!= null ? oed.InvoicingData.PaymentTerms.description : '';
                
      
                //Auftragswerte
                order.GrossValue__c = Decimal.valueOf(oed.totalValues.grossValue.amount);
                order.NetTotal__c = Decimal.valueOf(oed.totalValues.netValue.amount);
                order.Gross_margin__c = Decimal.valueOf(oed.grossMargin);
                order.Cost_of_goods__c = oed.costOfGoods.amount1;
                
                //Gewicht & Volumen
                order.GrossTotalWeight__c = Decimal.valueOf(oed.totalValues.grossWeight.amount);
                order.NetTotalWeight__c = Decimal.valueOf(oed.totalValues.netWeight.amount);
                


            

            }catch(Exception e){

                inboundCall.Status__c = 'Error';
                inboundCall.ErrorMessage__c = e.getLineNumber()+' '+ e.getMessage();                
                inboundCallsWithErrors.add(inboundCall);

            }
            if(inboundCall.Status__c == 'Pending'){

                inboundCalls.add(inboundCall);
                orders.add(order);
                orderItems.addAll(oItems);
                salesOrdersTemp.add(oed);

            }



        }
        Schema.SObjectField Idfield = Order.Fields.ExternalId__c;
        List<Database.UpsertResult> urList = Database.upsert(orders,Idfield,false);

        for(Integer index = 0, size = urList.size();index<size;index++)
        {
            if(!urList[index].success)
            {
                inboundCalls[index].Status__c = 'Error';
                String errorMessages ='';
                for(Database.Error error : urList[index].getErrors()){
                    errorMessages = errorMessages + '\n'+ error.message;
                }
                inboundCalls[index].ErrorMessage__c = errorMessages;
            }else
            {
                if(salesOrdersTemp[index].Details==null){
                    inboundCalls[index].Status__c = 'Success';
                    continue;
                }
                ibcs.add(inboundCalls[index]);
                salesOrders.add(salesOrdersTemp[index]);
            }            

        }
        inboundCalls.addAll(inboundCallsWithErrors);
        insert inboundCalls;
        update updateCalls;
    }

    public void finish(Database.BatchableContext bc)
    {
        V11_batchOrderUpsertPositions batchhandler = new V11_batchOrderUpsertPositions(salesOrders,ibcs,orderIds);
        database.executeBatch(batchhandler,200);

    }
}