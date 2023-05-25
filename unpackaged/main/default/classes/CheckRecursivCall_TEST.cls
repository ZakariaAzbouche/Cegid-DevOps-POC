@isTest
public class CheckRecursivCall_TEST {
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
        Map<Id, SObject> resultsBeforeInsertFirst = CheckRecursivCall.checkRunOnce(accsMap, System.TriggerOperation.BEFORE_INSERT);
        Map<Id, SObject> resultsBeforeUpdateFirst = CheckRecursivCall.checkRunOnce(accsMap, System.TriggerOperation.BEFORE_UPDATE);
        Map<Id, SObject> resultsBeforeDeleteFirst = CheckRecursivCall.checkRunOnce(accsMap, System.TriggerOperation.BEFORE_DELETE);

        Map<Id, SObject> resultsAfterInsertFirst = CheckRecursivCall.checkRunOnce(accsMap, System.TriggerOperation.AFTER_INSERT);
        Map<Id, SObject> resultsAfterUpdateFirst = CheckRecursivCall.checkRunOnce(accsMap, System.TriggerOperation.AFTER_UPDATE);
        Map<Id, SObject> resultsAfterDeleteFirst = CheckRecursivCall.checkRunOnce(accsMap, System.TriggerOperation.AFTER_DELETE);
        
        String errorMessageFirst = 'All inserted record should be in the map result because it is the first time';
        System.assertEquals(100, resultsBeforeInsertFirst.size(), errorMessageFirst);
        System.assertEquals(100, resultsBeforeUpdateFirst.size(), errorMessageFirst);
        System.assertEquals(100, resultsBeforeDeleteFirst.size(), errorMessageFirst);
        System.assertEquals(100, resultsAfterInsertFirst.size(), errorMessageFirst);
        System.assertEquals(100, resultsAfterUpdateFirst.size(), errorMessageFirst);
        System.assertEquals(100, resultsAfterDeleteFirst.size(), errorMessageFirst);

         //second run
         Map<Id, SObject> resultsBeforeInsertSecond =CheckRecursivCall.checkRunOnce(accsMap, System.TriggerOperation.BEFORE_INSERT);
         Map<Id, SObject> resultsBeforeUpdateSecond =CheckRecursivCall.checkRunOnce(accsMap, System.TriggerOperation.BEFORE_UPDATE);
         Map<Id, SObject> resultsBeforeDeleteSecond =CheckRecursivCall.checkRunOnce(accsMap, System.TriggerOperation.BEFORE_DELETE);
 
         Map<Id, SObject> resultsAfterInsertSecond =CheckRecursivCall.checkRunOnce(accsMap, System.TriggerOperation.AFTER_INSERT);
         Map<Id, SObject> resultsAfterUpdateSecond =CheckRecursivCall.checkRunOnce(accsMap, System.TriggerOperation.AFTER_UPDATE);
         Map<Id, SObject> resultsAfterDeleteSecond =CheckRecursivCall.checkRunOnce(accsMap, System.TriggerOperation.AFTER_DELETE);
         
         String errorMessageSecond = 'map result should be empty';
         System.assertEquals(true, resultsBeforeInsertSecond.isEmpty(), errorMessageSecond);
         System.assertEquals(true, resultsBeforeUpdateSecond.isEmpty(), errorMessageSecond);
         System.assertEquals(true, resultsBeforeDeleteSecond.isEmpty(), errorMessageSecond);
         System.assertEquals(true, resultsAfterInsertSecond.isEmpty(), errorMessageSecond);
         System.assertEquals(true, resultsAfterUpdateSecond.isEmpty(), errorMessageSecond);
         System.assertEquals(true, resultsAfterDeleteSecond.isEmpty(), errorMessageSecond);

    }
}