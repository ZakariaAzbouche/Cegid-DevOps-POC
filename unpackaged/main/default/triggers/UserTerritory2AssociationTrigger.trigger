trigger UserTerritory2AssociationTrigger on UserTerritory2Association (after insert, after update, after delete) {

    
    system.debug(' Recursionblocker.userTerritory2Association : ' +  Recursionblocker.userTerritory2AssociationTrigger);
    // Recursionblocker.quoteLineTrigger < 2 is used as to allow to execution e.g  1 before update 2 after update

    if(Recursionblocker.userTerritory2AssociationTrigger < 2 ){
        system.debug('UserTerritory2Association');
        new TH_UserTerritory2Association().run();
        Recursionblocker.userTerritory2AssociationTrigger = Recursionblocker.userTerritory2AssociationTrigger + 1;
        
    }
    
}