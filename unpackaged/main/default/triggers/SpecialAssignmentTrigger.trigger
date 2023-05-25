/**
 * @author Easyfront Consulting
 * @date 2022-11-21
 * @description Trigger for Special_Assignment__c
*/
trigger SpecialAssignmentTrigger on Special_Assignment__c (before insert,after insert,after update, before update, before delete) {
    BypassTrigger__c getAuth = BypassTrigger__c.getOrgDefaults();
    if(getAuth.Activatetrigger__c){
        system.debug('SpecialAssignmentTrigger');
        new TH_SpecialAssignment().run();
    }
}