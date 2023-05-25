/**
* @author Shamina M - Comforth Karoo
* @date 2020-11-06
* @modified 2020-06-04
* @group Product2Trigger
* @object Product2
* @description 
*/
trigger Product2Trigger on Product2 (after insert,after update, after delete) {

        system.debug('Product2Trigger');
        new TH_Product2().run();
        
}