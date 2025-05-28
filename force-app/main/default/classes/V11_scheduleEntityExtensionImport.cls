global class V11_scheduleEntityExtensionImport implements Schedulable{

    global void execute(SchedulableContext sc){
        V11_batchEntityExtensionUpsert batch = new V11_batchEntityExtensionUpsert();
        Database.executeBatch(batch,200);
    }

}