public with sharing class V11_AccountContactRelationController {
    @AuraEnabled(cacheable=true)
    public static List<AccountContactRelation> getRelatedContacts(Id accountId, String statusFilter) {
        if (accountId == null) {
            System.debug(' No AccountId provided.');
            return new List<AccountContactRelation>();
        }

        System.debug(' Fetching Related Contacts for Account ID: ' + accountId);
        System.debug(' Status Filter: ' + statusFilter);

        if (!Schema.sObjectType.AccountContactRelation.isAccessible() || !Schema.sObjectType.Contact.isAccessible()) {
            System.debug(' User does not have access to AccountContactRelation or Contact object.');
            throw new SecurityException('You do not have permission to access AccountContactRelation or Contact.');
        }

        List<AccountContactRelation> relatedContacts;

        try {
            String query = 'SELECT Id, ContactId, Contact.Name, Contact.Email, Contact.Phone, IsActive ' +
                           'FROM AccountContactRelation ' +
                           'WHERE AccountId = :accountId ';

            if (statusFilter == 'Active') {
                query += 'AND IsActive = true ';
            } else if (statusFilter == 'Inactive') {
                query += 'AND IsActive = false ';
            }

            query += 'WITH SECURITY_ENFORCED';

            relatedContacts = Database.query(query);
            System.debug(' Retrieved ' + relatedContacts.size() + ' contacts.');

        } catch (Exception e) {
            System.debug(' Error fetching contacts: ' + e.getMessage());
            return new List<AccountContactRelation>();
        }

        return relatedContacts;
    }
}