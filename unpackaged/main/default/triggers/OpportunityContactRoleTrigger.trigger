trigger OpportunityContactRoleTrigger on OpportunityContactRole (after delete, after insert, after update, before delete, before insert, before update) {
    

    if( Recursionblocker.OpportunityContactRoleTrigger < 2){
        new TH_OpportunityContactRole().run();
        Recursionblocker.contactTrigger = Recursionblocker.OpportunityContactRoleTrigger + 1;
    }

}