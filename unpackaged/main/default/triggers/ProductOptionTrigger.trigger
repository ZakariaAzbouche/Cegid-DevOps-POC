/**
* @author Keshav - Comforth
* @date 2020-06-04
* @modified 2020-06-04
* @group ProductOptionTrigger
* @object SBQQ__ProductOption__c
* @description 
*/
trigger ProductOptionTrigger on SBQQ__ProductOption__c (before insert,after insert, after update, before delete, after delete) {

    if(Recursionblocker.productOptionTrigger < 2){
        system.debug('ProductOptionTrigger');
        new TH_ProductOption().run();
        Recursionblocker.productOptionTrigger = Recursionblocker.productOptionTrigger + 1;
    }
   
}