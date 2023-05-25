/**
* @author Shamina M - Comforth Karoo
* @date 2020-11-06
* @modified 2020-06-04
* @group OpportunityLineItemTrigger
* @object  OpportunityLineItem
* @description 
*/
trigger OpportunityLineItemTrigger on  OpportunityLineItem (before insert, after insert, before update, after update, before delete, after delete) {
    new TH_OpportunityLineItem().run();
}