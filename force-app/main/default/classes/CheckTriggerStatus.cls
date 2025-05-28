/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-29-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CheckTriggerStatus {
    public static void checkTriggers() {
        // Trigger-Metadaten abfragen
        List<ApexTrigger> triggers = [
            SELECT Id, Name, Status, IsValid, ApiVersion, BodyCrc 
            FROM ApexTrigger 
            WHERE Name LIKE '%Opportunity%'
        ];
        
        for (ApexTrigger trig : triggers) {
            System.debug('Trigger: ' + trig.Name + ' - Status: ' + trig.Status + ' - IsValid: ' + trig.IsValid);
        }
    }
}