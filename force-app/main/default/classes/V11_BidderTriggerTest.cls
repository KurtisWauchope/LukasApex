@istest
private class V11_BidderTriggerTest {
    
    static testmethod void BidderTriggerTest()
    {        
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Raico_bidder'];
        String rty = rt.Id;
        Account a = new Account();
        a.Name = 'test3';
        a.Type = 'Architect';
        a.ComarchAccountNumber__c = 'test1';
        a.BillingStreet = 'Test Street 1';
        a.BillingCity = 'Testtown';
        a.BillingPostalCode = '12345';
        a.BillingCountryCode = 'DE';
        insert a;
        
        BuildingProject__c bp = new BuildingProject__c();
        bp.Name = 'test';
        bp.Amount__c = 123;
        bp.Stage__c = 'Research';
        bp.ComarchBuildingProjectNumber__c = 'Test';
        bp.ProjectAddress__Street__s = 'Pettenkoferstraße 13';
        bp.ProjectAddress__City__s = 'Berlin';
        bp.ProjectAddress__PostalCode__s = '10247';
        bp.ProjectAddress__CountryCode__s = 'DE';
        bp.BidderListSent__c = true;
        insert bp;


        Bidder__c b = new Bidder__c();
        b.Name = 'TEST123';
        b.RecordTypeId = rty;
        b.Account__c = a.Id;
        b.Building_Project__c = bp.Id;
        insert b;
        
        try {
            delete b;
            System.assert(false, 'Bidder__c record should not be deleted');
        } catch (DmlException ex) {
            System.assert(ex.getMessage().contains(Label.BidderDeletionErr), 'Expected error message not found');
        }
        
    }

}