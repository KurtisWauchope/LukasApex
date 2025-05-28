/**
 * @Email Class method for sending notifications to the bidder list. Bypasses the Salesforce Flow limit of 10 Apex invocations per transaction. This class should be able to send ~50k emails
 * @Date 13 August 2024- Kurtis Wauchope
 */

public class EmailClass  {
  // can only pass one parameter from flow into apex. Use the the same parameter twice.
  // get(0) the first variable that gets passed from the flow; get(1) the 2nd variable to get passed from the flow. They get passed into the same parameter
@InvocableMethod
    public static void executesendmail(List<List<String>> flowinput) {
                    
          String currentbuildingproject; 
          String currentuser;
          
        if (flowinput.size()> 0){
        currentbuildingproject = flowinput.get(0).get(0); //in the first table- there should only be one- get me the first position value: get(i).get(n). i: table, n: position
        currentuser = flowinput.get(0).get(1);// the second position value of the first table.         
        sendEmail(currentbuildingproject, currentuser);
        }
           }
    // using the get method for user name and email based on the user id. It is not a 'void' method because we want to return a value for later.
    public static String getusername(String userid) {
 List<User> username = new List<User>(); 
       username = [Select id, Name from User where User.id = :userid LIMIT 1]; // The ':' indicates that we are comparing a variable; select only the columns where the User ID is 'userid'.
       User us =  username.get(0);
       return us.Name;
    //  'userid' at this stage is merely a placeholder. We expect to be receiving a userid in this variable. This happens  
    }
    public static String getuseremail(String userid) {
 List<User> useremail = new List<User>(); 
       useremail = [Select id, Email from User where User.id = :userid LIMIT 1];
       User us =  useremail.get(0);
       return us.Email;
       
    }
    
