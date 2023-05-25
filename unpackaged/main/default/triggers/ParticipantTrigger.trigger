/**
* @author Keshav - Comforth Karoo
* @date 2021-08-26
* @description  
*/
trigger ParticipantTrigger on Participant__c (before insert,before update) {
    BypassTrigger__c getAuth = BypassTrigger__c.getOrgDefaults();
    if(getAuth.Activatetrigger__c){
        new TH_Participant().run();
        
        
    }
    system.debug('##getAuth  ' + getAuth);
    system.debug('##Activatetrigger__c  ' + getAuth.Activatetrigger__c);
}