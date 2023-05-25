global with sharing class BatchAlertOwnerOppyStageMqlSchedule  implements Schedulable {
    
    global static String scheduleMe() {
        BatchAlertOwnerOppyStageMqlSchedule batchSchedule = new BatchAlertOwnerOppyStageMqlSchedule(); 			
        
        //return System.schedule('BatchAlertOwnerOppyStageMql',  '0 0 0 ? * MON,TUE,WED,THU,FRI *', batchSchedule);                
        System.schedule('BatchAlertOwnerOppyStageMqlSchedule 1',  '0 00 * * * ?', batchSchedule);
        System.schedule('BatchAlertOwnerOppyStageMqlSchedule 2',  '0 05 * * * ?', batchSchedule);
        System.schedule('BatchAlertOwnerOppyStageMqlSchedule 3',  '0 10 * * * ?', batchSchedule);
        System.schedule('BatchAlertOwnerOppyStageMqlSchedule 4',  '0 15 * * * ?', batchSchedule);
        System.schedule('BatchAlertOwnerOppyStageMqlSchedule 5',  '0 20 * * * ?', batchSchedule);
        System.schedule('BatchAlertOwnerOppyStageMqlSchedule 6',  '0 25 * * * ?', batchSchedule);
        System.schedule('BatchAlertOwnerOppyStageMqlSchedule 7',  '0 30 * * * ?', batchSchedule);
        System.schedule('BatchAlertOwnerOppyStageMqlSchedule 8',  '0 35 * * * ?', batchSchedule);
        System.schedule('BatchAlertOwnerOppyStageMqlSchedule 9',  '0 40 * * * ?', batchSchedule);
        System.schedule('BatchAlertOwnerOppyStageMqlSchedule 10', '0 45 * * * ?', batchSchedule);
        System.schedule('BatchAlertOwnerOppyStageMqlSchedule 11', '0 50 * * * ?', batchSchedule);
        System.schedule('BatchAlertOwnerOppyStageMqlSchedule 12', '0 55 * * * ?', batchSchedule);
        return 'OK';
    }	
    
     global void execute (SchedulableContext SC){
        BatchAlertOwnerOppyStageMql batch = new BatchAlertOwnerOppyStageMql();
        ID batchprocessid = Database.executeBatch(batch, 50);
   }
}