    // we then pass the 2 String variables 'currentbuildingproject' and 'currentuser' into the cbp and cus variable in to sendEmail method
   
   
    public static void sendEmail(String cbp, String cuserid ) {
        // be careful with this query as you can have more than 50 000 Contacts where Email!=null 
        List<Contact> contacts =[Select Id From Contact where Email!=null];
        //List<User> lastsentence = new List<User>(); 
        //lastsentence = [Select id, Name from User where User.id =:cus LIMIT 1];
        List<Bidder__c> bidders = new List<Bidder__c>();
        bidders = [Select id, Account__r.OwnerId, Account__r.owner.name, Account__r.owner.Email, Building_Project__r.Name, ContactPerson__r.id, 
                   ContactPerson__r.Salutation, ContactPerson__r.name , ContactPerson__r.Email, ContactPerson__r.Language__c  from 
                   Bidder__c where  recordtype.developerName = 'Raico_bidder' AND Building_Project__c = :cbp AND ContactPerson__r.id IN : contacts];
        //List<BuildingProject__c> buildingProjectslist = new List <BuildingProject__c>();
        //buildingProjectslist = [Select id, Name  from BuildingProject__c where Send_Email__c = true and BidderListSent__c = false ];
        OrgWideEmailAddress owea = new OrgWideEmailAddress();
        owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress Where DisplayName='OWD' LIMIT 1];
        String sendername = getusername(cuserid);// get the username using the getusername method from Line 21 when the User ID is that of 'cuserid'.
        // The 'cuserid' will receive the id of the user from 'currentuser' as defined in Line 18. The value is passed on from the Flow.
        String senderemail = getuseremail(cuserid);
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        
       
        
        for (Bidder__c bd : bidders)  {
            
            //dynamically define salutation, subject and body based on language
            String subject;
            String body;
            String salutation = (bd.ContactPerson__r.Salutation != null ? bd.ContactPerson__r.Salutation : '');  
            String language = (bd.ContactPerson__r.Language__c != null ? bd.ContactPerson__r.Language__c : '');
            String bpname = bd.Building_Project__r.Name;
            String salutationtext;
            String accountowner = bd.Account__r.owner.Name;
            
             
        
            //determine the salutation and subject based on the bidders preferred language
            switch on language+Salutation {
                when 'enMr.','enMs.', 'enMrs.', 'enDr.', 'enProf.', 'en'  {
                    salutationtext = 'Dear ' + (bd.ContactPerson__r.Salutation != null ? bd.ContactPerson__r.Salutation + ' ' : '') + bd.ContactPerson__r.name;
                    subject = 'Bidder List for the Building Project' + bpname;
                    body = salutationtext + ',\r\nYou will receive the tender documents in the next few days or be made aware of the publication.\r\n'+
                        'Should you require assistance in preparing your bid, please do not hesitate to contact us.\r\n'+ 
                        'Best Regards\n'+ sendername ;
                }
            when 'deMr.' {
                    salutationtext = 'Sehr geehrter Herr ' +  bd.ContactPerson__r.name;
                    subject = 'Bieterliste für das Bauvorhaben ' + bpname;
                    body = '\r\n' + salutationtext + ',\r\n\nSie werden in den nächsten Tagen die Ausschreibungsunterlagen erhalten bzw. auf die Veröffentlichung aufmerksam gemacht werden.\r\n'+
                        '\nSollten Sie Unterstützung bei der Angebotserstellung benötigen, melden Sie sich gerne bei uns.\r\n'+ 
                        '\nSchöne Grüße\n'+ sendername +  (accountowner != sendername ? ' und '+ accountowner : '');
            }
            when 'deMrs.','deMs.' {
                   salutationtext = 'Sehr geehrte Frau ' +  bd.ContactPerson__r.name;
                   subject = 'Bieterliste für das Bauvorhaben ' + bpname;
                   body = '\r\n'+ salutationtext + ',\r\n\nSie werden in den nächsten Tagen die Ausschreibungsunterlagen erhalten bzw. auf die Veröffentlichung aufmerksam gemacht werden.\r\n'+
                        '\nSollten Sie Unterstützung bei der Angebotserstellung benötigen, melden Sie sich gerne bei uns.\r\n'+ 
                        '\nSchöne Grüße\n'+ sendername +  (accountowner != sendername ? ' und '+ accountowner : '');
            }
                when 'de', 'deDr.', 'deProf.'{
                   salutationtext = 'Hallo ' + (bd.ContactPerson__r.Salutation != null ? bd.ContactPerson__r.Salutation + ' ' : '') + bd.ContactPerson__r.name;
                   subject = 'Bieterliste für das Bauvorhaben ' + bpname;
                   body = salutationtext + ',\r\n\nSie werden in den nächsten Tagen die Ausschreibungsunterlagen erhalten bzw. auf die Veröffentlichung aufmerksam gemacht werden.\r\n'+
                        '\nSollten Sie Unterstützung bei der Angebotserstellung benötigen, melden Sie sich gerne bei uns.\r\n'+ 
                        '\nSchöne Grüße\n' + sendername +  (accountowner != sendername ? ' und '+ accountowner : '');
                }
                
                when 'frMr.' {
                   salutationtext = 'Cher partenaire Monsieur '  + bd.ContactPerson__r.name;
                   subject = 'Liste des soumissionnaires pour le projet de construction ' + bpname;
                   body = salutationtext + ',\r\nVous recevrez dans les prochains jours les documents d’appel d’offres ou serez informé de leur publication.\r\n'+
                        'Si vous avez besoin d’aide pour l’élaboration de votre offre, n’hésitez pas à nous contacter.\r\n'+ 
                        'Meilleures salutations\n' + sendername ;
                }
                 when 'frMadame','frMrs.','frMs.' {
                   salutationtext = 'Chere partenaire Madame ' + bd.ContactPerson__r.name;
                   subject = 'Liste des soumissionnaires pour le projet de construction ' + bpname;
                   body = salutationtext + ',\r\nVous recevrez dans les prochains jours les documents d’appel d’offres ou serez informée de leur publication.\r\n'+
                        'Si vous avez besoin d’aide pour l’élaboration de votre offre, n’hésitez pas à nous contacter.\r\n'+ 
                        'Meilleures salutations\n'+ sendername ;
                 }
                 when 'fr', 'frDr.', 'frProf.' {
                   salutationtext = 'Cher(e) partenaire ' ;
                   subject = 'Liste des soumissionnaires pour le projet de construction ' + bpname;
                   body = salutationtext + ',\r\nVous recevrez dans les prochains jours les documents d’appel d’offres ou serez informé(e)s de leur publication.\r\n'+
                        'Si vous avez besoin d’aide pour l’élaboration de votre offre, n’hésitez pas à nous contacter.\r\n'+ 
                        'Meilleures salutations\n'+ sendername ;
                 }
                
                when else {salutationtext = 'Dear ' + (bd.ContactPerson__r.Salutation != null ? bd.ContactPerson__r.Salutation + ' ' : '') + bd.ContactPerson__r.name;
                    subject = 'Bidder List for the Building Project' + bpname;
                    body = salutationtext + ',\r\nYou will receive the tender documents in the next few days or be made aware of the publication.\r\n'+
                        'Should you require assistance in preparing your bid, please do not hesitate to contact us.\r\n'+ 
                        'Best Regards\n'+ sendername ;}
            }
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            // set properties on singular email
            email.setToAddresses( new List<String>{ bd.ContactPerson__r.Email } );
            email.setWhatId(bd.Id); 
            email.setTargetObjectId(bd.ContactPerson__c);
            email.setReplyTo(senderemail);                       
            email.setOrgWideEmailAddressId(owea.id);
            email.setbccAddresses( new List<String>{ bd.Account__r.owner.Email } );
            email.setSubject(subject);
            email.setPlainTextBody(body);
            email.setSaveAsActivity(true);     
        
            
            emails.add( email ); // here we add the email to the list
        }
        Messaging.sendEmail( emails ); // here we send all emails 
     
        
  
     
    }
}