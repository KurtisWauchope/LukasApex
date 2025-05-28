@isTest 
public class V11_DeleteVisitReportContactTest {

    @isTest static void testcontactrelationdelete() {
        
        // create test data
            Account testvraccount = new Account(
            Name = 'Vision Eleven again',
            BillingCountry = 'Germany',
            BillingStreet = 'Pettenkoferstr.',
            BillingCity ='Munich',
            BillingPostalCode = '80336',
            Phone = '+491234565589',
            Account_Template__c = 'a0L7Q000004gmqDUAQ', 
            Language__c = 'en') ;
        
            insert testvraccount;
			
            Contact testvrcontact = new Contact(
			LastName = 'Swain',
			Email = 'Testcontact@v11.co',			
            Language__c = 'en',
            Salutation = 'Mr.',
            Accountid = testvraccount.id);

			insert testvrcontact;
        	
            VisitReport__c testvisitreport = new VisitReport__c(
            Account__c = testvraccount.id,
            Contact__c = testvrcontact.Id,
            Name = 'just visiting'  
            );
            insert testvisitreport;
        
            Visit_Report_Contact_Relation__c testvrcontactrelation = new Visit_Report_Contact_Relation__c(
            Contact__c = testvrcontact.Id,
            Visit_Report__c = testvisitreport.Id    
            );
            
            insert testvrcontactrelation;
        
        // get Visit report contact relation for test setup
        List<Visit_Report_Contact_Relation__c> relationsBeforeDelete = [SELECT Id FROM Visit_Report_Contact_Relation__c WHERE Contact__c = :testvrcontact.Id ];
        
        // get the corresponding contact
        List <Contact> beforedeleterelatedcontact = [SELECT Id FROM Contact WHERE id = :testvrcontact.Id];
        
        //assert that there is at least one contact relation
        System.assertEquals(1, relationsBeforeDelete.size(), 'There should be 1 related Visit_Report_Contact_Relation__c record before deleting the Contact.');
        
        
        delete beforedeleterelatedcontact;
        
        // assert that there are no visit report contact relations after deleting the contact
        List<Visit_Report_Contact_Relation__c> relationsAfterDelete = [SELECT Id FROM Visit_Report_Contact_Relation__c WHERE Contact__c = :testvrcontact.Id];
        System.assertEquals(0, relationsAfterDelete.size(), 'The related Visit_Report_Contact_Relation__c record should be deleted after deleting the Contact.');
        // now that the contact relation has been deleted see that the contact can now be deleted
        
        // assert that the contact has been deleted
        List <Contact> afterdeleterelatedcontact = [SELECT Id FROM Contact WHERE id = :testvrcontact.Id];
        System.assertEquals(0, afterdeleterelatedcontact.size(), 'should be possible to delete the contact');
    }

   @isTest
    static void testDeleteContactWithoutRelation() {
        // Create a test Contact with no relation record
        Contact testContact = new Contact(LastName = 'Test Contact No Relation');
        insert testContact;

        // Delete the contact with no relation to ensure it doesn’t throw an error
        delete testContact;

        // Confirm no exception and no Visit_Report_Contact_Relation__c records
        List<Visit_Report_Contact_Relation__c> relationsAfterDelete = [SELECT Id FROM Visit_Report_Contact_Relation__c WHERE Contact__c = :testContact.Id];
        System.assertEquals(0, relationsAfterDelete.size(), 'No related Visit_Report_Contact_Relation__c records should exist.');
    }
     
  }