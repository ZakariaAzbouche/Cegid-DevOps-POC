global class BatchObjectTerritory2AssociationSchedule implements Schedulable {


    global static String scheduleMe() {
        BatchObjectTerritory2AssociationSchedule batchSchedule = new BatchObjectTerritory2AssociationSchedule(); 	
        System.schedule('BatchObjectTerritory2AssociationSchedule Job 1', '0 0 * * * ?', batchSchedule);
        System.schedule('BatchObjectTerritory2AssociationSchedule Job 2', '0 3 * * * ?', batchSchedule);
        System.schedule('BatchObjectTerritory2AssociationSchedule Job 3', '0 5 * * * ?', batchSchedule);
        System.schedule('BatchObjectTerritory2AssociationSchedule Job 4', '0 10 * * * ?', batchSchedule);
        System.schedule('BatchObjectTerritory2AssociationSchedule Job 5', '0 13 * * * ?', batchSchedule);
        System.schedule('BatchObjectTerritory2AssociationSchedule Job 6', '0 15 * * * ?', batchSchedule);
        System.schedule('BatchObjectTerritory2AssociationSchedule Job 7', '0 18 * * * ?', batchSchedule);
        System.schedule('BatchObjectTerritory2AssociationSchedule Job 8', '0 20 * * * ?', batchSchedule);
        System.schedule('BatchObjectTerritory2AssociationSchedule Job 9', '0 23 * * * ?', batchSchedule);
        System.schedule('BatchObjectTerritory2AssociationSchedule Job 10', '0 25 * * * ?', batchSchedule);
        System.schedule('BatchObjectTerritory2AssociationSchedule Job 11', '0 28 * * * ?', batchSchedule);
        System.schedule('BatchObjectTerritory2AssociationSchedule Job 12', '0 30 * * * ?', batchSchedule);
        System.schedule('BatchObjectTerritory2AssociationSchedule Job 13', '0 33 * * * ?', batchSchedule);
        System.schedule('BatchObjectTerritory2AssociationSchedule Job 14', '0 35 * * * ?', batchSchedule);
        System.schedule('BatchObjectTerritory2AssociationSchedule Job 15', '0 38 * * * ?', batchSchedule);
        System.schedule('BatchObjectTerritory2AssociationSchedule Job 16', '0 40 * * * ?', batchSchedule);
        System.schedule('BatchObjectTerritory2AssociationSchedule Job 17', '0 43 * * * ?', batchSchedule);
        System.schedule('BatchObjectTerritory2AssociationSchedule Job 18', '0 45 * * * ?', batchSchedule);
        System.schedule('BatchObjectTerritory2AssociationSchedule Job 19', '0 48 * * * ?', batchSchedule);
        System.schedule('BatchObjectTerritory2AssociationSchedule Job 20', '0 50 * * * ?', batchSchedule);
        System.schedule('BatchObjectTerritory2AssociationSchedule Job 21', '0 53 * * * ?', batchSchedule);
        System.schedule('BatchObjectTerritory2AssociationSchedule Job 22', '0 55 * * * ?', batchSchedule);
        System.schedule('BatchObjectTerritory2AssociationSchedule Job 23', '0 58 * * * ?', batchSchedule);
                
        return 'OK';
    }	
    
     global void execute (SchedulableContext SC){
        BatchObjectTerritory2Association batch = new BatchObjectTerritory2Association();
        ID batchprocessid = Database.executeBatch(batch, 50);
   }
}