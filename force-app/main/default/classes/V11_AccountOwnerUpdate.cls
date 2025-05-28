public class V11_AccountOwnerUpdate {

    @AuraEnabled(cacheable=false)
    public static void updateAccountOwner(Id accId){
        V11_AccountOwnerAssigner aoa = new V11_AccountOwnerAssigner([SELECT Id FROM Account WHERE Id =:accId]);
        V11_ContactOwnerAssigner coa = new V11_ContactOwnerAssigner([SELECT Id, Account.OwnerId,AccountId FROM Contact WHERE AccountId =:accId]);
        aoa.assignAccountOwners();
        coa.assignAccountOwners();
    }

}