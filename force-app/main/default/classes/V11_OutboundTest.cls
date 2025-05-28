@istest
public class V11_OutboundTest {

    @TestSetup
    static void makeData(){

        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock());
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true; 

        List<Comarch_Number__c> cNumbers = new List<Comarch_Number__c>();

        Comarch_Number__c numberAcc = new Comarch_Number__c();
        numberAcc.Comarch_Number_Prefix__c = '';
        numberAcc.Comarch_Number__c = '123';
        numberAcc.Object__c = 'Account';
        cNumbers.add(numberAcc);

        Comarch_Number__c numberC = new Comarch_Number__c();
        numberC.Comarch_Number_Prefix__c = '';
        numberC.Comarch_Number__c = '123';
        numberC.Object__c = 'Contact';
        cNumbers.add(numberC);

        Comarch_Number__c numberBP = new Comarch_Number__c();
        numberBP.Comarch_Number_Prefix__c = 'VS';
        numberBP.Comarch_Number__c = '123';
        numberBP.Object__c = 'Building Project';
        cNumbers.add(numberBP);

        insert cNumbers;

        Profile p = [select id from profile where name ='System Administrator'][0];

        User u = new User();
        u.LastName = 'alias1';
        u.UserName = 'testuser@raico.de';
        u.Email = 'test@raico.de';
        u.alias = 'alias1';
        u.TimeZoneSidKey = 'Europe/Berlin';
        u.LocaleSidKey = 'de_DE_EURO';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = p.Id;
        u.LanguageLocaleKey = 'de';
        u.Comarch_External_UserID__c = '123456';
        insert u;

        Account acc = new Account();
        Account_Template__c temp = new Account_Template__c();
        temp.Key__c ='1000';
        insert temp;

