global class V11_batchQuoteUpsertQuotes implements Database.Batchable<V11_QuoteExportData.CustomerProposal>, Database.Stateful {

    List<V11_QuoteExportData.CustomerProposal> cProps;
    List<InboundCall__c> ibcs;
    Map<String,Opportunity> parentOppMap;

    Map<String,InboundCall__c> inboundCallsMap = new Map<String,InboundCall__c>();
    List<V11_QuoteExportData.CustomerProposal> cPropsPositions = new List<V11_QuoteExportData.CustomerProposal>();
    List<InboundCall__c> ibcsPositions = new List<InboundCall__c>();

    Map<String,String> existingQuotesWithOpps = new Map<String,String>();
    Set<String> existingContacts = new Set<String>();
    Set<String> existingAccounts = new Set<String>();
    Set<String> existingBPs = new Set<String>();
    Set<String> activeUsers = new Set<String>();

    public V11_batchQuoteUpsertQuotes(List<V11_QuoteExportData.CustomerProposal> cProps,List<InboundCall__c> ibcs,Map<String,Opportunity> parentOppMap){
        this.cProps = cProps;
        this.ibcs = ibcs;
        this.parentOppMap = parentOppMap;
    }





    public List<V11_QuoteExportData.CustomerProposal> start (Database.BatchableContext bc)
    {
        for(Integer index = 0, size = ibcs.size();index<size;index++){
            inboundCallsMap.put(cProps[index].guid,ibcs[index]);
        }
        List<String> contactIds = new List<String>();
        List<String> accIds = new List<String>();
        List<String> quoteIds = new List<String>();
        List<String> bpIds = new List<String>();
        for(V11_QuoteExportData.CustomerProposal q :cProps){
            quoteIds.add(q.number_x);
            if(q.customerData.CareOfPartner != null){
                contactIds.add(q.customerData.CareOfPartner.number_x);
            }
            if(q.customerData.CustomerPartner != null){
                accIds.add(q.customerData.CustomerPartner.number_x);
            }
            if(q.Rai_Opportunity != null){
                bpIds.add(q.Rai_Opportunity.number_x);
            }         
        }
        List<Quote> existingOpps = [SELECT OpportunityId, External_Id__c FROM Quote WHERE External_Id__c IN: quoteIds];
        for(Quote qOpps: existingOpps){
            existingQuotesWithOpps.put(qOpps.External_Id__c, qOpps.OpportunityId);
        }

        List<User> users = [SELECT Comarch_External_UserID__c FROM User WHERE IsActive = true];
        List<Contact> contacts = [SELECT ExternalComarchContactId__c FROM Contact WHERE ExternalComarchContactId__c in :contactIds];
        List<Account> accs = [SELECT ComarchAccountNumber__c FROM Account WHERE ComarchAccountNumber__c in :accIds];
        List<BuildingProject__c> bps = [SELECT ComarchBuildingProjectNumber__c FROM BuildingProject__c WHERE ComarchBuildingProjectNumber__c in :bpIds];

        for(User u : users){
            activeUsers.add(u.Comarch_External_UserID__c);
        }
        for(Contact c : contacts){
            existingContacts.add(c.ExternalComarchContactId__c);
        }
        for(Account a : accs){
            existingAccounts.add(a.ComarchAccountNumber__c);
        }
        for(BuildingProject__c b : bps){
            existingBPs.add(b.ComarchBuildingProjectNumber__c);
        }

        return cProps;

    }

    
    public void execute(Database.BatchableContext bc, List<V11_QuoteExportData.CustomerProposal> scope)
    {

        List<InboundCall__c> inboundCalls = new List<InboundCall__c>();
        List<InboundCall__c> inboundCallsWithErrors = new List<InboundCall__c>();
        List<InboundCall__c> updateCalls = new List<InboundCall__c>();
        List<Quote> quotes = new List<Quote>();
        List<V11_QuoteExportData.CustomerProposal> cPropsTemp = new List<V11_QuoteExportData.CustomerProposal>();
        List<Opportunity> childOpps = new List<Opportunity>();
        

        for(V11_QuoteExportData.CustomerProposal qed: scope)
        {
            if( qed.customerData.CustomerPartner.number_x ==''){
                continue;
            }
            
            Quote quote;           
            InboundCall__c ibc = inboundCallsMap.get(qed.guid);
            Opportunity childOpp;

            try{

                quote = new Quote(External_Id__c = qed.number_x);

                if(parentOppMap.containsKey(qed.number_x)){
                    
                    
                    Opportunity parentOpp = new Opportunity(External_Id__c = qed.customerData.CustomerPartner.number_x  + qed.Rai_Opportunity.number_x);
                    childOpp = parentOppMap.get(qed.number_x);
                    if(childOpp.External_Id__c != parentOpp.External_Id__c){
                        childOpp.ParentOpportunity__r = parentOpp;
                        quote.ParentOpportunity__r = parentOpp;
                    }
                    

                }else{

                    if(!existingQuotesWithOpps.containsKey(qed.number_x)){
                        Opportunity opp;

                        if(qed.Rai_Opportunity == null){
        
                                string extIdOpp = qed.customerData.CustomerPartner.number_x + qed.number_x;                  
                                opp = new Opportunity(External_Id__c = extIdOpp);
        
                            } 
                        else//Bauvorhaben
                        {
                            string extIdOpp = qed.customerData.CustomerPartner.number_x  + qed.Rai_Opportunity.number_x ;
                            opp = new Opportunity(External_Id__c = extIdOpp);
                            
                        }
                        quote.ParentOpportunity__r = opp;
                        quote.Opportunity = opp;
                    }  
                }   

                if(qed.customerData.CustomerPartner == null){
                    continue;
                }

                if(existingAccounts.contains(qed.customerData.CustomerPartner.number_x)){
                    Account acc = new Account (ComarchAccountNumber__c = qed.customerData.CustomerPartner.number_x);
                    quote.AccountId__r= acc; 
                }
              
                               
                if(qed.customerData.CareOfPartner != null){
                    if(existingContacts.contains(qed.customerData.CareOfPartner.number_x)){
                        Contact con = new Contact(ExternalComarchContactId__c = qed.customerData.CareOfPartner.number_x);
                        quote.ContactId__r = con;
                    }
                  
                }

                if(qed.SalesRepresentative_CustomerProposal != null){

                    if(activeUsers.contains(qed.SalesRepresentative_CustomerProposal.number_x)){
                        User us = new User(Comarch_External_UserID__c = qed.SalesRepresentative_CustomerProposal.number_x);
                        quote.SalesRepresentive__r = us;
                    }

                }
                if(qed.Rai_Opportunity != null){
                    if(existingBPs.contains(qed.Rai_Opportunity.number_x)){
                        BuildingProject__c bp = new BuildingProject__c(ComarchBuildingProjectNumber__c = qed.Rai_Opportunity.number_x);
                        quote.BuildingProjectName__r = bp;
                    }
                    
                }
               
                // Kopfdaten
                quote.Name = qed.number_x;
                quote.QuoteNumber__c = qed.number_x;
                
                quote.Type_of_Quote__c = qed.Type_x_CustomerProposal.description;         
                quote.Responsible_employee__c = qed.ResponsiblePartner.name;
                quote.Supervisor__c = qed.Rai_ResponsibleEmployee_CustomerProposal != null? qed.Rai_ResponsibleEmployee_CustomerProposal.name:'';
                quote.Information__c = qed.rai_infoText;
                quote.EntryDate__c = date.newInstance(qed.date_x.year(), qed.date_x.month(), qed.date_x.day());
                quote.ProductGroup__c = qed.classification1.description;
                quote.Description = qed.rai_objectName;

                if(qed.reviewDate.year() >= date.today().year()){
                    quote.ResubmissionDate__c = date.newInstance(qed.reviewDate.year(), qed.reviewDate.month(), qed.reviewDate.day()); 
                } else {
                    Date td = Date.today();
                    Date fd = td.addDays(7);
                    quote.ResubmissionDate__c = fd;
                }
                
                //Statusabfrage ob Angebot ersetzt
                
                if(qed.Classification3 != null){
                    if(qed.Classification3.code == '210' || qed.Classification3.code == '205'){
                        quote.Status = 'Rejected';
                        quote.Loss__c = 'Replaced';
                    }
                    else if(qed.totalValues.grossValue.amount == '0'){
                        quote.Status = 'Requested';
                        }else{
                        quote.Status = 'Sent';
                        }
                        
                }
                else{
                        if(qed.totalValues.grossValue.amount == '0'){
                        quote.Status = 'Requested';
                        }else{
                        quote.Status = 'Sent';
                        }
                        
                    } 
                
                
                
                //Rechnungskonditionen
                quote.PriceListing__c = qed.PriceListing != null? qed.PriceListing.description : '';
                quote.Percent1__c = Decimal.valueOf(qed.discounts[0].value);
                quote.Percent2__c = Decimal.valueOf(qed.discounts[1].value);
                quote.Percent3__c = Decimal.valueOf(qed.discounts[2].value);
                quote.Percent4__c = Decimal.valueOf(qed.discounts[3].value);
                quote.PaymentCondition__c = qed.InvoicingData.PaymentTerms.description;

                //Klassifikationen

                //quote.Multi_quote__c = 
                
               
                //Auftragswerte
                quote.GrossTotalWeight__c = Decimal.valueOf(qed.totalValues.grossWeight.amount);
                quote.Grand_Total__c = Decimal.valueOf(qed.totalValues.grossValue.amount);
                quote.NetTotal__c = Decimal.valueOf(qed.totalValues.netValue.amount);         

            }catch(Exception e){

                ibc.Status__c = 'Error';
                ibc.ErrorMessage__c = ' | C2 UpsertQuotes | '+ e.getLineNumber()+' | '+e.getMessage();
                inboundCallsWithErrors.add(ibc);

            }
            if(ibc.Status__c == 'Pending'){
                inboundCalls.add(ibc);
                quotes.add(quote);
                cPropsTemp.add(qed);
                if(childOpp != null){
                    if(childOpp.ParentOpportunity__c != null){
                        childOpps.add(childOpp);
                    }                    
                }
            }
        
    
        


        }


        Schema.SObjectField Idfield = Quote.Fields.External_Id__c;
        List<Database.UpsertResult> urList = Database.upsert(quotes,Idfield,false);


        for(Integer index = 0, size = urList.size();index<size;index++)
        {

            if(!urList[index].success)
            {
                inboundCalls[index].Status__c = 'Error';
                String errorMessages = '';
                for(Database.Error error : urList[index].getErrors()){
                    errorMessages = errorMessages + '\n'+ error.message;
                }
                inboundCalls[index].ErrorMessage__c = errorMessages;
            }else{
                if(cPropsTemp[index].Details==null){
                    inboundCalls[index].Status__c = 'Success';
                    continue;
                }
                ibcsPositions.add(inboundCalls[index]);
                cPropsPositions.add(cPropsTemp[index]);
            }                

        }
        inboundCalls.addAll(inboundCallsWithErrors);
        update inboundCalls;
        if(childOpps.size()>0){
                Set<Opportunity> oppSet = new Set<Opportunity>();
                List<Opportunity> finalOppList = new List<Opportunity>();
                    for (Opportunity o : childOpps) {
                        if (oppSet.add(o)) {
                            finalOppList.add(o);
                        }
                    }
            childOpps.clear();
            childOpps.addAll(finalOppList);
            update childOpps;
        }
        
    }

    global void finish(Database.BatchableContext bc)
    {
        V11_batchQuoteUpsertQuotesPositions batchhandler = new V11_batchQuoteUpsertQuotesPositions(cPropsPositions, ibcsPositions);
        database.executeBatch(batchhandler,200);

    }
}