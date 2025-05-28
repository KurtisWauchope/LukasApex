/**
 * @description       : Handler for Opportunity trigger
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-05-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class V11_OpportunityTriggerHandler implements V11_TriggerHandler {
    
    /**
     * Before insert logic for Opportunity
     */
    public void beforeInsert(List<SObject> newRecords) {
        // No logic required for now
    }
    
    /**
     * After insert logic for Opportunity
     */
    public void afterInsert(List<SObject> newRecords) {
        // No logic required for now
    }
    
    /**
     * Before update logic for Opportunity
     * - Store previous stage when StageName changes
     */
    public void beforeUpdate(List<SObject> newRecords, Map<Id, SObject> oldRecordsMap) {
        List<Opportunity> opportunities = (List<Opportunity>) newRecords;
        Map<Id, Opportunity> oldOpportunitiesMap = (Map<Id, Opportunity>) oldRecordsMap;
        
        System.debug('💡 BEFORE UPDATE: Setting Previous_Stage__c field on Opportunities');
        for (Opportunity opp : opportunities) {
            Opportunity oldOpp = oldOpportunitiesMap.get(opp.Id);
            
            // Store previous stage when it changes
            if (opp.StageName != oldOpp.StageName) {
                System.debug('📝 Opportunity ' + opp.Id + ' Stage changing from [' + oldOpp.StageName + '] to [' + opp.StageName + ']');
                opp.Previous_Stage__c = oldOpp.StageName;
                System.debug('👉 Previous Stage für Opportunity gespeichert: ' + opp.Id + ' - Status: ' + oldOpp.StageName);
            }
        }
    }
    
    /**
     * After update logic for Opportunity
     * - Handle Closed Lost opportunities: mark related Quotes as Rejected
     * - Handle Closed Won opportunities: update related BuildingProject and mark other Opportunities as Closed Lost
     */
    public void afterUpdate(List<SObject> newRecords, Map<Id, SObject> oldRecordsMap) {
        // Skip if reset is in progress
        if (V11_BuildingProjectResetService.isResetInProgress()) {
            System.debug('⚠️ Reset in progress - skipping Opportunity trigger');
            return;
        }
        
        List<Opportunity> opportunities = (List<Opportunity>) newRecords;
        Map<Id, Opportunity> oldOpportunitiesMap = (Map<Id, Opportunity>) oldRecordsMap;
        
        Set<Id> closedLostOppIds = new Set<Id>();
        Map<Id, Opportunity> closedWonOppByBPId = new Map<Id, Opportunity>();
        
        // First pass: identify Closed Lost and Closed Won opportunities
        for (Opportunity opp : opportunities) {
            Opportunity oldOpp = oldOpportunitiesMap.get(opp.Id);

            // Closed Lost handling
            if (opp.StageName == 'Closed Lost' && oldOpp.StageName != 'Closed Lost') {
                System.debug('🔴 Opportunity ' + opp.Id + ' marked as Closed Lost');
                closedLostOppIds.add(opp.Id);
            }

            // Closed Won handling
            if (opp.StageName == 'Closed Won' && oldOpp.StageName != 'Closed Won') {
                System.debug('🟢 Opportunity ' + opp.Id + ' marked as Closed Won');
                if (opp.BuildingProject__c != null) {
                    System.debug('🏢 Opportunity has Building Project: ' + opp.BuildingProject__c);
                    closedWonOppByBPId.put(opp.BuildingProject__c, opp);
                }
            }
        }
        
        // Handle Closed Lost: Set related quotes to Rejected
        handleClosedLostOpportunities(closedLostOppIds);
        
        // Handle Closed Won: Update BuildingProject and other Opportunities
        handleClosedWonOpportunities(closedWonOppByBPId);
    }
    
    /**
     * Handle Closed Lost opportunities by rejecting related quotes
     */
    private void handleClosedLostOpportunities(Set<Id> closedLostOppIds) {
        if (closedLostOppIds.isEmpty()) {
            return;
        }
        
        // Get quotes to reject for each closed lost opportunity
        List<Quote> quotesToReject = new List<Quote>();
        
        for (Id oppId : closedLostOppIds) {
            List<Quote> quoteList = [
                SELECT Id, Status FROM Quote 
                WHERE ParentOpportunity__c = :oppId AND Status != 'Rejected'
            ];
            
            System.debug('📊 Found ' + quoteList.size() + ' quotes to reject for Closed Lost opportunity');
            
            for (Quote quote : quoteList) {
                quote.Status = 'Rejected';
                quotesToReject.add(quote);
            }
        }
        
        if (!quotesToReject.isEmpty()) {
            System.debug('✏️ Updating ' + quotesToReject.size() + ' quotes to Rejected');
            update quotesToReject;
        }
    }
    
    /**
     * Handle Closed Won opportunities by updating BuildingProject and related opportunities
     */
    private void handleClosedWonOpportunities(Map<Id, Opportunity> closedWonOppByBPId) {
        if (closedWonOppByBPId.isEmpty()) {
            return;
        }
        
        System.debug('🏗️ Processing Building Projects for ' + closedWonOppByBPId.size() + ' Closed Won opportunities');
        
        // Step 1: Update Building Projects to Execution stage
        List<BuildingProject__c> buildingProjectsToUpdate = [
            SELECT Id, Stage__c, Previous_Stage__c, Allocationfabricator__c, Probability__c
            FROM BuildingProject__c
            WHERE Id IN :closedWonOppByBPId.keySet()
            AND Stage__c != 'Execution'
        ];
        
        System.debug('📊 Found ' + buildingProjectsToUpdate.size() + ' Building Projects to update');

        for (BuildingProject__c bp : buildingProjectsToUpdate) {
            Opportunity opp = closedWonOppByBPId.get(bp.Id);

            // Store previous stage
            System.debug('📝 Building Project ' + bp.Id + ' Stage changing from [' + bp.Stage__c + '] to [Execution]');
            bp.Previous_Stage__c = bp.Stage__c;
            
            // Set winning fabricator and update stage
            bp.Allocationfabricator__c = opp.AccountId;
            bp.Stage__c = 'Execution';
            bp.Probability__c = '100';
            System.debug('✅ BuildingProject ' + bp.Id + ' updated: Stage=Execution, Allocationfabricator=' + opp.AccountId);
        }

        if (!buildingProjectsToUpdate.isEmpty()) {
            System.debug('✏️ Updating ' + buildingProjectsToUpdate.size() + ' Building Projects');
            update buildingProjectsToUpdate;
        }

        // Step 2: Mark other related opportunities as Closed Lost
        List<Opportunity> relatedOppsToUpdate = [
            SELECT Id, StageName, Previous_Stage__c
            FROM Opportunity
            WHERE BuildingProject__c IN :closedWonOppByBPId.keySet()
            AND Id NOT IN :closedWonOppByBPId.values()
            AND StageName != 'Closed Won'
            AND StageName != 'Closed Lost'
        ];
        
        System.debug('📊 Found ' + relatedOppsToUpdate.size() + ' related Opportunities to mark as Closed Lost');

        for (Opportunity opp : relatedOppsToUpdate) {
            // Store previous stage
            System.debug('📝 Related Opportunity ' + opp.Id + ' Stage changing from [' + opp.StageName + '] to [Closed Lost]');
            opp.Previous_Stage__c = opp.StageName;
            opp.StageName = 'Closed Lost';
            opp.Loss_Reason__c = 'Project awarded to other company';
        }

        if (!relatedOppsToUpdate.isEmpty()) {
            System.debug('✏️ Updating ' + relatedOppsToUpdate.size() + ' related Opportunities to Closed Lost');
            update relatedOppsToUpdate;
        }
    }
    
    public void beforeDelete(List<SObject> oldRecords) {
        // Not implemented
    }
    
    public void afterDelete(List<SObject> oldRecords) {
        // Not implemented
    }
}