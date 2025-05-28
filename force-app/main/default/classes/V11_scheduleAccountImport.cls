global class V11_scheduleAccountImport implements Schedulable{

    global void execute(SchedulableContext sc){
        V11_batchAccountUpdate batch = new V11_batchAccountUpdate();
        Database.executeBatch(batch,200);
    }
}