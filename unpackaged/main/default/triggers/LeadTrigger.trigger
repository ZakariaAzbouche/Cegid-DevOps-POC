trigger LeadTrigger on Lead  (after delete, after insert, after update, before delete, before insert, before update) {


    system.debug(' Recursionblocker.leadTrigger : ' +  Recursionblocker.leadTrigger);
    // Recursionblocker.quoteLineTrigger < 2 is used as to allow to execution e.g  1 before update 2 after update
    system.debug('leadTrigger');
    new TH_Lead().run();      
    
}