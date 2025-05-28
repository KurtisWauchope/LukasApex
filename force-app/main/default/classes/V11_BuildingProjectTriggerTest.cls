@isTest
public class V11_BuildingProjectTriggerTest {
    @TestSetup
    static void makeData(){

        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock());
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true; 

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

        List<Comarch_Number__c> cNumbers = new List<Comarch_Number__c>();

        Comarch_Number__c numberAcc = new Comarch_Number__c();
        numberAcc.Comarch_Number_Prefix__c = '';
        numberAcc.Comarch_Number__c = '123';
        numberAcc.Object__c = 'Account';
        cNumbers.add(numberAcc);


        Comarch_Number__c numberBP = new Comarch_Number__c();
        numberBP.Comarch_Number_Prefix__c = 'VS';
        numberBP.Comarch_Number__c = '123';
        numberBP.Object__c = 'Building Project';
        cNumbers.add(numberBP);

        insert cNumbers;

        Account_Template__c temp = new Account_Template__c();
        temp.Key__c ='1000';
        insert temp;


        Account acc = new Account();

        acc.Name = 'RAICO';
        acc.Account_Template__c = temp.Id;
        acc.ComarchAccountNumber__c = '1';
        acc.BillingStreet = 'Test Street 1';
        acc.BillingCity = 'Testtown';
        acc.BillingPostalCode = '12345';
        acc.BillingCountryCode = 'DE';
        acc.Language__c = 'DE';
        acc.Type = 'Competitor';
        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock());
        Database.insert(acc,dml);
        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock());

        Account acc1 = new Account();
        acc1.Name = 'Test Fabricator';
        acc.ComarchAccountNumber__c = '2';
        acc1.Account_Template__c = temp.Id;
        acc1.BillingStreet = 'Muster straße';
        acc1.BillingCity = 'Testn';
        acc1.BillingPostalCode = '12335';
        acc1.BillingCountryCode = 'DE';
        acc1.Language__c = 'DE';
        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock());
        Database.insert(acc1,dml);
        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock());

        BuildingProject__c bp = new BuildingProject__c();

        bp.Name='Test Automation';
        bp.Amount__c=12300000;
        bp.ProjectSupported__c=true;
        bp.AwardDate__c=Date.today()+10;
        bp.BuildingType__c='Culture';
        bp.ConstructionEndPlanned__c=Date.today()+10;
        bp.DateOfServiceSpecification__c=Date.today()+10;
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
        bp.Stage__c='Research';
        bp.SubmissionDate__c=Date.today()+10;
        bp.TenderType__c='Competitive bidding';
        bp.TotalSize__c=123;
        bp.Type__c='New construction';
        bp.ConstructionStart__c=Date.today()+10;
        bp.RAICOSpecification__c=true;
        bp.ComarchBuildingProjectNumber__c='VS00000128';
        bp.BidderListSent__c=true;
        bp.ComarchSyncStatus__c='Success';
        bp.Service_specifications_sent__c=false;
        bp.Probability__c='0';

        Insert bp;

        Opportunity opp = new Opportunity();
        opp.StageName = 'Open';
        opp.Name = 'Test';
        opp.AccountId = acc1.Id;
        opp.BuildingProject__c = bp.Id;
        opp.CloseDate = Date.today();

        Insert opp;

        Opportunity opp2 = new Opportunity();
        opp2.StageName = 'Open';
        opp2.Name = 'Test Lose';
        opp2.AccountId = acc.Id;
        opp2.BuildingProject__c = bp.Id;
        opp2.CloseDate = Date.today();

        Insert opp2;

        Quote q = new Quote();
        q.OpportunityId = opp.Id;
        q.ParentOpportunity__c = opp.Id;
        q.Name = 'Test Quote';
        Insert q;
        
    }

    static testmethod void testTenderAndQuote(){
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        BuildingProject__c bp = [SELECT Id FROM BuildingProject__c WHERE Name='Test Automation'];
        bp.Service_specifications_sent__c = true;
        Test.startTest();
        Database.Update(bp,dml);
        Test.stopTest();
    }
    static testmethod void testExecutionSuccess(){
        BuildingProject__c bp = [SELECT Id FROM BuildingProject__c WHERE Name='Test Automation'];
        Account acc = [SELECT Id FROM Account WHERE Name='Test Fabricator'];
        bp.Allocationfabricator__c = acc.Id;
        bp.Probability__c = '100';
        Test.startTest();
        Update bp;
        Test.stopTest();
    }

    static testmethod void testCloseBP(){
        BuildingProject__c bp = [SELECT Id FROM BuildingProject__c WHERE Name='Test Automation'];
        bp.Stage__c = 'Closed';
        bp.Closing_Reason__c = 'Lost';
        Test.startTest();
        Update bp;
        Test.stopTest();
    }

    static testmethod void testWinOpp(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name='Test'];
        opp.StageName = 'Closed Won';
        Test.startTest();
        Update opp;
        Test.stopTest();
    }

    static testmethod void testQuote(){
        Quote q = [SELECT Id FROM Quote WHERE Name='Test Quote'];
        q.Status = 'Accepted';
        Test.startTest();
        Update q;
        Test.stopTest();
    }
}