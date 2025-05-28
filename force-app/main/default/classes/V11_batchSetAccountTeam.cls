public class V11_batchSetAccountTeam implements Database.Batchable<sObject>,Database.Stateful{

    List<Id> accountIds;
    List<AccountTeamMember> accTeams;
    List<Role_Assignment__c> roleAssignment;
    V11_PostalCodeAssignment pcaList;

    public V11_batchSetAccountTeam(List<Id> accountIds) 
    {
        this.accountIds = accountIds;
        pcaList = new V11_PostalCodeAssignment();
    }

    public Database.QueryLocator start(Database.BatchableContext bc){

        roleAssignment = [select PrimaryRole__c, Additional_Roles__c, Type__c,Country__c from Role_Assignment__c where Objecttype__c ='Account'];

        return Database.getQueryLocator([SELECT Id, RecordType.Name,BillingPostalCode,BillingCountryCode,OwnerId FROM Account WHERE id in :accountIds AND BillingPostalCode != '']);
    }

    public void execute(Database.BatchableContext bc,List<Account> scope)
    {
        List <Account> updateAccounts = new List<Account>();
        List <AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();
        List<AccountTeamMember> accTeamsToDelete = new List<AccountTeamMember>();

        for(Account acc:scope)
        {
            

            
           /*integer postalCode;
           String  postalCode;
            
            if(acc.BillingPostalCode.isNumeric()){
                postalCode = Integer.valueOf(acc.BillingPostalCode);
            }else{
                continue;
            } 
*/           
            List<Postal_Code_Range__c> postalCodeAssignment = pcaList.getUserAndRole(acc.BillingPostalCode, acc.BillingCountryCode);
            
            system.debug(postalCodeAssignment.size());
            

            for(Role_Assignment__c ra:roleAssignment)
            {

                if(acc.RecordType.Name != ra.Type__c || acc.BillingCountryCode != ra.Country__c){
                    continue;
                }

                for(Postal_Code_Range__c pca:postalCodeAssignment)
                {   
                    
                    if(pca.PostalCodeAssignment__r.Role__c == ra.PrimaryRole__c)
                    {

                        acc.OwnerId = pca.PostalCodeAssignment__r.User__c;
                        updateAccounts.add(acc);
                        AccountTeamMember atm = new AccountTeamMember();
                        atm.AccountId = acc.Id;
                        atm.UserId = pca.PostalCodeAssignment__r.User__c;
                        atm.TeamMemberRole = pca.PostalCodeAssignment__r.Role__c;
                        atm.AccountAccessLevel = 'Edit';
                        atm.CaseAccessLevel = 'Edit';
                        atm.OpportunityAccessLevel = 'Edit';
                        accountTeamMembers.add(atm);
                        
                        
                    }else if(ra.Additional_Roles__c!= null)
                    {
                        List<String> roles =  ra.Additional_Roles__c.split(';');
                        Set<String> rolesSet = new Set<String>();
                        rolesSet.addAll(roles);

                        if(rolesSet.contains(pca.PostalCodeAssignment__r.Role__c))
                        {
                            AccountTeamMember atm = new AccountTeamMember();
                            atm.AccountId = acc.Id;
                            atm.UserId = pca.PostalCodeAssignment__r.User__c;
                            atm.TeamMemberRole = pca.PostalCodeAssignment__r.Role__c;
                            atm.AccountAccessLevel = 'Edit';
                            atm.CaseAccessLevel = 'Edit';
                            atm.OpportunityAccessLevel = 'Edit';                    
                            accountTeamMembers.add(atm);
                        }
    
                    }
                }
            }    

        }   
        Set<Account> accSet = new Set<Account>();
        accSet.addAll(updateAccounts);
        updateAccounts.clear();
        updateAccounts.addAll(accSet);
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        Database.update(updateAccounts,dml);
        try{
            insert accountTeamMembers;
        }catch(Exception e) {}
        

    }
    public void finish(Database.BatchableContext bc)
    {

    }

}