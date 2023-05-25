/**
 * @author Keshav - Comforth Karoo
 * @date 2021-06-29
 * @modified 2020-11-10
 * @description Trigger handler class for Order_Influence__c
*/
public with sharing class TH_OrderInfluence extends TriggerHandler  {
    public override void beforeInsert(){
        SM019_VerificationOfOrderInfluence.DuplicateVerification(Trigger.New);
    }
    public override void beforeUpdate(){
        SM019_VerificationOfOrderInfluence.DuplicateVerification(Trigger.New);
    }
}