public class DiscountWorkflowUtils{
    
    public static void updateProductsWithNewMaxDiscounts(Set<Id> productIds){
        // Retrieve all the information we need regarding the Transversal Themes linked to the Products coming from the Trigger
        List<AggregateResult> transversalThemes = [Select MIN(Discount_Max_Level_2__c) DiscountMaxLevel2, 
                                                   MIN(Discount_Max_Level_3__c) DiscountMaxLevel3, Product__c
                                                   From Transversal_Theme__c
                                                   Where Product__c IN :productIds
                                                   Group by Product__c];
        
		System.debug('>>>> DiscountWorkflowUtils.updateProductsWithNewMaxDiscounts transversalThemes = ' + transversalThemes);        
        
        // Creation of two maps which will contain, for each Product, the max discount obtained from the query,
        // respectively for the Validation Group Level 2 and the Validation Group Level 3
        Map<Id, String> discountMaxLevel2ByProduct = new Map<Id, String>();
        Map<Id, String> discountMaxLevel3ByProduct = new Map<Id, String>();
        
        // For each Transversal Theme in the obtained List, put the retrieved Max Discounts into the Maps along with the 
        // associated Product Id, which will be used as the key
        for(AggregateResult theme : transversalThemes){
            discountMaxLevel2ByProduct.put((Id)theme.get('Product__c'), String.valueOf(theme.get('DiscountMaxLevel2')));
            discountMaxLevel3ByProduct.put((Id)theme.get('Product__c'), String.valueOf(theme.get('DiscountMaxLevel3'))); 
        }
        
        // Prepare a List with all the Products that need to be updated with the new Max Discounts
        List<Product2> productsToUpdate = new List<Product2>();
        for(Id productId : productIds){
            Product2 product = new Product2(Id = productId,
                                            Transversal_Theme_Discount_Max_Level_2__c = discountMaxLevel2ByProduct.get(productId),
                                            Transversal_Theme_Discount_Max_Level_3__c = discountMaxLevel3ByProduct.get(productId));
            productsToUpdate.add(product);
        }
        
        // Try to update the Products
        try{
            Update productsToUpdate;
        }
        catch(DmlException exc){
            System.debug('>>>> <!ERROR!> DiscountWorkflowUtils.updateProductsWithNewMaxDiscounts Failed Update <!ERROR!>' + exc.getMessage());
        }
    }
}