        acc.Name = 'Test ist das wirklich nur ein Test oder warum ist dieser Name so Lang, bitte sein einfach nur lang genug - reicht das jetzt? Ich glaube schon';
        acc.Account_Template__c = temp.Id;
        acc.ComarchAccountNumber__c = '123';
        acc.BillingStreet = 'Test Street 1';
        acc.BillingCity = 'Testtown';
        acc.BillingPostalCode = '12345';
        acc.BillingCountryCode = 'DE';
        acc.Language__c = 'DE';
        acc.Website = 'www.test.com';
        acc.Email__c = 'test@account.com';
        acc.Phone = '+49123123';
        acc.Fax ='+49123123';
        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock());
        Database.insert(acc,dml);
        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock());

        Account acc1 = new Account();
        acc1.Name = 'Test Number';
        acc1.Account_Template__c = temp.Id;
        acc1.BillingStreet = 'Muster straße';
        acc1.BillingCity = 'Testn';
        acc1.BillingPostalCode = '12335';
        acc1.BillingCountryCode = 'DE';
        acc1.Language__c = 'DE';
        acc.Website = 'www.test.com';
        acc.Email__c = 'test@account.com';
        acc.Phone = '+49123123';
        acc.Fax ='+49123123';
        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock());
        Database.insert(acc1,dml);
        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock());

        List<Contact> contacts = new List<Contact>();
        Contact c = new Contact();
        KeyValuePair__c kvp = new KeyValuePair__c();
        kvp.Field__c = 'Title__c';
        kvp.Key__c = 'ArchitektIn';
        kvp.Value__c = 'ArchitektIn';
        kvp.Object__c = 'Contact';
        insert kvp;

        c.ExternalComarchContactId__c = '123';
        c.AccountId = acc.Id;
        c.Salutation = 'Ms.';
        c.Title__c = 'ArchitektIn';
        c.LastName = 'Test';
        c.FirstName = 'hm';
        c.MiddleName = 'Lol';
        c.MobilePhone = '+491234';
        c.Phone = '+491234';
        c.Email = 'test@test.com';
        c.Language__c = 'de';

        contacts.add(c);

        Contact cIdent = new Contact();
        cIdent.ExternalComarchContactId__c = '1234';
        cIdent.AccountId = acc.Id;
        cIdent.Salutation = 'Ms.';
        cIdent.Title__c = 'ArchitektIn';
        cIdent.LastName = 'Test';
        cIdent.FirstName = 'hm';
        cIdent.MiddleName = 'Lol';
        cIdent.MobilePhone = '+491234';
        cIdent.Phone ='+491234';
        cIdent.Email = 'test@test.com';
        cIdent.Language__c = 'de';
        contacts.add(cIdent);

        Contact c1 = new Contact();
        c1.ExternalComarchContactId__c = '1235';
        c1.AccountId = acc.Id;
        c1.Salutation = 'Mr.';
        c1.Title__c = 'ArchitektIn';
        c1.LastName = 'Test';
        c1.FirstName = 'hm';
        c1.MiddleName = 'Lol';
        c1.MobilePhone = '+491234';
        c1.Phone = '+491234';
        c1.Email = 'test@asxd.com';
        c1.Language__c = 'de';

        contacts.add(c1);

        Contact c2 = new Contact();
        c2.ExternalComarchContactId__c = '1236';
        c2.AccountId = acc.Id;
        c2.Salutation = '';
        c2.Title__c = 'ArchitektIn';
        c2.LastName = 'Test';
        c2.FirstName = 'hm';
        c2.MiddleName = 'Lol';
        c2.MobilePhone = '+491234';
        c2.Phone = '+491234';
        c2.Email = 'tesfghft@tesfghfgt.com';
        c2.Language__c = 'de';

        contacts.add(c2);

        Contact c3 = new Contact();
        c3.AccountId = acc.Id;
        c3.ExternalComarchContactId__c = '12365567';
        c3.Salutation = '';
        c3.LastName = 'Test das';
        c3.FirstName = 'Test Number';
        c3.MiddleName = 'hä';
        c3.MobilePhone = '+49123434534';
        c3.Phone = '+49123567564';
        c3.Email = 'tedfghdfgst@tedgfhdfgst.com';
        c3.Language__c = 'de';

        contacts.add(c3);



        System.debug(Database.insert(contacts, dml));

        List<AccountContactRelation> acrs = [SELECT isActive, Id FROM AccountContactRelation WHERE ContactId =: c3.Id];
        for(AccountContactRelation acr:acrs ){
            acr.Synced__c = true;
        }
        Database.update(acrs,dml);

        BuildingProject__c bp = new BuildingProject__c();

        bp.Name='Test Schnitti';
        bp.Amount__c=12300000;
        bp.ProjectSupported__c=true;
        bp.AwardDate__c=Date.today()+10;
        bp.BuildingType__c='Culture';
        bp.ConstructionEndPlanned__c=Date.today()+10;
        bp.DateOfServiceSpecification__c=Date.today()+10;
        //bp.InternalNote__c='dfgdfg';
        bp.ExternalNote__c='fghfgh';
        bp.LeadSource__c='Construction site';
        bp.Material__c='Aluminium';
        bp.NonDisclosureAgreement__c=true;
        bp.OrderEntry__c=Date.today()+10;
        bp.ProjectAddress__Street__s='Pettenkoferstraße 13';
        bp.ProjectAddress__City__s='Berlin';
        bp.ProjectAddress__PostalCode__s='10247';
        bp.ProjectAddress__CountryCode__s='DE';
        bp.ProjectPreview__c=true;
        bp.ProjectPriority__c='Prio A';
        bp.Stage__c='Award System house';
        bp.SubmissionDate__c=Date.today()+10;
        bp.TenderType__c='Competitive bidding';
        bp.TotalSize__c=123;
        bp.Type__c='New construction';
        bp.ConstructionStart__c=Date.today()+10;
        bp.RAICOSpecification__c=true;
        bp.Allocationfabricator__r= acc;
        bp.ComarchBuildingProjectNumber__c='VS00000128';
        bp.BidderListSent__c=true;
        bp.ComarchSyncStatus__c='Success';
        bp.Service_specifications_sent__c=false;
        bp.Probability__c='0';
        bp.OwnerId = u.Id;

        Database.insert(bp,dml);

        BuildingProject__c bp1 = new BuildingProject__c();

        bp1.Name='Test Number';
        bp1.Amount__c=12300000;
        bp1.ProjectSupported__c=true;
        bp1.AwardDate__c=Date.today()+10;
        bp1.BuildingType__c='Culture';
        bp1.ConstructionEndPlanned__c=Date.today()+10;
        bp1.DateOfServiceSpecification__c=Date.today()+10;
        //bp1.InternalNote__c='dfgdfg';
        bp1.ExternalNote__c='fghfgh';
        bp1.LeadSource__c='Construction site';
        bp1.Material__c='Aluminium';
        bp1.NonDisclosureAgreement__c=true;
        bp1.OrderEntry__c=Date.today()+10;
        bp1.ProjectAddress__Street__s='Pettenkoferstraße 13';
        bp1.ProjectAddress__City__s='Berlin';
        bp1.ProjectAddress__PostalCode__s='10247';
        bp1.ProjectAddress__CountryCode__s='DE';
        bp1.ProjectPreview__c=true;
        bp1.ProjectPriority__c='Prio A';
        bp1.Stage__c='Award System house';
        bp1.SubmissionDate__c=Date.today()+10;
        bp1.TenderType__c='Competitive bidding';
        bp1.TotalSize__c=123;
        bp1.Type__c='New construction';
        bp1.ConstructionStart__c=Date.today()+10;
        bp1.RAICOSpecification__c=true;
        bp1.Allocationfabricator__r= acc;
        bp1.BidderListSent__c=true;
        bp1.ComarchSyncStatus__c='Success';
        bp1.Service_specifications_sent__c=false;
        bp1.Probability__c='0';
        bp1.OwnerId = u.Id;

        Database.insert(bp1,dml);

        Systems__c  sys = new Systems__c ();

        sys.SystemType__c='Aluminiumfassade';
        sys.SystemSize__c=89;
        sys.SystemUnit__c='sqm';
        sys.BuildingProjectSystem__c = bp.Id;


        Systems__c  sys2 = new Systems__c ();

        sys2.SystemType__c='Aluminiumfassade';
        sys2.SystemSize__c=89;
        sys2.SystemUnit__c='sqm';
        sys2.BuildingProjectSystem__c = bp.Id;

        Systems__c  sys3 = new Systems__c ();

        sys3.SystemType__c='Aluminiumfassade';
        sys3.SystemSize__c=89;
        sys3.SystemUnit__c='sqm';
        sys3.BuildingProjectSystem__c = bp.Id;

        insert sys;
        insert sys2;
        insert sys3;

        Building_Project_Team__c bpt = new Building_Project_Team__c();
        bpt.BuildingProject__c = bp.Id;
        bpt.Role__c = 'Project Sales';
        bpt.User__c = u.Id;

        insert bpt;


        AccountBuildingProjectRelation__c abp = new AccountBuildingProjectRelation__c ();
        abp.BuildingProject__c = bp.Id;
        abp.Account__c = acc.Id;
        abp.Role__c = 'Planner of cladding';

        insert abp;



        


    }
    static testmethod void testAccountInsert(){

        List<Account> accs = [SELECT ID FROM Account];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock());

        V11_CreateOutboundCall.insertAccount(accs[0].id, 'create');

        List<OutboundCall__c> obc = [SELECT id  FROM OutboundCall__c WHERE Object__c = 'Account'];
        V11_CallComarchOutboundCalls.resendObject(obc[0].Id);

        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock('Error'));

        V11_CreateOutboundCall.insertAccount(accs[0].id, 'create');

        Test.stopTest();

    }

    static testmethod void testAccountUpdate(){

        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock());
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;

        User u = [SELECT Id FROM User WHERE Comarch_External_UserID__c = '123456'];

        List<Account> accs = [SELECT ID FROM Account];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock());

        accs[0].Phone = '+49123124';
        accs[0].Fax = '+49123124';
        accs[0].Website = 'www.test.de';
        accs[0].Email__c = 'test@account.de';

        System.runAs(u){
            Database.update(accs,dml);
        } 

        Test.stopTest();

    }

    static testmethod void testContactInsert(){

        List<Contact> createContact = [SELECT Id,ExternalComarchContactId__c,Account.ComarchAccountNumber__c,Salutation,Title__c,LastName,FirstName,MiddleName,MobilePhone,Phone,Email,Language__c FROM Contact];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock());
        V11_CreateOutboundCall.insertContact(createContact, 'create');
        List<OutboundCall__c> obc = [SELECT id  FROM OutboundCall__c WHERE Object__c = 'Contact'];
        V11_CallComarchOutboundCalls.resendObject(obc[0].Id);

        Test.stopTest();

    }

    static testmethod void testContactUpdate(){

        Contact updateContact = [SELECT Id,ExternalComarchContactId__c,Account.ComarchAccountNumber__c,Salutation,Title__c,LastName,FirstName,MiddleName,MobilePhone,Phone,Email,Language__c FROM Contact WHERE ExternalComarchContactId__c ='123'];

        Contact oldContact = updateContact;
        updateContact.MobilePhone = '+490000';
        updateContact.Phone = '+490000';
        updateContact.Email = 'update@update.com';

        List<Contact> oldContacts = new List<Contact>();
        List<Contact> updateContacts = new List<Contact>();
        oldContacts.add(oldContact);
        updateContacts.add(updateContact);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock('Error'));
        V11_CreateOutboundCall.updateContact(updateContacts, oldContacts);

        Test.stopTest();

    }

    static testmethod void testBPInsert(){

        BuildingProject__c bp = [SELECT Id, OwnerId, Name,Allocationfabricator__r.ComarchAccountNumber__c, AdditionalAddressInformation__c, Amount__c,  ProjectSupported__c, AwardDate__c, AwardCountdown__c, BuildingType__c, ConstructionEndPlanned__c, DateOfServiceSpecification__c, /*InternalNote__c,*/ ExternalNote__c, ProjectID__c, Geolocation__Latitude__s, Geolocation__Longitude__s, Geolocation__c, LeadSource__c, Material__c, NonDisclosureAgreement__c, OrderEntry__c, ProjectAddress__Street__s, ProjectAddress__City__s, ProjectAddress__PostalCode__s, ProjectAddress__StateCode__s, ProjectAddress__CountryCode__s, ProjectAddress__Latitude__s, ProjectAddress__Longitude__s, ProjectAddress__GeocodeAccuracy__s, ProjectAddress__c, Probability__c, ProjectPriority__c, Stage__c, SubmissionDate__c, SubmissionCountdown__c, TenderType__c, TotalSize__c, Type__c, ConstructionStart__c, ConstructionDuration__c, /*EntitledToCommission__c,*/ RAICOSpecification__c, Allocationfabricator__c, Allocationsystemhouse__c, DateofServiceSpecificationCountdown__c, ComarchBuildingProjectNumber__c, Postal_Code_City__c, ConstructionDurationFormula__c,Total_Size__c FROM BuildingProject__c WHERE ComarchBuildingProjectNumber__c = 'VS00000128'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock('Error'));
        V11_CreateOutboundCall.insertBuildingProject(bp, 'create');

        List<OutboundCall__c> obc = [SELECT id  FROM OutboundCall__c WHERE Object__c = 'Building Project'];
        V11_CallComarchOutboundCalls.resendObject(obc[0].Id);

        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock());
        V11_CreateOutboundCall.insertBuildingProject(bp, 'update');

        Test.stopTest();
    }

    static testmethod void testACRUpdate(){
        List<AccountContactRelation> acr= [SELECT Id, AccountId, ContactId, Roles, IsDirect, IsActive, StartDate, EndDate, IsDeleted, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Relationship_Strength__c, ComarchAccountNumber__c, ComarchContactNumber__c, Synced__c, InitialContactRelation__c, Decision_maker__c,ContactSyncStatus__c FROM AccountContactRelation WHERE Account.ComarchAccountNumber__c = '123'];
        Map<Id,AccountContactRelation> acrOld = new Map<Id,AccountContactRelation>();
        acrOld.putAll(acr);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock('Error'));
        V11_CreateOutboundCall.insertAccountContactRelation(acr, 'create');
        acr[0].IsActive = false;
        V11_CreateOutboundCall.updateAccountContactRelation(acr, acrOld);        
        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock());
        V11_CreateOutboundCall.updateAccountContactRelation(acr, acrOld); 


        Test.stopTest();

        
    }

    static testmethod void testNamesplit(){

        String test = 'aaaaa';
        V11_helperClass.splitName(test);
        test = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        V11_helperClass.splitName(test);
        test = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        V11_helperClass.splitName(test);
        test = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        V11_helperClass.splitName(test);

    }

    static testmethod void testNumberManager(){

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock('Error'));

        /*BuildingProject__c bp = [SELECT Id FROM BuildingProject__c WHERE Name = 'Test Number'];
        V11_ComarchNumberManager.setNumberBP(bp.Id);
        Contact c = [SELECT Id FROM Contact WHERE Email = 'tedfghdfgst@tedgfhdfgst.com'];
        c.ExternalComarchContactId__c = '';
        update c;
        V11_ComarchNumberManager.setNumberContact(c.Id);
        Account a = [SELECT Id FROM Account WHERE Name = 'Test Number'];
        V11_ComarchNumberManager.setNumberAccount(a.Id);*/

        Test.stopTest();
    }

}