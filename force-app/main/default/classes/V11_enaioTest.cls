@isTest
public class V11_enaioTest {
    @TestSetup
    static void makeData(){

        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;

        Account acc = new Account();
        Account_Template__c temp = new Account_Template__c();
        temp.Key__c ='1000';
        insert temp;

        Account acc1 = new Account();
        acc1.Name = 'Test Number';
        acc1.Account_Template__c = temp.Id;
        acc1.BillingStreet = 'Muster straße';
        acc1.BillingCity = 'Test';
        acc1.BillingPostalCode = '12335';
        acc1.BillingCountryCode = 'DE';
        acc1.ComarchAccountNumber__c = '123';

        Database.insert(acc1,dml);

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

    }
    static testmethod void sendAccount(){

        Account acc = [SELECT Id,ComarchAccountNumber__c,Name,BillingStreet,BillingCountry,BillingPostalCode,BillingCity FROM Account WHERE ComarchAccountNumber__c = '123'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock('enaio'));

        V11_sendObjectToEnaio queue = new V11_sendObjectToEnaio(acc);
        System.enqueueJob(queue);

        Test.stopTest();

    }

    static testmethod void sendBP(){

        BuildingProject__c bp = [SELECT Id,ComarchBuildingProjectNumber__c,OwnerId,Name, ProjectAddress__City__s FROM BuildingProject__c WHERE ComarchBuildingProjectNumber__c = 'Test'];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new V11_WebServiceMock('enaio'));

        V11_sendObjectToEnaio queue = new V11_sendObjectToEnaio(bp);
        System.enqueueJob(queue);

        Test.stopTest();

    }
}