/**
* @author Keshav M - Comforth Karoo
* @date 2021-07-01
* @description Trigger for Service_Level_Price__c
*/
trigger ServiceLevelPriceTrigger on Service_Level_Price__c (before insert,after insert, after update,after delete) {
    System.debug('ServiceLevelPriceTrigger');
    BypassTrigger__c getAuth = BypassTrigger__c.getOrgDefaults();
    if(getAuth.Activatetrigger__c ){
        new TH_ServiceLevelPrice().run();
    }
}