public class V11_sendRelationsToComarch implements Queueable,Database.AllowsCallouts {

    String obcId;
    String operation;

    public V11_sendRelationsToComarch(String obcId, String operation) {
        this.obcId = obcId;
        this.operation = operation;

    }
    public void execute(QueueableContext context){

        
        obcAccountContactRelation__c obcACR = [SELECT Id,Account__c,Contact__c,Id__c,InitialContactRelation__c FROM obcAccountContactRelation__c WHERE Outbound_Call__c=:obcID];

        String envHeader='<?xml version="1.0"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:par="http://webservices.semiramis.com/2006-01/Import/extended/PARTNERSALESFORCE" xmlns:data="http://webservices.semiramis.com/2006-01/Import/extended/PARTNERSALESFORCE/data" xmlns:com="http://webservices.semiramis.com/2006-01/common"><soapenv:Header/>'+
        '<soapenv:Body><par:process><par:in0><par:warningsMode>CONFIRM_ALL</par:warningsMode><par:correctionMode>NONE</par:correctionMode><par:processLogLevel>ENABLED</par:processLogLevel><par:importData>';
        String envFooter = '</par:importData></par:in0></par:process></soapenv:Body></soapenv:Envelope>';
        String body = '';

        if(obcACR.InitialContactRelation__c){

            body = '<data:Partner mode="update">'+
            '<data:number>'+obcACR.Contact__c+'</data:number>'+
            '<data:Employee mode="create">'+ 
            '<data:PartnerRelations mode="create">'+
            '<data:Target>'+
            '<data:number>'+obcACR.Account__c+'</data:number>'+
            '</data:Target><data:Type><data:name>Employee</data:name></data:Type>'+
            '</data:PartnerRelations>'+       
            '</data:Employee></data:Partner>';

        }else{

            if(operation == 'delete'){

                body = '<data:Partner mode="update">'+
                '<data:number>'+obcACR.Contact__c+'</data:number>'+
                '<data:Employee mode="update">'+ 
                '<data:PartnerRelations mode="delete">'+
                '<data:Target>'+
                '<data:number>'+obcACR.Account__c+'</data:number>'+
                '</data:Target><data:Type><data:name>Employee</data:name></data:Type>'+
                '</data:PartnerRelations>'+       
                '</data:Employee></data:Partner>';
    
            }else if(operation == 'create'){
    
                body = '<data:Partner mode="update">'+
                '<data:number>'+obcACR.Contact__c+'</data:number>'+
                '<data:Employee mode="update">'+ 
                '<data:PartnerRelations mode="create">'+
                '<data:Target>'+
                '<data:number>'+obcACR.Account__c+'</data:number>'+
                '</data:Target><data:Type><data:name>Employee</data:name></data:Type>'+
                '</data:PartnerRelations>'+       
                '</data:Employee></data:Partner>';
    
            }

        }


        String requestString = envHeader + body + envFooter;
        HttpRequest req = new HttpRequest();
        String userAuth = V11_helperClass.getPassword('Comarch');
        req.setHeader('Authorization','Basic '+userAuth);
        req.setEndpoint(V11_helperClass.getEndpoint('RelationsImport'));
        req.setMethod('POST');
        req.setBody(requestString);
        req.setHeader('Content-Type', 'text/xml');
        req.setHeader('SOAPAction', '""');
        Http http = new Http();
        HTTPResponse res;
        res = http.send(req);


        
        OutboundCall__c obcUpdate = [SELECT Id FROM OutboundCall__c WHERE Id =:obcId];
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        obcUpdate.Data__c = requestString;
        obcUpdate.Data__c = requestString;
        obcUpdate.ErrorMessage__c = res.getBody();
        XmlStreamReader reader = res.getXmlStreamReader();
        Boolean hasError = false;
        while(reader.hasNext()){
            if(reader.getLocalName()=='hasErrorFile'){
                reader.next();
                if(reader.hasText()){
                    hasError = Boolean.valueOf(reader.getText());
                    break;
                }
            }
            reader.next();
        }
        
        
        
        if(!hasError && res.getStatusCode() == 200){
            if(operation != 'delete'){
                AccountContactRelation acrUpdate = [SELECT Id FROM AccountContactRelation WHERE Id =:obcACR.Id__c];
                acrUpdate.Synced__c = true;
                acrUpdate.InitialContactRelation__c = false;
                Database.update(acrUpdate, dml);
            }
            obcUpdate.Status__c = 'Success';

            Database.update(obcUpdate, dml);
        }else{

            obcUpdate.Status__c = 'Error';          
            Database.update(obcUpdate, dml);
        }  

    }
}