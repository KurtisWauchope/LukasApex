public class V11_sendBuildingProjectToComarch implements Queueable,Database.AllowsCallouts{

    String obcId;
    String operation;

    public V11_sendBuildingProjectToComarch(String obcId, String operation) {
        this.obcId = obcId;
        this.operation = operation;

    }
        
    private static string getStringValue(string field){
        if(field == null){
            return '';
        }else{
            return field;
        }

    }

    public void execute(QueueableContext context){
        String envHeader='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ver="http://webservices.semiramis.com/2006-01/Import/extended/VERTRIEBSAUSSICHTSF" xmlns:data="http://webservices.semiramis.com/2006-01/Import/extended/VERTRIEBSAUSSICHTSF/data" xmlns:com="http://webservices.semiramis.com/2006-01/common"><soapenv:Header/><soapenv:Body> <ver:process> <ver:in0> <ver:warningsMode>CONFIRM_ALL</ver:warningsMode>  <ver:correctionMode>NONE</ver:correctionMode><ver:processLogLevel>ENABLED</ver:processLogLevel> <ver:importData>';
        String envFooter = '</ver:importData></ver:in0></ver:process></soapenv:Body></soapenv:Envelope>';
        String body='';

        obcBuildingProject__c bp = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Postal_Code__c, Allocation_fabricator_Id__c, Entitled_to_Commission__c, City__c, Size_1__c, Planner_of_cladding_Id__c, Architect_Id__c, Inside_Sales_Id__c, Project_Priority__c, Amount__c, Size_3__c, General_Constructor_Id__c, System_2__c, Investor_Id__c, external_note__c, Total_Size__c, Street__c, Country__c, Building_Authority_Id__c, Allocation_system_house__c, Project_Sales_Id__c, internal_note__c, Builder_Awarding_Office_Id__c, Type__c, Stage__c, Probability__c, Name__c, System_3__c, Building_Type__c, Size_2__c, Tender_Type__c, System_1__c, Outbound_Call__c, System_Unit_1__c, System_Unit_2__c, System_Unit_3__c, Id__c, ComarchBuildingProjectNumber__c, Project_supported__c, Responsible_VL_VKL__c, Status__c, RAICO_specification__c, Non_Disclosure_Agreement__c, Building_Project_Owner__c, Construction_End_Planned__c, Construction_Start__c, Submission_Date__c, Date_of_Service_Specification__c, Order_Entry__c FROM obcBuildingProject__c WHERE Outbound_Call__c =: obcId];
        String bez = v11_helperClass.getStringValue(bp.Name__c)+', '+V11_helperClass.getStringValue(bp.City__c);
        if (bez.length() > 64){
            bez = bez.substring(0, 64);
        }
            body = body +'<data:Opportunity mode="'+operation+'">'+
            '<data:number>'+V11_helperClass.getStringValue(bp.ComarchBuildingProjectNumber__c)+'</data:number>'+
            '<data:description>'+bez+'</data:description>'+
            '<data:status>'+V11_helperClass.getStringValue(bp.Status__c)+'</data:status>'+
            '<data:probability>'+V11_helperClass.getStringValue(bp.Probability__c)+'</data:probability>'+
            '<data:OpportunityStage> <data:code>'+V11_helperClass.getStringValue(bp.Stage__c)+'</data:code> </data:OpportunityStage>'+
            '<data:Partner > <data:number>99999999</data:number> </data:Partner>'+
            '<data:ResponsiblePartner > <data:number>'+V11_helperClass.getStringValue(bp.Building_Project_Owner__c)+'</data:number> </data:ResponsiblePartner>'+
            '<data:SalesOrganization > <data:number>910000</data:number> </data:SalesOrganization>'+
            '<data:Type> <data:code>100</data:code> </data:Type>'+
            '<data:Rai_ResponsibleEmployee> <data:number>'+V11_helperClass.getStringValue(bp.Project_Sales_Id__c)+'</data:number> </data:Rai_ResponsibleEmployee>'+
            '<data:Classification2> <data:path>'+V11_helperClass.getStringValue(bp.Project_supported__c)+'</data:path></data:Classification2>'+
            '<data:Classification3> <data:path>'+V11_helperClass.getStringValue(bp.RAICO_specification__c)+'</data:path> </data:Classification3>'+
            '<data:Classification4> <data:path>'+V11_helperClass.getStringValue(bp.Type__c)+'</data:path> </data:Classification4>'+
            '<data:Classification5> <data:path>'+V11_helperClass.getStringValue(bp.Building_Type__c)+'</data:path> </data:Classification5>'+
            '<data:EntityExtension >'+
            //'<data:AD90> <data:Employee> <data:number>'+V11_helperClass.getStringValue(bp.Entitled_to_Commission__c)+'</data:number> </data:Employee> </data:AD90>'+
            '<data:ARCHITEKT> <data:Partner > <data:number>'+V11_helperClass.getStringValue(bp.Architect_Id__c)+'</data:number> </data:Partner> </data:ARCHITEKT>'+
            '<data:AUSFUEHRUNG> <data:value> <data:timeStamp>'+V11_helperClass.getStringValue(bp.Construction_Start__c)+'</data:timeStamp> <data:timeZone>CET</data:timeZone> </data:value> </data:AUSFUEHRUNG>'+
            '<data:VERGABE> <data:value> <data:timeStamp>'+V11_helperClass.getStringValue(bp.Order_Entry__c)+'</data:timeStamp> <data:timeZone>CET</data:timeZone> </data:value> </data:VERGABE>'+
            '<data:AUSSCHREIBUNGSART> <data:value>'+V11_helperClass.getStringValue(bp.Tender_Type__c)+'</data:value> </data:AUSSCHREIBUNGSART>'+
            '<data:PB> <data:Partner> <data:number>'+V11_helperClass.getStringValue(bp.Planner_of_cladding_Id__c)+'</data:number> </data:Partner> </data:PB>'+
            '<data:BAUAMT> <data:Partner> <data:number>'+V11_helperClass.getStringValue(bp.Building_Authority_Id__c)+'</data:number> </data:Partner> </data:BAUAMT>'+
            //'<data:BEMERKUNGEN> <data:value>'+V11_helperClass.getStringValue(bp.internal_note__c)+'</data:value> </data:BEMERKUNGEN>'+
            //'<data:BEMERKUNGENAD> <data:value>'+V11_helperClass.getStringValue(bp.external_note__c)+'</data:value> </data:BEMERKUNGENAD>'+            
            '<data:GU> <data:Partner> <data:number>'+V11_helperClass.getStringValue(bp.General_Constructor_Id__c)+'</data:number> </data:Partner> </data:GU>'+
            '<data:LAND> <data:Country> <data:isoCode>'+V11_helperClass.getStringValue(bp.Country__c)+'</data:isoCode> </data:Country> </data:LAND>'+
            '<data:MWV> <data:value> <data:amount1>'+V11_helperClass.getStringValue(bp.Amount__c)+'</data:amount1> <data:Currency1> <data:isoCode>EUR</data:isoCode> </data:Currency1> </data:value> </data:MWV>'+
            '<data:OBJEKTNAME> <data:value>'+V11_helperClass.getStringValue(bp.Name__c)+'</data:value> </data:OBJEKTNAME>'+
            '<data:OBJGROESSEGESAMT > <data:value> <data:amount>'+V11_helperClass.getStringValue(bp.Total_Size__c)+'</data:amount> <data:Uom> <data:code>m²</data:code> </data:Uom> </data:value> </data:OBJGROESSEGESAMT>'+
            '<data:ORT > <data:value>'+V11_helperClass.getStringValue(bp.City__c)+'</data:value> </data:ORT>'+
            '<data:PLZ > <data:value>'+V11_helperClass.getStringValue(bp.Postal_Code__c)+'</data:value> </data:PLZ>'+
            //'<data:PROJEKTVERANTWORTLICHER_VL_VKL > <data:value>'+V11_helperClass.getStringValue(bp.Responsible_VL_VKL__c)+'</data:value> </data:PROJEKTVERANTWORTLICHER_VL_VKL>'+
            '<data:STRASSE > <data:value>'+V11_helperClass.getStringValue(bp.Street__c)+'</data:value> </data:STRASSE>'+
            '<data:SUBMISSION > <data:value> <data:timeStamp>'+V11_helperClass.getStringValue(bp.Submission_Date__c)+'</data:timeStamp> <data:timeZone>CET</data:timeZone> </data:value> </data:SUBMISSION>'+
            '<data:LVVERSAND > <data:value> <data:timeStamp>'+V11_helperClass.getStringValue(bp.Date_of_Service_Specification__c)+'</data:timeStamp> <data:timeZone>CET</data:timeZone> </data:value> </data:LVVERSAND>'+
            '<data:SYSTEM1 > <data:value>'+V11_helperClass.getStringValue(bp.System_1__c)+'</data:value> </data:SYSTEM1><data:SYSTEM2 > <data:value>'+V11_helperClass.getStringValue(bp.System_2__c)+'</data:value> </data:SYSTEM2> <data:SYSTEM3 ><data:value>'+V11_helperClass.getStringValue(bp.System_3__c)+'</data:value> </data:SYSTEM3>'+
            '<data:GROESSE1 > <data:value> <data:amount>'+V11_helperClass.getStringValue(bp.Size_1__c)+'</data:amount> <data:Uom > <data:code>'+V11_helperClass.getStringValue(bp.System_Unit_1__c)+'</data:code> </data:Uom> </data:value> </data:GROESSE1>'+
            '<data:GOESSE2 > <data:value> <data:amount>'+V11_helperClass.getStringValue(bp.Size_2__c)+'</data:amount> <data:Uom > <data:code>'+V11_helperClass.getStringValue(bp.System_Unit_2__c)+'</data:code> </data:Uom> </data:value> </data:GOESSE2>'+
            '<data:GROESSE3 > <data:value> <data:amount>'+V11_helperClass.getStringValue(bp.Size_3__c)+'</data:amount> <data:Uom > <data:code>'+V11_helperClass.getStringValue(bp.System_Unit_3__c)+'</data:code> </data:Uom> </data:value> </data:GROESSE3>'+
            '<data:VERSCHWIEGENHEITSERKLAERUNG > <data:value>'+V11_helperClass.getStringValue(bp.Non_Disclosure_Agreement__c)+'</data:value> </data:VERSCHWIEGENHEITSERKLAERUNG>';
            if(operation == 'create'){

                body = body + '<data:BAUHERR mode="create"> <data:Partner mode="create"> <data:number>'+V11_helperClass.getStringValue(bp.Builder_Awarding_Office_Id__c)+'</data:number> </data:Partner> </data:BAUHERR>'+
                '<data:INVESTOR mode="create"> <data:Partner mode="create"> <data:number>'+V11_helperClass.getStringValue(bp.Investor_Id__c)+'</data:number> </data:Partner> </data:INVESTOR>'+
                '<data:PROJEKTKATEGORIE mode="create"> <data:value>'+V11_helperClass.getStringValue(bp.Project_Priority__c)+'</data:value> </data:PROJEKTKATEGORIE>'+
                //'<data:VERGABESYSTEM mode="create"> <data:value>'+V11_helperClass.getStringValue(bp.Allocation_system_house__c)+'</data:value> </data:VERGABESYSTEM>'+
                '<data:VERGABEVERARBEITER mode="create"> <data:Partner mode="create"> <data:number>'+V11_helperClass.getStringValue(bp.Allocation_fabricator_Id__c)+'</data:number> </data:Partner> </data:VERGABEVERARBEITER>';
                //'<data:PROVBERECHTIGT mode="create"> <data:Employee mode="create"> <data:number>XXXXXXX<data:number> </data:Employee> </data:PROVBERECHTIGT>';

            }else if (operation == 'update'){

                    body = body + '<data:BAUHERR mode="delete"> <data:Partner mode="delete"> <data:number>'+V11_helperClass.getStringValue(bp.Builder_Awarding_Office_Id__c)+'</data:number> </data:Partner> </data:BAUHERR>'+
                    '<data:INVESTOR mode="delete"> <data:Partner mode="delete"> <data:number>'+V11_helperClass.getStringValue(bp.Investor_Id__c)+' </data:number> </data:Partner> </data:INVESTOR>'+
                    '<data:PROJEKTKATEGORIE mode="delete"><data:value>'+V11_helperClass.getStringValue(bp.Project_Priority__c)+' </data:value> </data:PROJEKTKATEGORIE>'+
                    //'<data:VERGABESYSTEM mode="delete"> <data:value>'+V11_helperClass.getStringValue(bp.Allocation_system_house__c)+'</data:value></data:VERGABESYSTEM>'+
                    '<data:VERGABEVERARBEITER mode="delete"> <data:Partner mode="delete"> <data:number>'+V11_helperClass.getStringValue(bp.Allocation_fabricator_Id__c)+'</data:number> </data:Partner> </data:VERGABEVERARBEITER>';
                    //'<data:PROVBERECHTIGT mode="delete"> <data:Employee mode="delete"> <data:number>XXXXXXXX<data:number> </data:Employee> </data:PROVBERECHTIGT>';
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


        BuildingProject__c bpUpdate = [SELECT Id FROM BuildingProject__c WHERE Id =:bp.Id__c];
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
            bpUpdate.ComarchSyncStatus__c = 'Success';
            bpUpdate.Status_Update_Id__c = String.valueOf(System.Crypto.getRandomInteger());
            if(operation == 'create'){
                bpUpdate.InitialComarchSync__c = true;
            }      
            obcUpdate.Status__c = 'Success';

            Database.update(obcUpdate, dml);
            Database.update(bpUpdate, dml);       
            
        }else{

            bpUpdate.ComarchSyncStatus__c = 'Error';
            bpUpdate.Status_Update_Id__c = String.valueOf(System.Crypto.getRandomInteger()); 
            obcUpdate.Status__c = 'Error';          
            Database.update(bpUpdate, dml);
            Database.update(obcUpdate, dml);
        }  
        
    }
}