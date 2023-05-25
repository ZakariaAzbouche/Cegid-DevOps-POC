/* 
----------------------------------------------------------------------
-- - Name          : CaseTrigger
-- - Author        : Comforth
-- - Description   : Case Trigger Handler 
-- - Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 01 DEC-2020  SRA    1.0     Initial version - 
----------------------------------------------------------------------
***********************************************************************/
trigger CaseTrigger on Case (after delete, after insert, after update, before delete, before insert, before update) {
    BypassTrigger__c getAuth = BypassTrigger__c.getOrgDefaults();
    system.debug('getAuth' + getAuth.Activatetrigger__c);
    
    if(getAuth.Activatetrigger__c == true){
        new TH_Case().run();
    }
}