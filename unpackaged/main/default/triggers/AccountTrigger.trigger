/*
----------------------------------------------------------------------
-- - Name          : AccountTrigger
-- - Author        : Comforth
-- - Description   : Account Trigger Handler 
-- - Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 22 Oct-2020  SRA    1.0     Initial version - 
----------------------------------------------------------------------
***********************************************************************/
trigger AccountTrigger on Account (after delete, after insert, after update, before delete, before insert, before update) {
    BypassTrigger__c getAuth = BypassTrigger__c.getOrgDefaults();
    system.debug('getAuth' + getAuth.Activatetrigger__c);
    
    if(getAuth.Activatetrigger__c){
        system.debug('TriggergetAuth');
        new TH_Account().run();
    }
}