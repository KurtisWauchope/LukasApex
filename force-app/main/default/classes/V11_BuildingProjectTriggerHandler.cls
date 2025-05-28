/**
 * @description       : Handler for BuildingProject trigger
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-05-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class V11_BuildingProjectTriggerHandler implements V11_TriggerHandler {
    
    /**
     * Before insert logic for BuildingProject
     * - Set Search_Address__c
     * - Assign ComarchBuildingProjectNumber__c if needed
     */
    public void beforeInsert(List<SObject> newRecords) {
        List<BuildingProject__c> newBuildingProjects = (List<BuildingProject__c>) newRecords;
        
        if (!Test.isRunningTest()) {
            for (BuildingProject__c bp : newBuildingProjects) {
                // Set search address
                bp.Search_Address__c = bp.Name + ', ' + bp.ProjectAddress__PostalCode__s + ' ' + bp.ProjectAddress__City__s;

                // Assign or validate Comarch number
                if (String.isBlank(bp.ComarchBuildingProjectNumber__c)) {
                    bp.ComarchBuildingProjectNumber__c = V11_ComarchNumberManager.getNumber('Building Project');
                } else {
                    // Check if number is already used
                    List<BuildingProject__c> existing = [
                        SELECT Id FROM BuildingProject__c 
                        WHERE ComarchBuildingProjectNumber__c = :bp.ComarchBuildingProjectNumber__c
                    ];
                    if (!existing.isEmpty()) {
                        bp.ComarchBuildingProjectNumber__c = V11_ComarchNumberManager.getNumber('Building Project');
                    }
                }
            }
        }
    }
    
    /**
     * After insert logic for BuildingProject
     * - Send to external systems (enaio)
     * - Create outbound call
     */
    public void afterInsert(List<SObject> newRecords) {
        List<BuildingProject__c> newBuildingProjects = (List<BuildingProject__c>) newRecords;
        
        if (!Test.isRunningTest()) {
            for (BuildingProject__c bp : newBuildingProjects) {
                // Send to enaio if integration is active
                if (V11_helperClass.getIntegrationStatus('enaio')) {
                    System.debug('🔄 Sending Building Project ' + bp.Id + ' to enaio');
                    V11_sendObjectToEnaio queue = new V11_sendObjectToEnaio(bp);
                    System.enqueueJob(queue);
                }
                
                // Create outbound call
                System.debug('🔄 Creating outbound call for Building Project ' + bp.Id);
                V11_CreateOutboundCall.insertBuildingProject(bp, 'create');
            }
        }
    }
    
    /**
     * Before update logic for BuildingProject
     * - Store previous stage
     * - Update search address
     * - Handle automatic stage transitions
     * - Validate stage transitions (Execution requires Fabricator)
     * - Handle closed projects
     */
    public void beforeUpdate(List<SObject> newRecords, Map<Id, SObject> oldRecordsMap) {
        List<BuildingProject__c> updatedBuildingProjects = (List<BuildingProject__c>) newRecords;
        Map<Id, BuildingProject__c> oldBuildingProjectsMap = (Map<Id, BuildingProject__c>) oldRecordsMap;
        
        for (BuildingProject__c bp : updatedBuildingProjects) {
            BuildingProject__c oldBP = oldBuildingProjectsMap.get(bp.Id);

            // Store previous stage when changing
            if (bp.Stage__c != oldBP.Stage__c) {
                System.debug('📝 Building Project ' + bp.Id + ' Stage changing from [' + oldBP.Stage__c + '] to [' + bp.Stage__c + ']');
                bp.Previous_Stage__c = oldBP.Stage__c;
            }

            // Update search address
            bp.Search_Address__c = bp.Name + ', ' + bp.ProjectAddress__PostalCode__s + ' ' + bp.ProjectAddress__City__s;

            // Automatic stage transition to "Tender & Quote"
            if (bp.Service_specifications_sent__c == true &&
                (bp.Stage__c == 'Research' || bp.Stage__c == 'Consulting/ Planning')) {
                System.debug('🔄 Auto-changing Building Project ' + bp.Id + ' Stage to [Tender & Quote]');
                bp.Stage__c = 'Tender & Quote';
            }

            // Handle transition to Execution
            handleExecutionTransition(bp, oldBP);

            // Handle project closure
            handleProjectClosure(bp, oldBP);
        }
    }
    
    /**
     * After update logic for BuildingProject
     * - Update external systems
     * - Update related Opportunities
     */
    public void afterUpdate(List<SObject> newRecords, Map<Id, SObject> oldRecordsMap) {
        // Skip if reset is in progress
        if (V11_BuildingProjectResetService.isResetInProgress()) {
            System.debug('⚠️ Reset in progress - skipping BuildingProject afterUpdate processing');
            return;
        }
        
        List<BuildingProject__c> updatedBuildingProjects = (List<BuildingProject__c>) newRecords;
        Map<Id, BuildingProject__c> oldBuildingProjectsMap = (Map<Id, BuildingProject__c>) oldRecordsMap;
        
        for (BuildingProject__c bp : updatedBuildingProjects) {
            BuildingProject__c oldBP = oldBuildingProjectsMap.get(bp.Id);

            // External system updates
            handleExternalSystemUpdates(bp, oldBP);

            // Update related Opportunities for projects in Execution
            if ((bp.Stage__c == 'Execution' || (bp.Probability__c == '100' && bp.Stage__c != 'Closed')) &&
                bp.Allocationfabricator__c != null) {
                updateRelatedOpportunities(bp);
            }
        }
    }
    
    /**
     * Handle project transition to Execution stage
     */
    private void handleExecutionTransition(BuildingProject__c bp, BuildingProject__c oldBP) {
        if (bp.Stage__c == 'Execution' || (bp.Probability__c == '100' && bp.Stage__c != 'Closed')) {
            System.debug('🔍 Processing Execution transition for Building Project ' + bp.Id);
            
            // Allow stage change in reset scenario
            if (bp.Allocationfabricator__c == null) {
                if (oldBP.Stage__c == 'Execution' && bp.Stage__c != 'Execution' && bp.Previous_Stage__c == null) {
                    System.debug('⏪ Reset operation detected - allowing Stage change without Fabricator');
                    return; // Allow reset operation
                }

                // Block execution stage without fabricator
                System.debug('⚠️ Blocking Execution stage without Fabricator');
                bp.Stage__c.addError('You cannot enter this Stage without selecting a fabricator.');
                bp.Stage__c = oldBP.Stage__c;
                bp.Probability__c = oldBP.Probability__c;
            } else {
                // Properly set up Execution stage with Fabricator
                System.debug('✅ Setting Building Project to Execution with Fabricator: ' + bp.Allocationfabricator__c);
                bp.Probability__c = '100';
                bp.Stage__c = 'Execution';

                // Set default systemhouse if needed
                if (bp.Allocationsystemhouse__c == null) {
                    setDefaultSystemhouse(bp);
                }
            }
        }
    }
    
    /**
     * Set default systemhouse (RAICO)
     */
    private void setDefaultSystemhouse(BuildingProject__c bp) {
        try {
            Account acc = [
                SELECT Id FROM Account 
                WHERE Name LIKE '%RAICO%' AND Type = 'Competitor' 
                LIMIT 1
            ];
            bp.Allocationsystemhouse__c = acc.Id;
            System.debug('🏢 Setting default Systemhouse to RAICO: ' + acc.Id);
        } catch (Exception e) {
            System.debug('⚠️ Could not set default Systemhouse: ' + e.getMessage());
        }
    }
    
    /**
     * Handle project closure with Lost reason
     */
    private void handleProjectClosure(BuildingProject__c bp, BuildingProject__c oldBP) {
        if (bp.Stage__c == 'Closed' && bp.Closing_Reason__c == 'Lost') {
            System.debug('🔴 Building Project ' + bp.Id + ' marked as Closed/Lost');
            bp.Probability__c = '0';
            
            // Mark related Opportunities as Closed Lost (done in afterUpdate)
        }
    }
    
    /**
     * Handle external system updates
     */
    private void handleExternalSystemUpdates(BuildingProject__c bp, BuildingProject__c oldBP) {
        if (!Test.isRunningTest()) {
            // Update Comarch
            if (oldBP.Status_Update_Id__c == bp.Status_Update_Id__c && bp.InitialComarchSync__c) {
                System.debug('🔄 Creating outbound call update for Building Project ' + bp.Id);
                V11_CreateOutboundCall.insertBuildingProject(bp, 'update');
            }

            // Update enaio
            if ((oldBP.Name != bp.Name || oldBP.OwnerId != bp.OwnerId) 
                && V11_helperClass.getIntegrationStatus('enaio')) {
                System.debug('🔄 Sending updated Building Project to enaio due to Name/Owner change');
                V11_sendObjectToEnaio queue = new V11_sendObjectToEnaio(bp);
                System.enqueueJob(queue);
            }
        }
    }
    
    /**
     * Update related Opportunities when project enters Execution
     */
    private void updateRelatedOpportunities(BuildingProject__c bp) {
        System.debug('🔄 Updating Opportunities for Building Project in Execution stage');
        
        // Query all related opportunities
        List<Opportunity> oppList = [
            SELECT Id, AccountId, StageName, Previous_Stage__c
            FROM Opportunity 
            WHERE BuildingProject__c = :bp.Id
        ];
        
        System.debug('📊 Found ' + oppList.size() + ' Opportunities to process');

        for (Opportunity opp : oppList) {
            // Store previous stage
            opp.Previous_Stage__c = opp.StageName;
            
            // Set stage based on whether this opportunity matches the selected fabricator
            if (opp.AccountId == bp.Allocationfabricator__c && opp.StageName != 'Closed Won') {
                System.debug('🟢 Setting Opportunity ' + opp.Id + ' to Closed Won (matches Fabricator)');
                opp.StageName = 'Closed Won';
            } else if (opp.AccountId != bp.Allocationfabricator__c) {
                System.debug('🔴 Setting Opportunity ' + opp.Id + ' to Closed Lost (different Fabricator)');
                opp.StageName = 'Closed Lost';
                opp.Loss_Reason__c = 'Project will not be executed';
            }
        }

        if (!oppList.isEmpty()) {
            System.debug('✏️ Updating ' + oppList.size() + ' Opportunities');
            update oppList;
        }
    }
    
    public void beforeDelete(List<SObject> oldRecords) {
        // Not implemented
    }
    
    public void afterDelete(List<SObject> oldRecords) {
        // Not implemented
    }
}