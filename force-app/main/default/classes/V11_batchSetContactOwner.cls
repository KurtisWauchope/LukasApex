public class V11_batchSetContactOwner implements Database.Batchable<sObject>{
    List<Id> contactIds;

    public V11_batchSetContactOwner(List<Id> contactIds) {
        this.contactIds = contactIds;
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, Account.OwnerId FROM Contact WHERE id in :contactIds]);
    }
    public void execute(Database.BatchableContext bc,List<Contact> scope)
    {
        List<contact> updateContacts = new List<contact>();

        for(Contact c:scope){
            c.OwnerId = c.Account.OwnerId;
            updateContacts.add(c);
        }
        Update updateContacts;

    }
    public void finish(Database.BatchableContext bc)
    {

    }

}