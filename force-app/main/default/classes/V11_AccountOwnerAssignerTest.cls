@isTest
public class V11_AccountOwnerAssignerTest {

    @TestSetup
    static void makeData(){

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

        User u1 = new User();
        u1.LastName = 'alias2';
        u1.UserName = 'testuser2@raico.de';
        u1.Email = 'test2@raico.de';
        u1.alias = 'alias2';
        u1.TimeZoneSidKey = 'Europe/Berlin';
        u1.LocaleSidKey = 'de_DE_EURO';
        u1.EmailEncodingKey = 'ISO-8859-1';
        u1.ProfileId = p.Id;
        u1.LanguageLocaleKey = 'de';
        u1.Comarch_External_UserID__c = '123457';

        insert u1;

        Role_Assignment__c ra = new Role_Assignment__c();
        ra.PrimaryRole__c = 'Sales';
        ra.Additional_Roles__c = 'Project Sales';
        ra.Objecttype__c = 'Account';
        ra.Type__c = 'Account';

        insert ra;

        Postal_Code_Assignment__c pca = new Postal_Code_Assignment__c();
        pca.Role__c = 'Sales';
        pca.User__c = u.Id;
        pca.Country__c = 'DE';

        insert pca;

        Postal_Code_Assignment__c pca1 = new Postal_Code_Assignment__c();
        pca1.Role__c = 'Project Sales';
        pca1.User__c = u1.Id;
        pca1.Country__c = 'DE';

        insert pca1;

        Postal_Code_Range__c pcr = new Postal_Code_Range__c();
        pcr.Postal_Code_Start__c = 0;
        pcr.PostalCodeEnd__c = 99999;
        pcr.PostalCodeAssignment__c = pca.Id;

        insert pcr;

        
        Postal_Code_Range__c pcr1 = new Postal_Code_Range__c();
        pcr1.Postal_Code_Start__c = 0;
        pcr1.PostalCodeEnd__c = 99999;
        pcr1.PostalCodeAssignment__c = pca1.Id;

        insert pcr1;

        Account acc = new Account();
        Account_Template__c temp = new Account_Template__c();
        temp.Key__c ='1000';
        insert temp;

        acc.Name = 'Test';
        acc.Account_Template__c = temp.Id;
        acc.ComarchAccountNumber__c = '123';
        acc.BillingStreet = 'Test Street 1';
        acc.BillingCity = 'Testtown';
        acc.BillingPostalCode = '12345';
        acc.BillingCountryCode = 'DE';
        Database.insert(acc);

        Contact c = new Contact();
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

        Database.insert(c);



    }

    static testmethod void testAccounOwnerUodate(){

        Account acc = [SELECT Id FROM Account WHERE Name ='Test'];
        
        Test.startTest();
        V11_AccountOwnerUpdate.updateAccountOwner(acc.Id);
        test.stopTest();

    }
}