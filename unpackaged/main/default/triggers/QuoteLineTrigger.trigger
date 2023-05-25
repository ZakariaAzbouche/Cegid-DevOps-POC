/**
 * @author Shamina M - Comforth Karoo
 * @date 2020-08-31
 * @description Trigger for SBQQ__QuoteLine__c
*/
trigger QuoteLineTrigger on SBQQ__QuoteLine__c (before insert,after insert,before update,after update,after delete) {

    system.debug(' Recursionblocker.quoteLineTrigger : ' +  Recursionblocker.quoteLineTrigger);
    // Recursionblocker.quoteLineTrigger < 2 is used as to allow to execution e.g  1 before update 2 after update
    integer maxNum = 100;
    integer loopCount = (Test.isRunningTest())?maxNum:2;
    if(Recursionblocker.quoteLineTrigger < loopCount){
        new TH_QuoteLine().run();
        Recursionblocker.quoteLineTrigger =  Recursionblocker.quoteLineTrigger + 1;
    }
   
}