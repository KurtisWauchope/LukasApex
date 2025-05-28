public with sharing class V11_ContactOwnerAssigner {
    List<Contact> updateContacts;

    public V11_ContactOwnerAssigner(List<Contact> updateContacts) {
        this.updateContacts = updateContacts;
    }
    public void assignAccountOwners(){
        List<Id> contactIds = new List<Id>(new Map<Id,Contact>(updateContacts).keySet());
        V11_PostalCodeAssignment.setOwnerContact(contactIds); 
    }


}