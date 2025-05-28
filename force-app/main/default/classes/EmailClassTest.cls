/**
 * @this is testing the email class, creating a test user, some test contacts and corresponding bidders all linked to the same building project. The subject and text body is asserted in the class
 * @Date 20 August 2024-Kurtis Wauchope
 */
@IsTest
public class EmailClassTest {
    
    @testSetup
    static void setupTestData() {
        // Create a test user
        User testUser = new User(
            Username = 'testuserv@test.com',
            LastName = 'Test',
            Email = 'kurtis.wauchope@visioneleven.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'Europe/Berlin',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
       // create a test Building Project
     BuildingProject__c  testingBuildingProject = new BuildingProject__c(
     Name = 'Test Building Project', 
     ProjectAddress__Street__s = 'Pettenkoferstr. 33',
     ProjectAddress__City__s = 'Munich',
     ProjectAddress__PostalCode__s= '80336');
     insert testingBuildingProject;  
        
    
        
   //  Create an Account   
   Account testaccount = new Account(
   Name = 'Vision Eleven',
   BillingCountry = 'Germany',
   BillingStreet = 'Pettenkoferstr.',
   BillingCity ='Munich',
   BillingPostalCode = '80336',
   Phone = '+49123456789',
   Account_Template__c = 'a0L7Q000004gmqDUAQ', 
   Language__c = 'en') ;
   insert testaccount;
        
      // create a test contact en language
    Contact testcontacten = new Contact(
    LastName = 'Eleven',
    Email = 'test@v11.com',
    Salutation = 'Mr.',
    Language__c = 'en',
    Accountid = testaccount.id);
    insert testcontacten;
        
    // Create test contact without language or salutation    
    Contact testcontactx = new Contact(
    LastName = 'Eleven',
    Email = 'testx@v11.com',
    Salutation = '',
    Language__c = '',
    Accountid = testaccount.id);
    insert testcontactx;
   
    //create a test contact de language 
    Contact testcontactde = new Contact(
    LastName = 'Elevende',
    Email = 'testde@v11.com',
    Salutation = 'Mr.',
    Language__c = 'de',
    Accountid = testaccount.id);
    insert testcontactde;  
       
    
   //create a test contact fr language 
    Contact testcontactfr = new Contact(
    LastName = 'Elevenfr',
    Email = 'testfr@v11.com',
    Salutation = 'Mr.',
    Language__c = 'fr',
    Accountid = testaccount.id);
    insert testcontactfr;   
    
   // create test contact fr madame
    Contact testcontactfrmadm = new Contact(
    LastName = 'Elevenfrm',
    Email = 'testfrm@v11.com',
    Salutation = 'Madame',
    Language__c = 'fr',
    Accountid = testaccount.id);
    insert testcontactfrmadm; 
        
    // create a test Bidder en    
   Bidder__c testBidderen = new Bidder__c(
   Building_Project__c = testingBuildingProject.Id,
   ContactPerson__c = testcontacten.Id,      
   Account__c = testaccount.id);     
   insert testBidderen;
   
    // Create a test bidder without language or salutation
   Bidder__c testBidderx = new Bidder__c(
   Building_Project__c = testingBuildingProject.Id,
   ContactPerson__c = testcontactx.Id,      
   Account__c = testaccount.id);     
   insert testBidderx;
        
   // create test bidder de 
   Bidder__c testBidderde = new Bidder__c(
   Building_Project__c = testingBuildingProject.Id,
   ContactPerson__c = testcontactde.Id,      
   Account__c = testaccount.id);     
   insert testBidderde;
 
   // create test bidder fr
   Bidder__c testBidderfr = new Bidder__c(
   Building_Project__c = testingBuildingProject.Id,
   ContactPerson__c = testcontactfr.Id,      
   Account__c = testaccount.id);     
   insert testBidderfr;
        
   // create test bidder fr madame
   Bidder__c testBidderfrmadm = new Bidder__c(
   Building_Project__c = testingBuildingProject.Id,
   ContactPerson__c = testcontactfrmadm.Id,      
   Account__c = testaccount.id);     
   insert testBidderfrmadm;
       
  // create an Org wide address     
  // unfortunately you can't set OWD in TestSetup , but we are allowed to access it in the test without 'SeeAllData=True'
/*OrgWideEmailAddress owea = new OrgWideEmailAddress(
            Address = 'orgwide@test.com',
            DisplayName = 'OWD',
            IsAllowAllProfiles = true
        );
        insert owea;
        */ 
    }
 
  @IsTest static void testExecuteSendEmail() {
        // get the test data for class
    	User testUser = [SELECT Id, Email FROM User WHERE Username = 'testuserv@test.com' LIMIT 1];
        BuildingProject__c testBuildingProject = [SELECT Id FROM BuildingProject__c WHERE Name = 'Test Building Project' LIMIT 1];
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        
        // determine flowinput for invocable method
    List<List<String>> flowinput = new List<List<String>>{
            new List<String>{testBuildingProject.Id, testUser.Id}
        };
            
          String currentbuildingproject; 
          String currentuser;
          
        if (flowinput.size()> 0){
        currentbuildingproject = flowinput.get(0).get(0); //in the first table- there should only be one- get me the first position value: get(i).get(n). i: table, n: position
        currentuser = flowinput.get(0).get(1);// the second position value of the first table.         
        System.assertEquals(testBuildingProject.Id, currentbuildingproject, ' not the bp id' );
            
  /* Start the test that will invoke the email method, using the flow input variables that we created from the ids of the BP and User in TestSetup and called 
            in the testExecuteSendEmail method*/
            
 
        System.Test.StartTest();
        EmailClass.sendEmail(currentbuildingproject, currentuser);
      
        Integer invocations = Limits.getEmailInvocations();
        System.Test.stopTest();
       
        //Assert that an email has been sent.  
        System.assertEquals(1, invocations, 'An email has not been sent');
       
       // Query the email results to assert the subject and body.
       // Englisch email
        List<EmailMessage> sentEmails = new List<EmailMessage>(); 
            sentEmails = [SELECT Id, ToAddress, TextBody, Subject  FROM EmailMessage WHERE ToAddress = 'test@v11.com' LIMIT 1];
        // without language or salutation
        List<EmailMessage> sentEmailsx = new List<EmailMessage>(); 
            sentEmailsx = [SELECT Id, ToAddress, TextBody, Subject  FROM EmailMessage WHERE ToAddress = 'testx@v11.com' LIMIT 1];    
        // German email    
        List<EmailMessage> sentEmailsde = new List<EmailMessage>();
            sentEmailsde = [SELECT Id, ToAddress, TextBody, Subject  FROM EmailMessage WHERE ToAddress = 'testde@v11.com' LIMIT 1];
        // French Email    
       List<EmailMessage> sentEmailsfr = new List<EmailMessage>();
            sentEmailsfr = [SELECT Id, ToAddress, TextBody, Subject  FROM EmailMessage WHERE ToAddress = 'testfr@v11.com' LIMIT 1];
        // French Email Madame
       List<EmailMessage> sentEmailsfrm = new List<EmailMessage>();
            sentEmailsfrm = [SELECT Id, ToAddress, TextBody, Subject  FROM EmailMessage WHERE ToAddress = 'testfrm@v11.com' LIMIT 1];
        
       //Messaging.SingleEmailMessage sentEmails = [SELECT Id, ToAddress, Subject  FROM EmailMessage WHERE ToAddress = 'test@v11.com' LIMIT 1];
       EmailMessage email = sentEmails.get(0);
       EmailMessage emailx = sentEmailsx.get(0);     
       EmailMessage emailde = sentEmailsde.get(0);
       EmailMessage emailfr = sentEmailsfr.get(0);
       EmailMessage emailfrm = sentEmailsfrm.get(0);     
       // see if the emails contain the correct information
       // Assert method EN
       System.assert(email.Subject.contains('Test Building Project'), 'Email subject should contain Building Project Name');
       System.assert(email.TextBody.contains('Dear Mr. Eleven'), 'Email body should contain the correct salutation');
       // Assert method without language or saluation
       System.assert(emailx.Subject.contains('Test Building Project'), 'Email subject should contain Building Project Name');
       System.assert(emailx.TextBody.contains('Dear'), 'Email body should contain the correct salutation');
       // Assert method DE
       System.assert(emailde.Subject.contains('Bauvorhaben'), 'Email subject should contain Building Project Name');
       System.assert(emailde.TextBody.contains('Herr'), 'Email body should contain the correct salutation');
       // Assert method FR
       System.assert(emailfr.Subject.contains('construction'), 'Email subject should contain Building Project Name');
       System.assert(emailfr.TextBody.contains('Monsieur'), 'Email body should contain the correct salutation');
       // Assert method FR Madame
       System.assert(emailfrm.Subject.contains('construction'), 'Email subject should contain Building Project Name');
       System.assert(emailfrm.TextBody.contains('Madame'), 'Email body should contain the correct salutation');
    }
          
    
  }
}