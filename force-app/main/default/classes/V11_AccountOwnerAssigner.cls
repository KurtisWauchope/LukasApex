public class V11_AccountOwnerAssigner {
    List<Account> newAccounts;

    public V11_AccountOwnerAssigner(List<Account> newAccounts) {
        this.newAccounts = newAccounts;
    }

    public void assignAccountOwners(){
        List<Id> accountIds = new List<Id>(new Map<Id,Account>(newAccounts).keySet());
        V11_PostalCodeAssignment.setOwnerAndAccountTeam(accountIds); 
    }
}