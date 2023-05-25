public class TriggerUtils {

    @TestVisible
    private static User currentUser;
    @TestVisible
    private static Map<System.TriggerOperation, Set<Id>> alreadySeenRecords = new Map<System.TriggerOperation, Set<Id>>();

    @InvocableMethod(label='controlCPQTrigger' description='enable/disbale CPQ trigger')
    public static void controlCPQTrigger() {
        if(SBQQ.TriggerControl.isEnabled()) {
            SBQQ.TriggerControl.disable();
        } else {
            SBQQ.TriggerControl.enable();
        }
        System.debug('Trigger control enable ? : ' +SBQQ.TriggerControl.isEnabled());
    }

    public static Boolean checkUserByPass() {
        if(currentUser == null) {
            currentUser = [SELECT Bypass_Apex_Triggers__c FROM USER WHERE Id =: UserInfo.getUserId()];
        }
        return currentUser.Bypass_Apex_Triggers__c;
    }

    
    /**
     * Static Apex Method
     * @date               1.0 (2021-11-25)  
     * @description        CheckRecursivCall ensure IDs are used only once per trigger operation and transaction (Execution thread)
     * @param              triggerRecordMap     Map<Id, SObject>, all records which fired the trigger (Trigger.NewMap) 
     * @param              triggerOperation     System.TriggerOperation, trigger database operation
     * @return             Map<Id, SObject>     records which fired the trigger for the first time      
    **/
    public static Map<Id, SObject> checkRunOnce(Map<Id, SObject> triggerRecordMap, System.TriggerOperation triggerOperation) {
        System.debug('CHECK RECURSIVE');
        System.debug(triggerOperation);
        Map<Id, SObject> toBeProcessed = triggerRecordMap.clone();
        
        //Check if trigger already fired for record in parameter 
        if(alreadySeenRecords.containsKey(triggerOperation)) {
            // Remove the records we've already seen
            toBeProcessed.keySet().removeAll(alreadySeenRecords.get(triggerOperation));
            // We're left with a Map of records that this is our first time seeing
            
            // Add the Ids to the set of Ids we've seen (only for one trigger operation)
            alreadySeenRecords.get(triggerOperation).addAll(toBeProcessed.keySet());
        } else {
            // Add the Ids to the set of Ids we've seen (only for one trigger operation)
            alreadySeenRecords.put(triggerOperation, toBeProcessed.keySet().clone());
        }
        System.debug('NEW RECORDS SIZE : '+toBeProcessed.size());
        System.debug('ALREADY SEEN RECORDS SIZE : '+alreadySeenRecords.get(triggerOperation).size());
        return toBeProcessed;
    }

}