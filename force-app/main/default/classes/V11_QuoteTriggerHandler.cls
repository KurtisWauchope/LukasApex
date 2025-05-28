/**
 * @description       : Handler for Quote trigger
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-05-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class V11_QuoteTriggerHandler implements V11_TriggerHandler {
    
    /**
     * Before insert logic for Quote
     */
    public void beforeInsert(List<SObject> newRecords) {
        // No logic required for now
    }
    
    /**
     * After insert logic for Quote
     */
    public void afterInsert(List<SObject> newRecords) {
        // No logic required for now
    }
    
    /**
     * Before update logic for Quote
     * - Store previous stage when Status changes
     */
    public void beforeUpdate(List<SObject> newRecords, Map<Id, SObject> oldRecordsMap) {
        List<Quote> quotes = (List<Quote>) newRecords;
        Map<Id, Quote> oldQuotesMap = (Map<Id, Quote>) oldRecordsMap;
        
        System.debug('💡 BEFORE UPDATE: Setting Previous_Stage__c field on Quotes');
        for (Quote q : quotes) {
            Quote oldQ = oldQuotesMap.get(q.Id);
            
            // Store previous status when it changes
            if (q.Status != oldQ.Status) {
                System.debug('📝 Quote ' + q.Id + ' Status changing from [' + oldQ.Status + '] to [' + q.Status + ']');
                q.Previous_Stage__c = oldQ.Status;
                System.debug('👉 Previous Stage für Quote gespeichert: ' + q.Id + ' - Status: ' + oldQ.Status);
            }
        }
    }
    
    /**
     * After update logic for Quote
     * - Handle Accepted quotes: mark parent Opportunity as Closed Won
     * - Reject other quotes for the same Opportunity when one is Accepted
     */
    public void afterUpdate(List<SObject> newRecords, Map<Id, SObject> oldRecordsMap) {
        // Skip if reset is in progress
        if (V11_BuildingProjectResetService.isResetInProgress()) {
            System.debug('⚠️ Reset in progress - skipping Quote trigger');
            return;
        }
        
        List<Quote> quotes = (List<Quote>) newRecords;
        Map<Id, Quote> oldQuotesMap = (Map<Id, Quote>) oldRecordsMap;
        
        Map<Id, Opportunity> oppsToUpdate = new Map<Id, Opportunity>();
        Set<Id> oppsWithAcceptedQuotes = new Set<Id>();
        Set<Id> acceptedQuoteIds = new Set<Id>();
        
        // First pass: identify quotes that were just accepted
        for (Quote quote : quotes) {
            Quote oldQuote = oldQuotesMap.get(quote.Id);
            
            if (quote.Status == 'Accepted' && oldQuote.Status != 'Accepted' && 
                quote.ParentOpportunity__c != null) {
                
                System.debug('🎯 Quote ' + quote.Id + ' accepted - marking Opportunity ' + quote.ParentOpportunity__c + ' as Closed Won');
                oppsToUpdate.put(quote.ParentOpportunity__c, new Opportunity(
                    Id = quote.ParentOpportunity__c,
                    StageName = 'Closed Won'
                ));
                
                oppsWithAcceptedQuotes.add(quote.ParentOpportunity__c);
                acceptedQuoteIds.add(quote.Id);
            }
        }
        
        // Handle related quotes for these opportunities
        handleRelatedQuotes(oppsWithAcceptedQuotes, acceptedQuoteIds);
        
        // Update opportunities to Closed Won
        if (!oppsToUpdate.isEmpty()) {
            System.debug('✏️ Updating ' + oppsToUpdate.size() + ' opportunities to Closed Won');
            update oppsToUpdate.values();
        }
    }
    
    /**
     * Mark other quotes as Rejected when one is Accepted
     */
    private void handleRelatedQuotes(Set<Id> oppsWithAcceptedQuotes, Set<Id> acceptedQuoteIds) {
        if (oppsWithAcceptedQuotes.isEmpty()) {
            return;
        }
        
        System.debug('🔄 Finding other quotes to reject for ' + oppsWithAcceptedQuotes.size() + ' opportunities');
        
        // Find other quotes to reject (excluding the ones that were just accepted)
        List<Quote> otherQuotesToReject = [
            SELECT Id, Status, ParentOpportunity__c
            FROM Quote 
            WHERE ParentOpportunity__c IN :oppsWithAcceptedQuotes
            AND Status != 'Accepted' 
            AND Status != 'Rejected'
            AND Id NOT IN :acceptedQuoteIds
        ];
        
        System.debug('📊 Found ' + otherQuotesToReject.size() + ' quotes to reject');
        
        // Mark them as Rejected
        for (Quote q : otherQuotesToReject) {
            // Speichere vorherigen Status (muss wiederholt werden, da wir nicht im before update sind)
            q.Previous_Stage__c = q.Status;
            q.Status = 'Rejected';
            System.debug('📝 Quote ' + q.Id + ' rejected because another quote was accepted for Opportunity ' + q.ParentOpportunity__c);
        }
        
        if (!otherQuotesToReject.isEmpty()) {
            System.debug('✏️ Updating ' + otherQuotesToReject.size() + ' quotes to Rejected');
            update otherQuotesToReject;
        }
    }
    
    public void beforeDelete(List<SObject> oldRecords) {
        // Not implemented
    }
    
    public void afterDelete(List<SObject> oldRecords) {
        // Not implemented
    }
}