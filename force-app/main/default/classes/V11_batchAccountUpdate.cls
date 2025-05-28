global class V11_batchAccountUpdate implements Database.Batchable<V11_PartnerExportData.Partner>, Database.AllowsCallouts, Database.Stateful{

    List<Database.UpsertResult> upsertResults;
    Map<String,InboundCall__c> failedInboundCalls = new Map<String,InboundCall__c>();
    WebserviceLog__c wsLog;
    Map<String,String> keyValues;
    List<V11_PartnerExportData.Partner> accounts;

    public V11_batchAccountUpdate(){}
    public V11_batchAccountUpdate(List<V11_PartnerExportData.Partner> accounts){
        this.accounts = accounts;
        wsLog = new WebserviceLog__c();
    }

    public List<V11_PartnerExportData.Partner> start (Database.BatchableContext bc)
    {
        keyValues = V11_KeyValueMap.createKeyValueMap('Account');

        if(accounts == null){
            wsLog = new WebserviceLog__c();
            accounts = V11_callComarchImport.importPartners(wsLog);
        }
        List<InboundCall__c> ibc = [Select Object_ID__C, Id FROM InboundCall__c WHERE Object__c ='Account' and Status__c ='Error' and Outdated__c = false];
        for(InboundCall__c call : ibc)
        {
            failedInboundCalls.put(call.Object_ID__C,call);
        }
       
        return accounts;

    }
    public void execute(Database.BatchableContext bc, List<V11_PartnerExportData.Partner> scope)
    {
        List<InboundCall__c> inboundCalls = new List<InboundCall__c>();
        List<InboundCall__c> inboundCallsWithErrors = new List<InboundCall__c>();
        List<InboundCall__c> updateCalls = new List<InboundCall__c>();
        List<Account> accounts = new List<Account>();

        for(V11_PartnerExportData.Partner ped: scope)
        {
            if(ped.EntityExtension == null || ped.EntityExtension.SALESFORCEID.value == ''){
                continue;
            }
            InboundCall__c inboundCall = new InboundCall__c();
            InboundCall__c updateCall = new InboundCall__c();
            inboundCall.Webservice_Log__c = wsLog.Id;
            Account acc = new account();

            if(failedInboundCalls.containsKey(ped.number_x)){
                updateCall = failedInboundCalls.get(ped.number_x);
                updateCall.Outdated__c = true;
                updateCalls.add(updateCall);
            }

            inboundCall.Object__c = 'Account';
            inboundCall.Status__c = 'Pending';
            inboundCall.Object_ID__C = ped.number_x;
            inboundCall.Data__c = JSON.serialize(ped);

            try{

                acc.Name = ped.name;
                acc.Id = ped.EntityExtension.SALESFORCEID.value;
                acc.ComarchAccountNumber__c = ped.number_x;

                acc.BillingCity = ped.addressData.city;
                acc.BillingCountryCode = ped.addressData.Country.isoCode;
                acc.BillingPostalCode = ped.addressData.postalCode;
                acc.BillingStreet = ped.addressData.street;                
                acc.Language__c = ped.Language.isoCode;                
                if(ped.CommunicationData != null){
                    for(V11_PartnerExportData.Partner_CommunicationData commData : ped.CommunicationData){
                        if(commData.Method.name == '100'){
                            acc.Phone = commData.commData;
                        }else if(commData.Method.name == '200'){
                            acc.Fax = commData.commData;
                        }else if(commData.Method.name == '300'){
                            acc.Email__c = commData.commData;
                        }else if(commData.Method.name == '400'){
                            acc.Website = commData.commData;
                        }
                    }
                }else{
                    acc.Phone = '';
                    acc.Fax = '';
                    acc.Email__c ='';
                    acc.Website =''; 
                }
                if(ped.PartnerAccountingData != null){
                    for(V11_PartnerExportData.Partner_PartnerAccountingData accountingData : ped.PartnerAccountingData){
                        if(accountingData.SalesPaymentTerms == null|| accountingData.SalesPaymentTerms.OrganizationalUnit.number_x !='910000'){
                            continue;
                        }
                        acc.Terms_of_payment__c = accountingData.SalesPaymentTerms.description;
                        
                        if(accountingData.CustomerOutstandingDebt!= null){
                            acc.DeliveryBlock__c = accountingData.CustomerOutstandingDebt.deliveryStop;
                        }
                    }
                }
                if(ped.OrganizationalUnitPartner != null){
                    for(V11_PartnerExportData.Partner_OrganizationalUnitPartner org : ped.OrganizationalUnitPartner){
                        if(org.OrganizationalUnit.code =='910000'){
                            acc.Blocked__c = org.customerStatus == 'ON_HOLD'?true:false;
                        }
                    }
                }                
                acc.ReasonForBlocking__c = ped.EntityExtension.SPERRGRUND.value != '0' ? keyValues.get('ReasonForBlocking__c'+ped.EntityExtension.SPERRGRUND.value):'';



            }catch(Exception e){

                inboundCall.Status__c = 'Error';
                inboundCall.ErrorMessage__c = e.getMessage();
                inboundCallsWithErrors.add(inboundCall);

            }
            if(inboundCall.Status__c == 'Pending'){

                inboundCalls.add(inboundCall);
                accounts.add(acc);
            }
        }
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        dml.OptAllOrNone = false;
        List<Database.SaveResult> urList = Database.update(accounts,dml);

        for(Integer index = 0, size = urList.size();index<size;index++)
        {
            if(!urList[index].success)
            {
                inboundCalls[index].Status__c = 'Error';
                String errorMessages = 'Database: ';
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