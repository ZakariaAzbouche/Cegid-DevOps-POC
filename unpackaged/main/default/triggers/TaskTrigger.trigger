/**
* @author Keshav - Comforth Karoo
* @date 2021-06-29
* @modified 2020-11-10
* @description  
*/
trigger TaskTrigger on Task (before insert, before update) {
    BypassTrigger__c getAuth = BypassTrigger__c.getOrgDefaults();
    if(getAuth.Activatetrigger__c){
        new TH_Task().run();
    }
}