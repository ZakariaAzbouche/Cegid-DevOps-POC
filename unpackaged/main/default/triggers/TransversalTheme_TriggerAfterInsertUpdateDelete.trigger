trigger TransversalTheme_TriggerAfterInsertUpdateDelete on Transversal_Theme__c (after insert, after update, after delete){
	// Build a Set of products for which we will have to calculate the maximum discount allowed, on the 'Transversal Theme' line, 
	// for the different validation groups
    Set<Id> productIds = new Set<Id>();
    
    // On Insert and Update
    if(Trigger.isInsert || Trigger.isUpdate){
        System.debug('>>>> TransversalTheme_TriggerAfterInsertUpdateDelete Insert or Update');
        for(Transversal_Theme__c theme : Trigger.new){
            productIds.add(theme.Product__c);
        }
    }
    
    // On Delete
    if(Trigger.isDelete){
        System.debug('>>>> TransversalTheme_TriggerAfterInsertUpdateDelete Delete');
        for(Transversal_Theme__c theme : Trigger.old){
            productIds.add(theme.Product__c);
        }
    }
    
    // Update all the affected Products with the potential new Max Discounts
    DiscountWorkflowUtils.updateProductsWithNewMaxDiscounts(productIds);
}