/* 
----------------------------------------------------------------------
-- - Name          : ContactTrigger
-- - Author        : Comforth
-- - Description   : Contact Trigger Handler 
-- - Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 03 DEC-2020  SRA    1.0     Initial version - 
----------------------------------------------------------------------
***********************************************************************/
trigger ContactTrigger on Contact (after delete, after insert, after update, before delete, before insert, before update) {
    BypassTrigger__c getAuth = BypassTrigger__c.getOrgDefaults();
    system.debug('getAuth' + getAuth.Activatetrigger__c);
    
    if(getAuth.Activatetrigger__c == true){
        new TH_Contact().run();
    }
}