trigger V11_DeleteContactRelationVR on Contact (before delete) {
    // If a contact is related to a visit report, we need to delete the Visit Report Contact Relation Record
    // Get the list of Contact Ids that are being deleted
    Set<Id> contactIds = new Set<Id>();
    for (Contact contact : Trigger.old) {
        contactIds.add(contact.Id);
    }
    // Query all related Visit Report Contact Relations
    List<Visit_Report_Contact_Relation__c> relatedVisitReportContacts = [SELECT Id FROM Visit_Report_Contact_Relation__c WHERE Contact__c IN :contactIds];
    // Query Visit Reports
    List<VisitReport__c> visitreport = [SELECT Id, Contact__c FROM VisitReport__c WHERE Contact__c IN :contactIds];
    
    // if any visit reports found, set primary contact field to null. The lookup field to contact from vr doesn't allow deletion if it is related to a vr.
    List<VisitReport__c> vrtoupdate = new List <VisitReport__c>();
    for (VisitReport__c vr :visitreport) {
        vr.Contact__c = null;
        vrtoupdate.add(vr);
    }
    if (!visitreport.isEmpty()) {
        update vrtoupdate;
    }
    // If any relations found, delete them
    if (!relatedVisitReportContacts.isEmpty()) {
        delete relatedVisitReportContacts;
    }
}