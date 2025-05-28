public class V11_batchGetOrderIDs implements Database.Batchable<String>, Database.AllowsCallouts,Database.Stateful {

    List<String> orderIds = new List<String>();
    WebserviceLog__c wsLog = new WebserviceLog__c();

    public List<String> start (Database.BatchableContext bc)
    {
        orderIds = V11_callComarchImport.getOrderIds(wsLog);
        return orderIds;
    }
    public void execute(Database.BatchableContext bc, List<String> scope)
    {

    }
    public void finish(Database.BatchableContext bc)
    {
        if(orderIds.size()>0){
            V11_batchOrderUpsert batchhandler = new V11_batchOrderUpsert(orderIds);
            database.executeBatch(batchhandler,200);
        }
    }
    
}