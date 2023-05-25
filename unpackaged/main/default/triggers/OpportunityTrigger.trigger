/* 
----------------------------------------------------------------------
-- - Name          : OpportunityTrigger
-- - Author        : Comforth
-- - Description   : Opportunity Trigger Handler 
-- - Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 17 Jan-2020  KMM    1.0     Initial version - 
----------------------------------------------------------------------
***********************************************************************/
trigger OpportunityTrigger on Opportunity (after delete, after insert, after update, before delete, before insert, before update) {
    BypassTrigger__c getAuth = BypassTrigger__c.getOrgDefaults();
    system.debug('getAuth' + getAuth.Activatetrigger__c);
    
    if(getAuth.Activatetrigger__c == true){
        new TH_Opportunity().run();
    }
}