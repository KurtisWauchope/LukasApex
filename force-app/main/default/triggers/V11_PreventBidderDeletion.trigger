trigger V11_PreventBidderDeletion on Bidder__c (before delete) {
    List<Bidder__c> raicoBidders = [SELECT Id, RecordType.DeveloperName, Building_Project__c FROM Bidder__c WHERE RecordType.DeveloperName = 'Raico_bidder' AND Id IN :Trigger.old];
    List<BuildingProject__c> bps = [SELECT BidderListSent__c FROM BuildingProject__c WHERE Id IN (SELECT Building_Project__c FROM Bidder__c WHERE Id IN :raicoBidders)];
    Map<Id, BuildingProject__c> bpMap = new Map<Id, BuildingProject__c>(bps);

    for (Bidder__c b : raicoBidders) {
        BuildingProject__c bp = bpMap.get(b.Building_Project__c);
        String errMsg = Label.BidderDeletionErr;
        if (bp.BidderListSent__c) {
           Trigger.oldMap.get(b.Id).addError(errMsg);
        }
    }
}