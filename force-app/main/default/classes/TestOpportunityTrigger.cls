/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-29-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class TestOpportunityTrigger {
    @isTest
    static void testPreviousStageField() {
        // Testdaten vorbereiten - Account mit Adresse
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingStreet = 'Teststraße 1',
            BillingCity = 'Teststadt',
            BillingPostalCode = '12345',
            BillingCountry = 'Germany'
        );
        insert testAccount;
        
        // Opportunity erstellen
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        
        // Alle erforderlichen Felder setzen
        Test.startTest();
        insert opp;
        
        // Status ändern
        opp.StageName = 'Qualification';
        update opp;
        Test.stopTest();
        
        // Ergebnis prüfen
        Opportunity updatedOpp = [SELECT Id, StageName, Previous_Stage__c FROM Opportunity WHERE Id = :opp.Id];
        System.debug('Test Ergebnis - StageName: ' + updatedOpp.StageName + ', Previous_Stage__c: ' + updatedOpp.Previous_Stage__c);
        
        // Assertion
        System.assertEquals('Prospecting', updatedOpp.Previous_Stage__c, 'Previous_Stage__c sollte den vorherigen Status enthalten');
    }
}