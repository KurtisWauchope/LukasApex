global class V11_batchQuoteUpsert implements Database.Batchable<V11_QuoteExportData.CustomerProposal>, Database.AllowsCallouts, Database.Stateful {

    List<V11_QuoteExportData.CustomerProposal> quotes;

    Map<String,InboundCall__c> failedInboundCalls = new Map<String,InboundCall__c>();
    WebserviceLog__c wsLog;
    Map<String,Opportunity> existingQuotesWithOpps = new Map<String,Opportunity>();
    Map<String,Opportunity> existingBPOpps = new Map<String,Opportunity>();
    Map<String,Date> existingBPs = new Map<String,Date>();
    List<V11_QuoteExportData.CustomerProposal> cProps = new List<V11_QuoteExportData.CustomerProposal>();
    List<InboundCall__c> ibcs = new List<InboundCall__c>();
    Map<String,Opportunity> parentOppMap = new Map<String,Opportunity>();
    String masterRecordTypeId;

    public V11_batchQuoteUpsert(){

    }
    public V11_batchQuoteUpsert(List<V11_QuoteExportData.CustomerProposal> quotes){
        this.quotes = quotes; 
        wsLog = new WebserviceLog__c();       
    }


    public List<V11_QuoteExportData.CustomerProposal> start (Database.BatchableContext bc)
    {
        List<V11_QuoteExportData.CustomerProposal> batchQuotes = new List<V11_QuoteExportData.CustomerProposal>();

        if(quotes == null){
            wsLog = new WebserviceLog__c();
            quotes = V11_callComarchImport.importQuotes(wsLog);
        }      
        List<String> quoteIds = new List<String>();
        List<String> bpIds = new List<String>();
        
        for(V11_QuoteExportData.CustomerProposal q :quotes){
            quoteIds.add(q.number_x);
            if(q.Rai_Opportunity != null){
                bpIds.add(q.customerData.CustomerPartner.number_x  + q.Rai_Opportunity.number_x);
            }            
        }

        RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName ='Opportunity'];
        masterRecordTypeId = recordType.Id;

        List<Quote> existingQuoteOpps = [SELECT OpportunityId, External_Id__c,Opportunity.RecordType.DeveloperName, Opportunity.StageName, Opportunity.CloseDate,Opportunity.External_Id__c,Opportunity.OwnerId, Opportunity.Name, OwnerId FROM Quote WHERE External_Id__c IN: quoteIds];
        List<Opportunity> existingOpps = [SELECT Name,StageName,CloseDate,External_Id__c,Id FROM Opportunity WHERE External_Id__c IN:bpIds];

        for(Quote qOpps: existingQuoteOpps){

                Opportunity PaOpp = new Opportunity(Id = qOpps.OpportunityId);
                PaOpp.StageName = qOpps.Opportunity.StageName;
                PaOpp.CloseDate = qOpps.Opportunity.CloseDate;
                PaOpp.Name = qOpps.Opportunity.Name;
                PaOpp.External_Id__c = qOpps.Opportunity.External_Id__c;
                PaOpp.OwnerId = qOpps.OwnerId;
                existingQuotesWithOpps.put(qOpps.External_Id__c, PaOpp);         
        }        
        for(Opportunity opp:existingOpps){
            
            existingBPOpps.put(opp.External_Id__c,opp);
        }

        List<BuildingProject__c> existingBP = [SELECT ComarchBuildingProjectNumber__c,SubmissionDate__c FROM BuildingProject__c WHERE ComarchBuildingProjectNumber__c IN: bpIds];
        for(BuildingProject__c bp : existingBP){
            existingBPs.put(bp.ComarchBuildingProjectNumber__c, bp.SubmissionDate__c);
        }

        List<InboundCall__c> ibc = [Select Object_ID__C, Id FROM InboundCall__c WHERE Object__c ='Quote' and Status__c ='Error' and Outdated__c = false];
        for(InboundCall__c call : ibc)
        {
            failedInboundCalls.put(call.Object_ID__C,call);
        }
        


        return quotes;

    }

    
    public void execute(Database.BatchableContext bc, List<V11_QuoteExportData.CustomerProposal> scope)
    {

        List<InboundCall__c> inboundCalls = new List<InboundCall__c>();
        List<InboundCall__c> inboundCallsWithErrors = new List<InboundCall__c>();
        List<InboundCall__c> updateCalls = new List<InboundCall__c>();
        List<Quote> quotes = new List<Quote>();
        List<Opportunity> opps = new List<Opportunity>();
        List<QuoteLineItem> qlis = new List<QuoteLineItem>();
        List<V11_QuoteExportData.CustomerProposal> cPropsTemp = new List<V11_QuoteExportData.CustomerProposal>();
        Map<String,Opportunity> tempParentOppMap = new Map<String,Opportunity>();

        

        for(V11_QuoteExportData.CustomerProposal qed: scope)
        {
            if( qed.customerData.CustomerPartner.number_x ==''){
                continue;
            }               
        

            InboundCall__c inboundCall = new InboundCall__c();
            InboundCall__c updateCall = new InboundCall__c();
            inboundCall.Webservice_Log__c = wsLog.Id;

            

            if(failedInboundCalls.containsKey(qed.guid)){

                updateCall = failedInboundCalls.get(qed.guid);
                updateCall.Outdated__c = true;
                updateCalls.add(updateCall);
            }

            inboundCall.Object__c = 'Quote';
            inboundCall.Status__c = 'Pending';
            inboundCall.Object_ID__C = qed.guid;
            String dataJSON = JSON.serialize(qed);
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
            
            Opportunity opp;

            try{
        
                    // Set Stage for all Opportunities (also existingQuoteOpps & existingBPOpps)
                    String OppStage;
                    
                    if(qed.totalValues.grossValue.amount == '0'){
                        OppStage = 'Requested';            
                    }else{
                        OppStage = 'Proposal';
                    }
                        


                    if(qed.Rai_Opportunity == null){//kein Bauvorhaben
                        if(!existingQuotesWithOpps.containsKey(qed.number_x)){

                            string extIdOpp = qed.customerData.CustomerPartner.number_x + qed.number_x;                  
                            opp = new Opportunity(External_Id__c = extIdOpp);
                            
                            if(qed.rai_objectName == '' || qed.rai_objectName == null){
                                opp.Name = qed.number_x;
                            }else {
                                opp.Name = qed.rai_objectName;
                            }
                            
                            opp.Object_Description__c = qed.rai_objectName;
                            opp.RecordTypeId = masterRecordTypeId;
                            opp.StageName = OppStage;
                            
                            opp.CloseDate = date.newInstance(qed.date_x.year(), qed.date_x.month(), qed.date_x.day()+7);


                            if(qed.reviewDate.year() >= date.today().year()){
                                opp.ResubmissionDate__c = Date.today()+7;
                            } else {
                                Date td = Date.today();
                                Date fd = td.addDays(7);
                                opp.ResubmissionDate__c = fd;
                            }
                            
                            List<User> users = [SELECT Id, Comarch_External_UserID__c FROM User WHERE Comarch_External_UserID__c = :qed.SalesRepresentative_CustomerProposal.number_x LIMIT 1];
                            if (users != null && !users.isEmpty()) {
                                User us = users[0];
                                opp.OwnerId = us.Id;
                            }
                            
                                    
                            
                            Account acc = new Account (ComarchAccountNumber__c = qed.customerData.CustomerPartner.number_x);
                            opp.Account = acc;
                        }else{
                            opp = existingQuotesWithOpps.get(qed.number_x);
                            if(opp.StageName == 'Open' || opp.StageName == 'Requested' ){
                                opp.StageName = OppStage;
                            }
                        }

                    }else{ //wenn BV existiert

                        if(!existingBPOpps.containsKey(qed.customerData.CustomerPartner.number_x  + qed.Rai_Opportunity.number_x )){
                            
                            string extIdOpp = qed.customerData.CustomerPartner.number_x  + qed.Rai_Opportunity.number_x ;
                            opp = new Opportunity(External_Id__c = extIdOpp);                  
                            BuildingProject__c bp = new BuildingProject__c(ComarchBuildingProjectNumber__c = qed.Rai_Opportunity.number_x);
                            opp.RecordTypeId = masterRecordTypeId;
                            opp.Name = qed.customerData.name + ' | ' + qed.Rai_Opportunity.description;
                            opp.BuildingProject__r = bp;
                            opp.CloseDate = date.newInstance(qed.date_x.year(), qed.date_x.month(), qed.date_x.day()+7);
                            
                            if(qed.reviewDate.year() >= date.today().year()){
                                opp.ResubmissionDate__c = Date.today()+7;
                            } else {
                                Date td = Date.today();
                                Date fd = td.addDays(7);
                                opp.ResubmissionDate__c = fd;
                            }

                            opp.Object_Description__c = qed.rai_objectName;
                            
                            List<User> users = [SELECT Id, Comarch_External_UserID__c FROM User WHERE Comarch_External_UserID__c = :qed.SalesRepresentative_CustomerProposal.number_x LIMIT 1];
                            if (users != null && !users.isEmpty()) {
                                User us = users[0];
                                opp.OwnerId = us.Id;
                            }
                                
                            /*User us = new User(Comarch_External_UserID__c = qed.SalesRepresentative_CustomerProposal.number_x);
                            opp.OwnerId = us.Id;*/
                            
                            
                            opp.StageName = OppStage;
                            Account acc = new Account (ComarchAccountNumber__c = qed.customerData.CustomerPartner.number_x);
                            opp.Account = acc;

                        }else{
                            opp = existingBPOpps.get(qed.customerData.CustomerPartner.number_x  + qed.Rai_Opportunity.number_x);
                            if(opp.StageName == 'Open' || opp.StageName == 'Requested' ){
                                opp.StageName = OppStage;
                            }
                            opp.CloseDate = date.newInstance(qed.date_x.year(), qed.date_x.month(), qed.date_x.day()+7);
                            
                            if(qed.reviewDate.year() >= date.today().year()){
                                opp.ResubmissionDate__c = Date.today()+7;
                            } else {
                                Date td = Date.today();
                                Date fd = td.addDays(7);
                                opp.ResubmissionDate__c = fd;
                            }
                        }

                        if(existingQuotesWithOpps.containsKey(qed.number_x)){
                            tempParentOppMap.put(qed.number_x,existingQuotesWithOpps.get(qed.number_x));
                            if(opp.StageName == 'Open' || opp.StageName == 'Requested' ){
                                opp.StageName = OppStage;
                            }
                            opp.CloseDate = date.newInstance(qed.date_x.year(), qed.date_x.month(), qed.date_x.day()+7);
                            
                            if(qed.reviewDate.year() >= date.today().year()){
                                opp.ResubmissionDate__c = Date.today()+7; 
                            } else {
                                Date td = Date.today();
                                Date fd = td.addDays(7);
                                opp.ResubmissionDate__c = fd;
                            }
                        }
                    }          
            
            
            }catch(Exception e){

                inboundCall.Status__c = 'Error';
                inboundCall.ErrorMessage__c = ' | C1 batch Quote | '+ e.getLineNumber()+' | '+e.getMessage();
                inboundCallsWithErrors.add(inboundCall);

            }
            if(inboundCall.Status__c == 'Pending'){

                inboundCalls.add(inboundCall);
                opps.add(opp);
                cPropsTemp.add(qed);                

            }
        }

        Schema.SObjectField Idfield = Opportunity.Fields.External_Id__c;
        List<Opportunity> upsertOpps = new List<Opportunity>();
        List<Id> oppExtId = new List<String>();
        Integer indexUrList = 0;
        Map<String,Integer> indexMap = new Map<String,Integer>();
        for(Opportunity opp :opps){
            if(!oppExtId.contains(opp.External_Id__c)){
                oppExtId.add(opp.External_Id__c);
                upsertOpps.add(opp);
                indexMap.put(opp.External_Id__c, indexUrList);
                indexUrList++;
            }

        }
        List<Database.UpsertResult> urList = Database.upsert(upsertOpps,Idfield,false);        


        for(Integer index = 0, size = inboundCalls.size();index<size;index++)
        {

            if(!urList[indexMap.get(opps[index].External_Id__c)].success)
            {
                inboundCalls[index].Status__c = 'Error';
                String errorMessages ='Database: ';
                for(Database.Error error : urList[indexMap.get(opps[index].External_Id__c)].getErrors()){
                    errorMessages = errorMessages + '\n'+ error.message;
                }
                inboundCalls[index].ErrorMessage__c = errorMessages;
            }else{

                ibcs.add(inboundCalls[index]);
                cProps.add(cPropsTemp[index]);
                if(tempParentOppMap.containsKey(cPropsTemp[index].number_x)){
                    parentOppMap.put(cPropsTemp[index].number_x,tempParentOppMap.get(cPropsTemp[index].number_x));                            
                }
            }          

        }

        
        inboundCalls.addAll(inboundCallsWithErrors);
        insert inboundCalls;
        update updateCalls;
    }

    global void finish(Database.BatchableContext bc)
    {
        V11_batchQuoteUpsertQuotes batchhandler = new V11_batchQuoteUpsertQuotes(cProps,ibcs,parentOppMap);
        database.executeBatch(batchhandler,200);
    }
}