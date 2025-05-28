public class V11_sendContactToComarch implements Queueable,Database.AllowsCallouts {
    
    String obcId;
    String operation;

    public V11_sendContactToComarch(String obcId, String operation) {

        this.obcId = obcId;
        this.operation = operation;

    }

    public void execute(QueueableContext context){
        String envHeader='<?xml version="1.0"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:par="http://webservices.semiramis.com/2006-01/Import/extended/PARTNERSALESFORCE" xmlns:data="http://webservices.semiramis.com/2006-01/Import/extended/PARTNERSALESFORCE/data" xmlns:com="http://webservices.semiramis.com/2006-01/common"><soapenv:Header/>'+
        '<soapenv:Body><par:process><par:in0><par:warningsMode>CONFIRM_ALL</par:warningsMode><par:correctionMode>NONE</par:correctionMode><par:processLogLevel>ENABLED</par:processLogLevel><par:importData>';
        String envFooter = '</par:importData></par:in0></par:process></soapenv:Body></soapenv:Envelope>';
        String body='';

        obcContact__c contact = [SELECT Id,Comarch_ID__c,First_Name__c,Middle_Name__c,Name__c,Salutation__c,Title__c,Account_ID_comarch__c,Language__c,Email__c,Mobile__c,Phone__c,Old_Email__c,Old_Mobile__c,Old_Phone__c,Id__c FROM obcContact__c WHERE Outbound_Call__c =: obcId];

      
            //TODO
            body = body +'<data:Partner mode="'+operation+'">'+
            '<data:number>'+V11_helperClass.getStringValue(contact.Comarch_ID__c)+'</data:number>'+
            '<data:type>EXTERNAL</data:type>'+
            '<data:person>'+
            '<data:givenName>'+V11_helperClass.getStringValue(contact.First_Name__c)+'</data:givenName><data:middleNames>'+V11_helperClass.getStringValue(contact.Middle_Name__c)+'</data:middleNames><data:surname>'+V11_helperClass.getStringValue(contact.Name__c)+'</data:surname>'+
            '<data:gender>MALE</data:gender>'+
            '<data:Salutation><data:name>'+V11_helperClass.getStringValue(contact.Salutation__c)+'</data:name></data:Salutation>'+
            '<data:Title><data:name>'+V11_helperClass.getStringValue(contact.Title__c)+'</data:name></data:Title>'+
            '</data:person>'+
            '<data:EntityExtension mode="create">'+
            '<data:SALESFORCEID mode="create"> <data:value>'+V11_helperClass.getStringValue(contact.Id__c)+'</data:value> </data:SALESFORCEID>'+ 
            '</data:EntityExtension>'+
            '<data:human>true</data:human>'+
            '<data:Language><data:isoCode>'+V11_helperClass.getStringValue(contact.Language__c)+'</data:isoCode></data:Language>'+
            '<data:MaintainingOrganization><data:number>910000</data:number></data:MaintainingOrganization>';
            if(operation == 'create'){
                body = body + '<data:CommunicationData><data:commData>'+V11_helperClass.getStringValue(contact.Email__c)+'</data:commData><data:preferred>false</data:preferred><data:Method><data:name>300</data:name></data:Method></data:CommunicationData>'+
                '<data:CommunicationData><data:commData>'+V11_helperClass.getStringValue(contact.Mobile__c)+'</data:commData><data:preferred>false</data:preferred><data:Method><data:name>120</data:name></data:Method></data:CommunicationData>'+
                '<data:CommunicationData><data:commData>'+V11_helperClass.getStringValue(contact.Phone__c)+'</data:commData><data:preferred>true</data:preferred><data:Method><data:name>100</data:name></data:Method></data:CommunicationData>';
            }else{
                if(contact.Email__c != contact.Old_Email__c){
                    body = body + '<data:CommunicationData mode="create"><data:commData>'+V11_helperClass.getStringValue(contact.Email__c)+'</data:commData><data:preferred>false</data:preferred><data:Method><data:name>300</data:name></data:Method></data:CommunicationData>';
                    if(contact.Old_Email__c != null){
                        body = body +'<data:CommunicationData mode="delete"><data:commData>'+V11_helperClass.getStringValue(contact.Old_Email__c)+'</data:commData><data:preferred>false</data:preferred><data:Method><data:name>300</data:name></data:Method></data:CommunicationData>';
                    }

                }if(contact.Mobile__c != contact.Old_Mobile__c){
                    body = body + '<data:CommunicationData mode="create"><data:commData>'+V11_helperClass.getStringValue(contact.Mobile__c)+'</data:commData><data:preferred>false</data:preferred><data:Method><data:name>120</data:name></data:Method></data:CommunicationData>';
                    if(contact.Old_Mobile__c != null){
                        body = body + '<data:CommunicationData mode="delete"><data:commData>'+V11_helperClass.getStringValue(contact.Old_Mobile__c)+'</data:commData><data:preferred>false</data:preferred><data:Method><data:name>120</data:name></data:Method></data:CommunicationData>';
                    }                    

                }if(contact.Phone__c != contact.Old_Phone__c){
                    body = body + '<data:CommunicationData mode="create"><data:commData>'+V11_helperClass.getStringValue(contact.Phone__c)+'</data:commData><data:preferred>false</data:preferred><data:Method><data:name>100</data:name></data:Method></data:CommunicationData>';
                    if(contact.Old_Phone__c != null){
                        body = body + '<data:CommunicationData mode="delete"><data:commData>'+V11_helperClass.getStringValue(contact.Old_Phone__c)+'</data:commData><data:preferred>false</data:preferred><data:Method><data:name>100</data:name></data:Method></data:CommunicationData>';
                    }                    
                }                
            }

            body = body +'</data:Partner>';
                


        String requestString = envHeader + body + envFooter;
        HttpRequest req = new HttpRequest();
        String userAuth = V11_helperClass.getPassword('Comarch');
        req.setHeader('Authorization','Basic '+userAuth);
        req.setEndpoint(V11_helperClass.getEndpoint('ContactImport'));
        req.setMethod('POST');
        req.setBody(requestString);
        req.setHeader('Content-Type', 'text/xml');
        req.setHeader('SOAPAction', '""');
        Http http = new Http();
        HTTPResponse res;      
        res = http.send(req);


        Contact cUpdate = [SELECT Id FROM Contact WHERE Id =:contact.Id__c];
        OutboundCall__c obcUpdate = [SELECT Id FROM OutboundCall__c WHERE Id =:obcId];
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
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

            obcUpdate.Status__c = 'Success';           
            cUpdate.ComarchSyncStatusContact__c = 'Success';
            cUpdate.Synced__c = true;
            Database.update(cUpdate, dml);
            Database.update(obcUpdate, dml);
            
            if(operation == 'create'){
                List<AccountContactRelation> acrList = [SELECT Id FROM AccountContactRelation WHERE ContactId =:cUpdate.Id ];
                for(AccountContactRelation acr: acrList){
                    acr.InitialContactRelation__c = true;
                }
                Database.update(acrList, dml);    
            }                              


        }else{

            cUpdate.ComarchSyncStatusContact__c = 'Error';
            obcUpdate.Status__c = 'Error';          
            Database.update(cUpdate, dml);
            Database.update(obcUpdate, dml);
        }     
            


    }
}