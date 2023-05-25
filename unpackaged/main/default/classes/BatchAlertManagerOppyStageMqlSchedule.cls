global with sharing class BatchAlertManagerOppyStageMqlSchedule implements Schedulable {
    
    global static String scheduleMe() {
        BatchAlertManagerOppyStageMqlSchedule batchSchedule = new BatchAlertManagerOppyStageMqlSchedule(); 	
  
        //return System.schedule('BatchAlertManagerOppyStageMql',  '0 0 0 ? * MON,TUE,WED,THU,FRI *', batchSchedule);        

        System.schedule('BatchAlertManagerOppyStageMql 1',  '0 00 * * * ?', batchSchedule);
        System.schedule('BatchAlertManagerOppyStageMql 2',  '0 05 * * * ?', batchSchedule);
        System.schedule('BatchAlertManagerOppyStageMql 3',  '0 10 * * * ?', batchSchedule);
        System.schedule('BatchAlertManagerOppyStageMql 4',  '0 15 * * * ?', batchSchedule);
        System.schedule('BatchAlertManagerOppyStageMql 5',  '0 20 * * * ?', batchSchedule);
        System.schedule('BatchAlertManagerOppyStageMql 6',  '0 25 * * * ?', batchSchedule);
        System.schedule('BatchAlertManagerOppyStageMql 7',  '0 30 * * * ?', batchSchedule);
        System.schedule('BatchAlertManagerOppyStageMql 8',  '0 35 * * * ?', batchSchedule);
        System.schedule('BatchAlertManagerOppyStageMql 9',  '0 40 * * * ?', batchSchedule);
        System.schedule('BatchAlertManagerOppyStageMql 10', '0 45 * * * ?', batchSchedule);
        System.schedule('BatchAlertManagerOppyStageMql 11', '0 50 * * * ?', batchSchedule);
        System.schedule('BatchAlertManagerOppyStageMql 12', '0 55 * * * ?', batchSchedule);
        return 'OK';
    }	
    
     global void execute (SchedulableContext SC){
        BatchAlertManagerOppyStageMql batch = new BatchAlertManagerOppyStageMql();
        ID batchprocessid = Database.executeBatch(batch, 50);
   }
}