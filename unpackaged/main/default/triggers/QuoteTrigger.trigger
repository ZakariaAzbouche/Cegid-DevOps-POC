/**
 * @author Keshav M - Comforth Karoo
 * @date 2020-11-23
 * @description Trigger for SBQQ__Quote__c
*/
trigger QuoteTrigger on SBQQ__Quote__c (before insert,after insert,after update, before update) {
    // Recursionblocker.quoteTrigger < 2 is used as to allow to execution e.g  1 before update 2 after update
    BypassTrigger__c getAuth = BypassTrigger__c.getOrgDefaults();
    if(getAuth.Activatetrigger__c && Recursionblocker.quoteTrigger < Integer.valueOf(System.Label.QuoteExecution) ){
        system.debug('QuoteTrigger');
        new TH_Quote().run();
    }
    Recursionblocker.quoteTrigger =  Recursionblocker.quoteTrigger + 1;
}