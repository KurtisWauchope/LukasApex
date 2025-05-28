global class V11_scheduleProductImport implements Schedulable{

    global void execute(SchedulableContext sc){
        V11_batchProductsUpsert batchhandler = new V11_batchProductsUpsert();
        database.executeBatch(batchhandler,200);       
    }
}