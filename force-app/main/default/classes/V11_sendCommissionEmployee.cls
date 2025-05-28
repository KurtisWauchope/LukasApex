public class V11_sendCommissionEmployee implements Queueable,Database.AllowsCallouts {

    String obcId;
    String operation;

    public V11_sendCommissionEmployee(String obcId, String operation) {
        this.obcId = obcId;
        this.operation = operation;

    }
    public void execute(QueueableContext context){

        
       obcCommissionEmployee__c obcCE = [SELECT Id, BuildingProject__c, Employee__c FROM obcCommissionEmployee__c WHERE Outbound_Call__c=:obcID];
       BuildingProject__c bp = [SELECT ComarchBuildingProjectNumber__c FROM BuildingProject__c WHERE Id =: obcCE.BuildingProject__c];
       List<Building_Project_Team__c> bpTeam = [SELECT User__r.Comarch_External_UserID__c FROM Building_Project_Team__c WHERE BuildingProject__c =: obcCE.BuildingProject__c AND Entitled_to_Commission__c = True];
       User empl = [SELECT Comarch_External_UserID__c FROM User WHERE Id =: obcCE.Employee__c];
 
        String envHeader='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ver="http://webservices.semiramis.com/2006-01/Import/extended/VERTRIEBSAUSSICHTSF" xmlns:data="http://webservices.semiramis.com/2006-01/Import/extended/VERTRIEBSAUSSICHTSF/data" xmlns:com="http://webservices.semiramis.com/2006-01/common"><soapenv:Header/><soapenv:Body> <ver:process> <ver:in0> <ver:warningsMode>CONFIRM_ALL</ver:warningsMode>  <ver:correctionMode>NONE</ver:correctionMode><ver:processLogLevel>ENABLED</ver:processLogLevel> <ver:importData>';
        String envFooter = '</ver:importData></ver:in0></ver:process></soapenv:Body></soapenv:Envelope>';
        String body='';
        String provBer='';


        if(operation == 'create' || operation == 'delete'){
            if(bpTeam.size() > 1){
                for(Building_Project_Team__c t : bpTeam){
                provBer +=
                '<data:PROVBERECHTIGT><data:Employee><data:number>'+V11_helperClass.getStringValue(t.User__r.Comarch_External_UserID__c)+'</data:number> </data:Employee> </data:PROVBERECHTIGT>';
                }

        body = body +'<data:Opportunity mode="update">'+
        '<data:number>'+V11_helperClass.getStringValue(bp.ComarchBuildingProjectNumber__c)+'</data:number>'+
        '<data:SalesOrganization><data:number>910000</data:number></data:SalesOrganization>'+
        '<data:Type><data:code>100</data:code></data:Type>'+'<data:EntityExtension>'+provBer;
                }
            else{body = body +'<data:Opportunity mode="update">'+
            '<data:number>'+V11_helperClass.getStringValue(bp.ComarchBuildingProjectNumber__c)+'</data:number>'+
            '<data:Type> <data:code>100</data:code></data:Type>'+'<data:EntityExtension>'+                  
            '<data:PROVBERECHTIGT mode="delete"> <data:Employee mode="delete"> <data:number>'+V11_helperClass.getStringValue(empl.Comarch_External_UserID__c)+'</data:number> </data:Employee> </data:PROVBERECHTIGT>';
            }
            
            }else if (operation == 'update'){

                body = body +'<data:Opportunity mode="update">'+
                '<data:number>'+V11_helperClass.getStringValue(bp.ComarchBuildingProjectNumber__c)+'</data:number>'+'<data:EntityExtension>'+
                '<data:Type> <data:code>100</data:code></data:Type>'+                  
                '<data:PROVBERECHTIGT mode="delete"> <data:Employee mode="delete"> <data:number>'+V11_helperClass.getStringValue(empl.Comarch_External_UserID__c)+'</data:number> </data:Employee> </data:PROVBERECHTIGT>';
            
            }

            body= body+'</data:EntityExtension> </data:Opportunity>';


        String requestString = envHeader + body + envFooter;
        HttpRequest req = new HttpRequest();
        String userAuth = V11_helperClass.getPassword('Comarch');
        req.setHeader('Authorization','Basic '+userAuth);
        req.setEndpoint(V11_helperClass.getEndpoint('BuildingProjectImport'));
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
            obcUpdate.Status__c = 'Success';

            Database.update(obcUpdate, dml);
        }else{

            obcUpdate.Status__c = 'Error';          
            Database.update(obcUpdate, dml);
        }  

    }
}