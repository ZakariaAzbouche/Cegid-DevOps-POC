@isTest
public class TriggerUtils_Test {
    @isTest static void controlCPQTriggerTest() {
        Test.startTest();
            TriggerUtils.controlCPQTrigger();
            TriggerUtils.controlCPQTrigger();
        Test.stopTest();
    }

    @isTest static void checkUserByPassTest() {
        TriggerUtils.checkUserByPass();
    }


    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();  
    @isTest static void checkRunOnceTest() {
        List<Account> accs = new List<Account>();

        for(Integer i = 0; i < 100 ; i++) {
            accs.add(new Account(Name='Test'+i));
        }
        System.runAs(adminUser) {
            insert accs;
        }
        

        Map<Id, Account> accsMap = new Map<Id, Account>(accs);
       
        //first run
        Map<Id, SObject> resultsBeforeInsertFirst = TriggerUtils.checkRunOnce(accsMap, System.TriggerOperation.BEFORE_INSERT);
        Map<Id, SObject> resultsBeforeUpdateFirst = TriggerUtils.checkRunOnce(accsMap, System.TriggerOperation.BEFORE_UPDATE);
        Map<Id, SObject> resultsBeforeDeleteFirst = TriggerUtils.checkRunOnce(accsMap, System.TriggerOperation.BEFORE_DELETE);

        Map<Id, SObject> resultsAfterInsertFirst = TriggerUtils.checkRunOnce(accsMap, System.TriggerOperation.AFTER_INSERT);
        Map<Id, SObject> resultsAfterUpdateFirst = TriggerUtils.checkRunOnce(accsMap, System.TriggerOperation.AFTER_UPDATE);
        Map<Id, SObject> resultsAfterDeleteFirst = TriggerUtils.checkRunOnce(accsMap, System.TriggerOperation.AFTER_DELETE);
        
        String errorMessageFirst = 'All inserted record should be in the map result because it is the first time';
        System.assertEquals(100, resultsBeforeInsertFirst.size(), errorMessageFirst);
        System.assertEquals(100, resultsBeforeUpdateFirst.size(), errorMessageFirst);
        System.assertEquals(100, resultsBeforeDeleteFirst.size(), errorMessageFirst);
        System.assertEquals(100, resultsAfterInsertFirst.size(), errorMessageFirst);
        System.assertEquals(100, resultsAfterUpdateFirst.size(), errorMessageFirst);
        System.assertEquals(100, resultsAfterDeleteFirst.size(), errorMessageFirst);

         //second run
         Map<Id, SObject> resultsBeforeInsertSecond =TriggerUtils.checkRunOnce(accsMap, System.TriggerOperation.BEFORE_INSERT);
         Map<Id, SObject> resultsBeforeUpdateSecond =TriggerUtils.checkRunOnce(accsMap, System.TriggerOperation.BEFORE_UPDATE);
         Map<Id, SObject> resultsBeforeDeleteSecond =TriggerUtils.checkRunOnce(accsMap, System.TriggerOperation.BEFORE_DELETE);
 
         Map<Id, SObject> resultsAfterInsertSecond =TriggerUtils.checkRunOnce(accsMap, System.TriggerOperation.AFTER_INSERT);
         Map<Id, SObject> resultsAfterUpdateSecond =TriggerUtils.checkRunOnce(accsMap, System.TriggerOperation.AFTER_UPDATE);
         Map<Id, SObject> resultsAfterDeleteSecond =TriggerUtils.checkRunOnce(accsMap, System.TriggerOperation.AFTER_DELETE);
         
         String errorMessageSecond = 'map result should be empty';
         System.assertEquals(true, resultsBeforeInsertSecond.isEmpty(), errorMessageSecond);
         System.assertEquals(true, resultsBeforeUpdateSecond.isEmpty(), errorMessageSecond);
         System.assertEquals(true, resultsBeforeDeleteSecond.isEmpty(), errorMessageSecond);
         System.assertEquals(true, resultsAfterInsertSecond.isEmpty(), errorMessageSecond);
         System.assertEquals(true, resultsAfterUpdateSecond.isEmpty(), errorMessageSecond);
         System.assertEquals(true, resultsAfterDeleteSecond.isEmpty(), errorMessageSecond);

    }
}