global class V11_scheduleQuoteImport implements Schedulable{

    global void execute(SchedulableContext sc){
        V11_batchQuoteUpsert batch = new V11_batchQuoteUpsert();
        Database.executeBatch(batch,200);
    }

}