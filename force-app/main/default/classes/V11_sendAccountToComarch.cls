public class V11_sendAccountToComarch implements Queueable,Database.AllowsCallouts{

    String obcId;
    String operation;

    public V11_sendAccountToComarch(String obcId, String operation) {
        
        this.obcId = obcId;
        this.operation = operation;

    }



    public void execute(QueueableContext context){
        
        String envHeader='<?xml version="1.0"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:par="http://webservices.semiramis.com/2006-01/Import/extended/PARTNERSALESFORCE" xmlns:data="http://webservices.semiramis.com/2006-01/Import/extended/PARTNERSALESFORCE/data" xmlns:com="http://webservices.semiramis.com/2006-01/common"><soapenv:Header/>'+
        '<soapenv:Body><par:process><par:in0><par:warningsMode>CONFIRM_ALL</par:warningsMode><par:correctionMode>NONE</par:correctionMode><par:processLogLevel>ENABLED</par:processLogLevel><par:importData>';
        String envFooter = '</par:importData></par:in0></par:process></soapenv:Body></soapenv:Envelope>';
        String body ='';

        obcAccount__c acc = [SELECT Id,Comarch_ID__c,Name__c,Street__c,City__c,Postal_Code__c, Language__c, Country_Code__c,Template__c,ID__c,Website__c,Phone__c,Email__c,Old_Website__c,Old_Phone__c,Old_Email__c,Fax__c,Old_Fax__c FROM obcAccount__c WHERE Outbound_Call__c =: obcId];


        body = body +'<data:Partner mode="'+ operation +'">'+
        '<data:number>'+ acc.Comarch_ID__c +'</data:number>';
        if(operation == 'create'){
            List<String> splittedName = V11_helperClass.splitName(acc.Name__c);      
            body = body + '<data:organizationalUnit><data:name index="0">'+ splittedName[0].escapeXml() +'</data:name>';
            if(splittedName.size()>1){
                body = body +'<data:name index="1">'+splittedName[1].escapeXml()+'</data:name>';
                if(splittedName.size()>2){
                    body = body +'<data:name index="2">'+splittedName[2].escapeXml()+'</data:name>';
                }
            }
            body = body + '</data:organizationalUnit><data:addressData><data:street>'+acc.Street__c.escapeXml()+'</data:street><data:city>'+acc.City__c.escapeXml()+'</data:city><data:postalCode>'+acc.Postal_Code__c.escapeXml()+'</data:postalCode><data:Country mode="'+operation+'"><data:isoCode>'+acc.Country_Code__c+'</data:isoCode></data:Country></data:addressData>'+
            '<data:template>'+acc.Template__c+'</data:template>'+
            '<data:EntityExtension mode="create">'+
            '<data:SALESFORCEID mode="create"> <data:value>'+acc.ID__c+'</data:value> </data:SALESFORCEID>'+ 
            '</data:EntityExtension>';
        }
        body = body + '<data:Language><data:isoCode>'+acc.Language__c+'</data:isoCode></data:Language>'+
        '<data:MaintainingOrganization><data:number>910000</data:number></data:MaintainingOrganization>';

        if(operation == 'create'){

            body = body + '<data:CommunicationData><data:commData>'+V11_helperClass.getStringValue(acc.Email__c)+'</data:commData><data:preferred>false</data:preferred><data:Method><data:name>300</data:name></data:Method></data:CommunicationData>'+
            '<data:CommunicationData><data:commData>'+V11_helperClass.getStringValue(acc.Website__c)+'</data:commData><data:preferred>false</data:preferred><data:Method><data:name>400</data:name></data:Method></data:CommunicationData>'+
            '<data:CommunicationData><data:commData>'+V11_helperClass.getStringValue(acc.Phone__c)+'</data:commData><data:preferred>false</data:preferred><data:Method><data:name>100</data:name></data:Method></data:CommunicationData>'+
            '<data:CommunicationData><data:commData>'+V11_helperClass.getStringValue(acc.Fax__c)+'</data:commData><data:preferred>false</data:preferred><data:Method><data:name>200</data:name></data:Method></data:CommunicationData>';

        }else{
            if(acc.Email__c != acc.Old_Email__c){
                body = body + '<data:CommunicationData mode="create"><data:commData>'+V11_helperClass.getStringValue(acc.Email__c)+'</data:commData><data:preferred>false</data:preferred><data:Method><data:name>300</data:name></data:Method></data:CommunicationData>';
                if(acc.Old_Email__c != null){
                    body = body +'<data:CommunicationData mode="delete"><data:commData>'+V11_helperClass.getStringValue(acc.Old_Email__c)+'</data:commData><data:preferred>false</data:preferred><data:Method><data:name>300</data:name></data:Method></data:CommunicationData>';
                }

            }if(acc.Website__c != acc.Old_Website__c){
                body = body + '<data:CommunicationData mode="create"><data:commData>'+V11_helperClass.getStringValue(acc.Website__c)+'</data:commData><data:preferred>false</data:preferred><data:Method><data:name>400</data:name></data:Method></data:CommunicationData>';
                if(acc.Old_Website__c != null){
                    body = body + '<data:CommunicationData mode="delete"><data:commData>'+V11_helperClass.getStringValue(acc.Old_Website__c)+'</data:commData><data:preferred>false</data:preferred><data:Method><data:name>400</data:name></data:Method></data:CommunicationData>';
                }                    

            }if(acc.Phone__c != acc.Old_Phone__c){
                body = body + '<data:CommunicationData mode="create"><data:commData>'+V11_helperClass.getStringValue(acc.Phone__c)+'</data:commData><data:preferred>false</data:preferred><data:Method><data:name>100</data:name></data:Method></data:CommunicationData>';
                if(acc.Old_Phone__c != null){
                    body = body + '<data:CommunicationData mode="delete"><data:commData>'+V11_helperClass.getStringValue(acc.Old_Phone__c)+'</data:commData><data:preferred>false</data:preferred><data:Method><data:name>100</data:name></data:Method></data:CommunicationData>';
                }                    
            }
            if(acc.Fax__c != acc.Old_Fax__c){
                body = body + '<data:CommunicationData mode="create"><data:commData>'+V11_helperClass.getStringValue(acc.Fax__c)+'</data:commData><data:preferred>false</data:preferred><data:Method><data:name>200</data:name></data:Method></data:CommunicationData>';
                if(acc.Old_Fax__c != null){
                    body = body + '<data:CommunicationData mode="delete"><data:commData>'+V11_helperClass.getStringValue(acc.Old_Fax__c)+'</data:commData><data:preferred>false</data:preferred><data:Method><data:name>200</data:name></data:Method></data:CommunicationData>';
                }                    
            }                 
        }
        body = body +'</data:Partner>';
     


        String requestString = envHeader + body + envFooter;
        HttpRequest req = new HttpRequest();
        String userAuth = V11_helperClass.getPassword('Comarch');
        req.setHeader('Authorization','Basic '+userAuth);
        req.setEndpoint(V11_helperClass.getEndpoint('PartnerImport'));
        req.setMethod('POST');
        req.setBody(requestString);
        req.setHeader('Content-Type', 'text/xml');
        req.setHeader('SOAPAction', '""');
        Http http = new Http();
        HTTPResponse res;
        res = http.send(req);

        

        Account accUpdate = [SELECT Id FROM Account WHERE Id =:acc.Id__c];
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
            accUpdate.ComarchSyncStatus__c = 'Success';
            List<AccountContactRelation> acr = [SELECT Id FROM AccountContactRelation WHERE AccountId =:accUpdate.Id ];
            Database.update(acr, dml);                         
            Database.update(accUpdate, dml);
            Database.update(obcUpdate, dml);
        }else{

            accUpdate.ComarchSyncStatus__c = 'Error';
            obcUpdate.Status__c = 'Error';          
            Database.update(accUpdate, dml);
            Database.update(obcUpdate, dml);
        }              
        

    }
}