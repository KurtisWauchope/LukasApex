global class V11_scheduleOrderImport implements Schedulable{

    global void execute(SchedulableContext sc){
        V11_batchGetOrderIDs batch = new V11_batchGetOrderIDs();
        Database.executeBatch(batch,200);
    }

}