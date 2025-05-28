public class V11_CreateOutboundCall {

    public static void insertAccount(Id accountId, String operation)
    {

        
        Account acc = [SELECT Id, BillingAddress, Name, Account_Template__c, ComarchAccountNumber__c, Language__c,Email__c,Website,Phone,Fax FROM Account WHERE Id =: accountId];
        Account_Template__c temp = [SELECT Key__c FROM Account_Template__c WHERE Id =: acc.Account_Template__c];

        List<OutboundCall__c> outboundcalls = new List<OutboundCall__c>();

        OutboundCall__c obc = new OutboundCall__c();
        obc.Status__c = 'Pending';
        obc.Object__c = 'Account';
        obc.System__c = 'comarch';
        obc.Operation__c = operation;
        if(!V11_helperClass.getIntegrationStatus('comarch')){
            obc.Status__c = 'Integration on Hold';
        }

        Insert obc;
        
        obcAccount__c obcA = new obcAccount__c();
        obcA.ID__c = acc.Id;
        obcA.Comarch_ID__c = acc.ComarchAccountNumber__c;
        obcA.Name__c = acc.Name; 
        obcA.Street__c = acc.BillingAddress.getStreet();
        obcA.City__c = acc.BillingAddress.getCity();
        obcA.Postal_Code__c = acc.BillingAddress.getPostalCode();
        obcA.Country_Code__c = acc.BillingAddress.getCountryCode();
        obcA.Outbound_Call__c = obc.Id;
        obcA.Template__c = temp.Key__c;
        obcA.Language__c = acc.Language__c;
        obcA.Email__c = acc.Email__c;
        obcA.Website__c = acc.Website;
        obcA.Phone__c = acc.Phone;
        obcA.Fax__c = acc.Fax;
        Insert obcA;


    }

    public static void updateAccount(Account account, Account OldAccount)
    {

        OutboundCall__c obc = new OutboundCall__c();
        obc.Status__c = 'Pending';
        obc.Object__c = 'Account';
        obc.System__c = 'comarch';
        obc.Operation__c = 'update';
        if(!V11_helperClass.getIntegrationStatus('comarch')){
            obc.Status__c = 'Integration on Hold';
        }

        Insert obc;

        obcAccount__c obcA = new obcAccount__c();
        obcA.Outbound_Call__c = obc.Id;
        obcA.ID__c = account.Id;
        obcA.Comarch_ID__c = account.ComarchAccountNumber__c;
        obcA.Language__c = account.Language__c;
        obcA.Email__c = account.Email__c;
        obcA.Old_Email__c = OldAccount.Email__c;
        obcA.Website__c = account.Website;
        obcA.Old_Website__c = OldAccount.Website;            
        obcA.Phone__c = account.Phone;
        obcA.Old_Phone__c = OldAccount.Phone;
        obcA.Fax__c = account.Fax;
        obcA.Old_Fax__c = OldAccount.Fax;
        obcA.Outbound_Call__c = obc.Id;

        Insert obcA;

    }
    
    public static void insertContact (List<Contact> contacts, String operation)
    {

        Map<String,String> valueKey = V11_KeyValueMap.createInverseKeyValueMap('Contact');
        List<OutboundCall__c> obcList = new List<OutboundCall__c>();
        List<obcContact__c> contactList = new List<obcContact__c>();
        
        for(Contact c:contacts){

            OutboundCall__c obcContact = new OutboundCall__c();
            obcContact.Status__c = 'Pending';
            obcContact.Object__c = 'Contact';
            obcContact.System__c = 'comarch';
            obcContact.Operation__c = operation;
            if(!V11_helperClass.getIntegrationStatus('comarch')){
                obcContact.Status__c = 'Integration on Hold';
            }
    
            obcList.add(obcContact);
        }

        Insert obcList;

        Integer index = 0;
        for(Contact c:contacts){

            obcContact__c obc = new obcContact__c();
            obc.Id__c = c.Id;            
            obc.Comarch_ID__c = c.ExternalComarchContactId__c;
            obc.Account_ID_comarch__c = c.Account.ComarchAccountNumber__c;
            obc.Salutation__c = valueKey.get('Salutation'+c.Salutation);
            obc.Title__c = valueKey.get('Title__c'+c.Title__c);
            obc.Name__c = c.LastName;
            obc.First_Name__c = c.FirstName;
            obc.Middle_Name__c = c.MiddleName;
            obc.Mobile__c = c.MobilePhone;
            obc.Phone__c = c.Phone;
            obc.Email__c = c.Email;
            obc.Language__c = c.Language__c;

            obc.Outbound_Call__c = obcList[index].Id;

            contactList.add(obc);
            index++;

        }
        Insert contactList;

    }

    public static void updateContact (List<Contact> contacts, List<Contact> oldContacts)
    {


        Map<String,String> valueKey = V11_KeyValueMap.createInverseKeyValueMap('Contact');
        List<OutboundCall__c> obcList = new List<OutboundCall__c>();
        List<obcContact__c> contactList = new List<obcContact__c>();
        
        for(Contact c:contacts){

            OutboundCall__c obcContact = new OutboundCall__c();
            obcContact.Status__c = 'Pending';
            obcContact.Object__c = 'Contact';
            obcContact.System__c = 'comarch';
            obcContact.Operation__c = 'update';
            if(!V11_helperClass.getIntegrationStatus('comarch')){
                obcContact.Status__c = 'Integration on Hold';
            }    
            obcList.add(obcContact);
        }

        Insert obcList;

        Integer index = 0;
        for(Contact c:contacts){

            obcContact__c obc = new obcContact__c();
            obc.Id__c = c.Id;            
            obc.Comarch_ID__c = c.ExternalComarchContactId__c;
            obc.Account_ID_comarch__c = c.Account.ComarchAccountNumber__c;
            obc.Salutation__c = valueKey.get('Salutation'+c.Salutation);
            obc.Title__c = valueKey.get('Title__c'+c.Title__c);
            obc.Name__c = c.LastName;
            obc.First_Name__c = c.FirstName;
            obc.Middle_Name__c = c.MiddleName;
            obc.Mobile__c = c.MobilePhone;
            obc.Old_Mobile__c = oldContacts[index].MobilePhone;
            obc.Phone__c = c.Phone;
            obc.Old_Phone__c = oldContacts[index].Phone;
            obc.Email__c = c.Email;
            obc.Old_Email__c = oldContacts[index].Email;
            obc.Language__c = c.Language__c;

            obc.Outbound_Call__c = obcList[index].Id;

            contactList.add(obc);
            index++;

        }
        Insert contactList;

    }

    public static void insertCommissionEmployee(Building_Project_Team__c bptc, String operation){

        List<OutboundCall__c> obcList = new List<OutboundCall__c>();
        List<obcCommissionEmployee__c> comList = new List<obcCommissionEmployee__c>();
        BuildingProject__c bp = [SELECT ComarchBuildingProjectNumber__c, InitialComarchSync__c FROM BuildingProject__c WHERE Id =: bptc.BuildingProject__c];
            if(bp.ComarchBuildingProjectNumber__c != null || bp.InitialComarchSync__c == true){
            OutboundCall__c obc = new OutboundCall__c();
            obc.Status__c = 'Pending';
            obc.Object__c = 'Outbound Commission Employee';
            obc.System__c = 'comarch';
            if(!V11_helperClass.getIntegrationStatus('comarch')){
                obc.Status__c = 'Integration on Hold';
            }
    
            obc.Operation__c = operation;
            System.debug('HALLOOO '+obc.Object__c);
            obcList.add(obc);   


        Insert obc;
            }
            

        Integer index = 0;

        if(bp.ComarchBuildingProjectNumber__c != null || bp.InitialComarchSync__c){
            obcCommissionEmployee__c obcCom = new obcCommissionEmployee__c();
            obcCom.BuildingProject__c = bptc.BuildingProject__c;
            obcCom.Employee__c = bptc.User__c;
            obcCom.Id__c = bptc.Id;
            obcCom.Outbound_Call__c = obcList[index].Id;
            
            comList.add(obcCom);
            index++;
            System.debug('HALLOOO 2 '+obcCom.Outbound_Call__c);
        

            Insert obcCom;
    
            }

    }

    public static void insertBuildingProject(BuildingProject__c bp, String operation)
    {

        List<Systems__c> s = [SELECT SystemType__c, SystemSize__c, SystemUnit__c, BuildingProjectSystem__c FROM Systems__c WHERE BuildingProjectSystem__r.Id =: bp.Id];
        List<Building_Project_Team__c> iTeam = [SELECT BuildingProject__c, User__r.Comarch_External_UserID__c, Entitled_to_Commission__c, ReportUser__c,Role__c FROM Building_Project_Team__c WHERE BuildingProject__r.Id =: bp.Id];
        List<Building_Project_Team__c> empTeam = [SELECT BuildingProject__c, User__r.Comarch_External_UserID__c, Entitled_to_Commission__c, ReportUser__c,Role__c FROM Building_Project_Team__c WHERE BuildingProject__r.Id =: bp.Id AND Entitled_to_Commission__c = True];
        List<AccountBuildingProjectRelation__c> relatedAccounts = [SELECT Account__r.ComarchAccountNumber__c, BuildingProject__c, Role__c FROM AccountBuildingProjectRelation__c WHERE BuildingProject__r.Id =: bp.Id];
        
        Account allocationFabricator;
        if(bp.Allocationfabricator__c != null){
            allocationFabricator = [SELECT ComarchAccountNumber__c FROM Account WHERE Id =:bp.Allocationfabricator__c];
        }

        User owner = [SELECT Id,Comarch_External_UserID__c FROM User WHERE Id=:bp.OwnerId];

        Map<String,String> accMap = new Map<String,String>();
        for(AccountBuildingProjectRelation__c acc: relatedAccounts)
        {
            accMap.put(acc.Role__c,acc.Account__r.ComarchAccountNumber__c);
        }

        Map<String,String> teamMap = new Map<String,String>();
        for(Building_Project_Team__c member : iTeam){
            teamMap.put(member.Role__c, member.User__r.Comarch_External_UserID__c);
        }

        List<String> comEmp = new  List<String>();
        for(Building_Project_Team__c m : empTeam){
            comEmp.add(m.User__r.Comarch_External_UserID__c);
        }


        Map<String,String> valueKey = V11_KeyValueMap.createInverseKeyValueMap('Building Project');

        OutboundCall__c obc = new OutboundCall__c();
        obc.Status__c = 'Pending';
        obc.Object__c = 'Building Project';
        obc.System__c = 'comarch';
        if(!V11_helperClass.getIntegrationStatus('comarch')){
            obc.Status__c = 'Integration on Hold';
        }
        obc.Operation__c = operation;

        Insert obc;

        obcBuildingProject__c obcBp = new obcBuildingProject__c();
        obcBp.Id__c = bp.Id;
        obcBP.ComarchBuildingProjectNumber__c = bp.ComarchBuildingProjectNumber__c;
        obcBp.Status__c = 'IN_PROCESS';
        obcBp.Amount__c = String.valueOf(bp.Amount__c);
        obcBp.Building_Type__c = valueKey.containsKey('BuildingType__c'+bp.BuildingType__c)? valueKey.get('BuildingType__c'+bp.BuildingType__c):'';
        obcBp.Construction_End_Planned__c = bp.ConstructionEndPlanned__c!=null?V11_helperClass.convertDate(bp.ConstructionEndPlanned__c):''; 
        obcBp.Date_of_Service_Specification__c = bp.DateOfServiceSpecification__c!=null?V11_helperClass.convertDate(bp.DateOfServiceSpecification__c):''; 
        //obcBp.internal_note__c = bp.InternalNote__c;
        //obcBp.external_note__c = bp.ExternalNote__c;
        obcBp.Street__c = bp.ProjectAddress__Street__s;
        obcBp.City__c = bp.ProjectAddress__City__s;
        obcBp.Postal_Code__c = bp.ProjectAddress__PostalCode__s;
        obcBp.Country__c = bp.ProjectAddress__CountryCode__s;
        obcBp.Name__c = bp.Name;
        obcBp.Stage__c = valueKey.get('Stage__c'+bp.Stage__c);
        obcBp.Probability__c = bp.Probability__c;
        obcBp.Project_Priority__c = valueKey.get('ProjectPriority__c'+bp.ProjectPriority__c);
        obcBp.Submission_Date__c = bp.SubmissionDate__c!=null?V11_helperClass.convertDate(bp.SubmissionDate__c):'';
        obcBp.Tender_Type__c =valueKey.get('TenderType__c'+bp.TenderType__c);
        obcBp.Total_Size__c = String.valueOf(bp.Total_Size__c);
        obcBp.Type__c = valueKey.get('Type__c'+bp.Type__c);
        obcBp.Construction_Start__c = bp.ConstructionStart__c!=null?V11_helperClass.convertDate(bp.ConstructionStart__c):'';
        obcBp.Allocation_fabricator_Id__c = allocationFabricator!=null?allocationFabricator.ComarchAccountNumber__c:''; 
        obcBp.Allocation_system_house__c = bp.Allocationsystemhouse__c; //???
        obcBp.Project_supported__c = valueKey.get('ProjectSupported__c'+(bp.ProjectSupported__c==true ?'true':'false'));
        obcBp.RAICO_specification__c = valueKey.get('RAICOSpecification__c'+(bp.RAICOSpecification__c==true ?'true':'false'));
        obcBp.Non_Disclosure_Agreement__c = valueKey.get('NonDisclosureAgreement__c'+(bp.NonDisclosureAgreement__c==true?'true':'false'));
        obcBp.Order_Entry__c = bp.OrderEntry__c!=null?V11_helperClass.convertDate(bp.OrderEntry__c):'';
        obcBp.System_1__c =s.size() > 0? valueKey.get('System__c'+s.get(0).SystemType__c):'0';
        obcBp.Size_1__c = s.size() > 0?String.valueOf(s.get(0).SystemSize__c):'0';
        obcBp.System_Unit_1__c =s.size() > 0? valueKey.get('SystemUnit__c'+s.get(0).SystemUnit__c):'';
        obcBp.System_2__c = s.size() > 1?valueKey.get('System__c'+s.get(1).SystemType__c):'0';
        obcBp.Size_2__c = s.size() > 1? String.valueOf(s.get(1).SystemSize__c):'0';
        obcBp.System_Unit_2__c = s.size() > 1? valueKey.get('SystemUnit__c'+s.get(1).SystemUnit__c):'';
        obcBp.System_3__c = s.size() > 2? valueKey.get('System__c'+s.get(2).SystemType__c):'0';
        obcBp.Size_3__c = s.size() > 2? String.valueOf(s.get(2).SystemSize__c):'0';
        obcBp.System_Unit_3__c = s.size() > 2? valueKey.get('SystemUnit__c'+s.get(2).SystemUnit__c):'';
        obcBp.Building_Project_Owner__c = owner.Comarch_External_UserID__c;
        obcBp.Project_Sales_Id__c = teamMap.get('Project Sales');
        obcBp.General_Constructor_Id__c = accMap.get('General Constructor');
        obcBp.Planner_of_cladding_Id__c = accMap.get('Planner of cladding');
        obcBp.Building_Authority_Id__c = accMap.get('Building Authority');
        obcBp.Builder_Awarding_Office_Id__c = accMap.get('Builder/ Awarding Office');
        obcBp.Investor_Id__c = accMap.get('Investor');
        obcBp.Architect_Id__c = accMap.get('Architect');
        obcBp.Outbound_Call__c = obc.Id;

        Insert obcBp;
    }

    public static void insertAccountContactRelation(List<AccountContactRelation> newObjects, String operation){



        List<OutboundCall__c> obcList = new List<OutboundCall__c>();
        List<obcAccountContactRelation__c> acrList = new List<obcAccountContactRelation__c>();

        for(AccountContactRelation acr:newObjects){
            
            if(acr.ComarchAccountNumber__c == null || acr.ComarchContactNumber__c == null ||!acr.ContactSyncStatus__c || !acr.isActive){
                continue;
            }
            OutboundCall__c obc = new OutboundCall__c();
            obc.Status__c = 'Pending';
            obc.Object__c = 'Account Contact Relation';
            obc.System__c = 'comarch';
            if(!V11_helperClass.getIntegrationStatus('comarch')){
                obc.Status__c = 'Integration on Hold';
            }
    
            obc.Operation__c = operation;
    
            obcList.add(obc);   

        }

        Insert obcList;

        Integer index = 0;
        for(AccountContactRelation acr:newObjects){

            if(acr.ComarchAccountNumber__c == null || acr.ComarchContactNumber__c == null ||!acr.ContactSyncStatus__c|| !acr.isActive){
                continue;
            }                  
            obcAccountContactRelation__c obcACR = new obcAccountContactRelation__c();
            obcACR.Account__c = acr.ComarchAccountNumber__c;
            obcACR.Contact__c = acr.ComarchContactNumber__c;
            obcACR.Id__c = acr.Id;
            obcACR.InitialContactRelation__c = acr.InitialContactRelation__c;
            obcACR.Outbound_Call__c = obcList[index].Id;
            
            acrList.add(obcACR);
            index++;

        }

        Insert acrList;
    }

    public static void updateAccountContactRelation(List<AccountContactRelation> newObjects, Map<Id,AccountContactRelation> oldObjects){


        List<OutboundCall__c> obcList = new List<OutboundCall__c>();
        List<obcAccountContactRelation__c> acrList = new List<obcAccountContactRelation__c>();

        for(AccountContactRelation acr:newObjects){            

            
            if(acr.ComarchAccountNumber__c == null || acr.ComarchContactNumber__c == null || !acr.ContactSyncStatus__c||
            (acr.IsActive == oldObjects.get(acr.Id).IsActive && acr.Synced__c)){
                continue;
            }
            OutboundCall__c obc = new OutboundCall__c();
            obc.Status__c = 'Pending';
            obc.Object__c = 'Account Contact Relation';
            obc.System__c = 'comarch';
            if(acr.isActive){
                obc.Operation__c = 'create';
            }else{
                obc.Operation__c = 'delete';
            }
            if(!V11_helperClass.getIntegrationStatus('comarch')){
                obc.Status__c = 'Integration on Hold';
            }
                
    
            obcList.add(obc);

    

        }

        Insert obcList;
        Integer index = 0;

        for(AccountContactRelation acr:newObjects){

            if(acr.ComarchAccountNumber__c == null || acr.ComarchContactNumber__c == null || !acr.ContactSyncStatus__c||
            (acr.IsActive == oldObjects.get(acr.Id).IsActive && acr.Synced__c)){
                continue;
            }                   
            obcAccountContactRelation__c obcACR = new obcAccountContactRelation__c();
            obcACR.Account__c = acr.ComarchAccountNumber__c;
            obcACR.Contact__c = acr.ComarchContactNumber__c;
            obcACR.Id__c = acr.Id;
            obcACR.InitialContactRelation__c = acr.InitialContactRelation__c;
            obcACR.Outbound_Call__c = obcList[index].Id;
            
            acrList.add(obcACR);
            index++;

        }
        Insert acrList;
    }

}