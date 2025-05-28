/**
 * @description       : Service-Klasse zum Zurücksetzen von BuildingProjects und Opportunities
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-05-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class V11_BuildingProjectResetService {
    // Flag, um zu erkennen, ob ein Reset-Vorgang läuft
    private static boolean isResetting = false;
    
    @InvocableMethod(label='Reset Opportunities and Quotes by BuildingProject')
    public static void resetByBuildingProject(List<Id> buildingProjectIds) {
        System.debug('⏳ Eingehender Reset für BuildingProject IDs: ' + buildingProjectIds);
        
        try {
            // Reset-Modus aktivieren - Trigger werden diesen Zustand prüfen
            isResetting = true;
            
            // Vorprozess: Ensure TriggerHelper Counts are at zero
            V11_TriggerHelper.clearProcessed();
            
            // 1. ZUERST BuildingProject zurücksetzen
            List<BuildingProject__c> bpsToUpdate = [
                SELECT Id, Stage__c, Previous_Stage__c, Allocationfabricator__c, Probability__c
                FROM BuildingProject__c
                WHERE Id IN :buildingProjectIds
            ];
            
            Integer bpResetCount = 0;
            Set<Id> actualBuildingProjectIds = new Set<Id>();
            
            for (BuildingProject__c bp : bpsToUpdate) {
                actualBuildingProjectIds.add(bp.Id);
                
                // Wenn Previous_Stage__c vorhanden, nehmen wir diesen
                if (String.isNotBlank(bp.Previous_Stage__c)) {
                    bp.Stage__c = bp.Previous_Stage__c;
                    bp.Previous_Stage__c = null;
                } else if (bp.Stage__c == 'Execution') {
                    // Wenn keine Previous_Stage__c und Execution -> zurück zu Tender & Quote
                    bp.Stage__c = 'Tender & Quote';
                }
                
                // Auf jeden Fall Fabricator und Probability zurücksetzen
                bp.Allocationfabricator__c = null;
                bp.Probability__c = '0';
                bpResetCount++;
            }
            
            if (!bpsToUpdate.isEmpty()) {
                update bpsToUpdate;
            }
            
            // 2. DANN Opportunities zurücksetzen - NUR die auf Closed Won gesetzten
            List<Opportunity> oppsToUpdate = [
                SELECT Id, StageName, Previous_Stage__c, AccountId, Name
                FROM Opportunity
                WHERE BuildingProject__c IN :actualBuildingProjectIds
                AND StageName = 'Closed Won'  // Nur die versehentlich auf Closed Won gesetzten
            ];
            
            Integer oppResetCount = 0;
            Set<Id> resetOppIds = new Set<Id>();
            
            for (Opportunity opp : oppsToUpdate) {
                resetOppIds.add(opp.Id);
                
                if (String.isNotBlank(opp.Previous_Stage__c)) {
                    // Zurück auf die vorherige Phase setzen
                    System.debug('🔄 Opportunity ' + opp.Id + ' wird von [' + opp.StageName + '] zurück auf [' + opp.Previous_Stage__c + '] gesetzt');
                    opp.StageName = opp.Previous_Stage__c;
                    opp.Previous_Stage__c = null;
                } else {
                    // Fallback: zurück auf "Negotiation"
                    System.debug('🔄 Opportunity ' + opp.Id + ' wird von [' + opp.StageName + '] zurück auf [Negotiation] gesetzt (kein vorheriger Status verfügbar)');
                    opp.StageName = 'Negotiation';
                }
                
                oppResetCount++;
            }
            
            if (!oppsToUpdate.isEmpty()) {
                update oppsToUpdate;
            }
            
            // 3. ZULETZT Quotes zurücksetzen - NUR für die zurückgesetzten Opportunities
            if (!resetOppIds.isEmpty()) {
                List<Quote> quotesToUpdate = [
                    SELECT Id, Status, Previous_Stage__c, ParentOpportunity__c, Name
                    FROM Quote
                    WHERE ParentOpportunity__c IN :resetOppIds
                    AND Status = 'Accepted'  // Nur die auf Accepted gesetzten
                ];
                
                Integer quoteResetCount = 0;
                
                for (Quote q : quotesToUpdate) {
                    if (String.isNotBlank(q.Previous_Stage__c)) {
                        System.debug('🔄 Quote ' + q.Id + ' wird von [' + q.Status + '] zurück auf [' + q.Previous_Stage__c + '] gesetzt');
                        q.Status = q.Previous_Stage__c;
                        q.Previous_Stage__c = null;
                    } else {
                        // Fallback: zurück auf "Sent"
                        System.debug('🔄 Quote ' + q.Id + ' wird von [' + q.Status + '] zurück auf [Sent] gesetzt (kein vorheriger Status verfügbar)');
                        q.Status = 'Sent';
                    }
                    
                    quoteResetCount++;
                }
                
                if (!quotesToUpdate.isEmpty()) {
                    update quotesToUpdate;
                }
                
                System.debug('→ Quotes zurückgesetzt: ' + quoteResetCount);
            }
            
            // 4. System.debug-Ausgabe
            System.debug('✅ BuildingProject Reset erfolgreich.');
            System.debug('→ BuildingProjects zurückgesetzt: ' + bpResetCount);
            System.debug('→ Opportunities zurückgesetzt: ' + oppResetCount);
        } finally {
            // Reset-Modus deaktivieren
            isResetting = false;
        }
    }
    
    // Methode, um zu prüfen, ob gerade ein Reset stattfindet
    public static boolean isResetInProgress() {
        return isResetting;
    }
}