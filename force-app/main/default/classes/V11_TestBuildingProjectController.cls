@istest
public class V11_TestBuildingProjectController {
    
    @TestSetup
    static void setupData()
    {
        Account a = new Account();
        a.Name = 'test';
        a.Type = 'Architect';
        a.ComarchAccountNumber__c = 'test';
        a.BillingStreet = 'Test Street 1';
        a.BillingCity = 'Testtown';
        a.BillingPostalCode = '12345';
        a.BillingCountryCode = 'DE';
        insert a;
        
        Contact c = new Contact();
        c.LastName = 'test';
        c.Email = 'test@test.de';
        c.AccountId = a.id;
        c.MobilePhone = '+491234';
        c.Phone = '+491234';
        c.Email = 'test@test.com';
        c.ExternalComarchContactId__c = '123';
        insert c;
        
        BuildingProject__c bp = new BuildingProject__c();
        bp.Name = 'test';
        bp.Amount__c = 123;
        bp.Stage__c = 'Research';
        bp.ComarchBuildingProjectNumber__c='Test';
        bp.ProjectAddress__Street__s='Pettenkoferstraße 13';
        bp.ProjectAddress__City__s='Berlin';
        bp.ProjectAddress__PostalCode__s='10247';
        bp.ProjectAddress__CountryCode__s='DE';
        insert bp;
        
        Bidder__c bidder = new Bidder__c();
        bidder.ContactPerson__c = c.Id;
        bidder.Building_Project__c = bp.Id;
        bidder.Account__c = a.Id;
        insert bidder;

        AccountBuildingProjectRelation__c ar = new AccountBuildingProjectRelation__c();
        ar.Account__c = a.Id;
        ar.BuildingProject__c = bp.Id;
        ar.Role__c = 'Architect';
        insert ar;
        
        AccountBuildingProjectRelation__c gc = new AccountBuildingProjectRelation__c();
        gc.Account__c = a.Id;
        gc.BuildingProject__c = bp.Id;
        gc.Role__c = 'General Constructor';
        insert gc;
        
        AccountBuildingProjectRelation__c p = new AccountBuildingProjectRelation__c();
        p.Account__c = a.Id;
        p.BuildingProject__c = bp.Id;
        p.Role__c = 'Planner of cladding';
        insert p;
        
        AccountBuildingProjectRelation__c ba = new AccountBuildingProjectRelation__c();
        ba.Account__c = a.Id;
        ba.BuildingProject__c = bp.Id;
        ba.Role__c = 'Building Authority';
        insert ba;
        
        Systems__c sy = new Systems__c();
        sy.BuildingProjectSystem__c = bp.Id;
        sy.SystemType__c = 'Holzdach';
        sy.SystemUnit__c = 'sqm';
        sy.SystemSize__c = 30.0;
        insert sy;
    }
    
    static testmethod void buildingProjectControllerTest()
    {        
        List<BuildingProject__c> bps = [select id, ComarchBuildingProjectNumber__c, Name from BuildingProject__c];        
        ApexPages.StandardController sc = new ApexPages.StandardController(bps.get(0));
        
        Test.startTest();
        V11_BuildingProjectControllerExtension v11Controller = new V11_BuildingProjectControllerExtension(sc);
        v11Controller.getBidders();  
        v11Controller.getArchs();      
        v11Controller.getSystems();
        v11Controller.getProjectSalesRep();
        v11Controller.getBAuth();
        v11Controller.getPlanner();
        v11Controller.getGC();

        Test.stopTest();
        
    }

}