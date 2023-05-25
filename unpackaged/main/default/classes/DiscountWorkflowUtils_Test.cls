@isTest
public class DiscountWorkflowUtils_Test{

    // Method to create a Product
    private static Product2 createProduct(){
        RecordType productRecordType = [Select Id
                                        From RecordType
                                        Where DeveloperName = 'Product'];
        
        Product2 prod = new Product2(Name = 'productTest1',
                                     Marketing_Status__c = 'Non-marketable',
                                     Service_Levels__c = 'C30',
                                     IsActive = true,
                                     Possible_Billing_Modes__c = 'Consumption',
                                     ShortDescription__c = 'Test DESC',
                                     SBQQ__ChargeType__c = 'One-Time',
                                     RecordTypeId = productRecordType.Id);
        Insert prod;
        return prod;
    }

	// Method to obtain a list of 3 Transversal Themes
    private static List<Transversal_Theme__c> createTransversalThemeList(Product2 prod){
        Map<String,List<String>> dependenciesMapDiscountLvl2 = DependentPicklistUtils.getFieldDependencies('Transversal_Theme__c', 'Transversal_Theme__c', 
                                                                                        'Discount_Max_Level_2__c');
        System.debug('>>>>> DiscountWorkflowUtils_Test.createTransversalThemeList dependenciesMapDiscountLvl2 = ' + dependenciesMapDiscountLvl2);
        Map<String,List<String>> dependenciesMapDiscountLvl3 = DependentPicklistUtils.getFieldDependencies('Transversal_Theme__c','Transversal_Theme__c', 
                                                                                        'Discount_Max_Level_3__c');
        System.debug('>>>>> DiscountWorkflowUtils_Test.createTransversalThemeList dependenciesMapDiscountLvl3 = ' + dependenciesMapDiscountLvl3);
        
        List<Transversal_Theme__c> transThemeList = new List<Transversal_Theme__c>();
        List<String> controllingValues = new List<String>(dependenciesMapDiscountLvl2.keySet());
        Integer i = 0;
        while(transThemeList.size() <= 3 && i < controllingValues.size()){
            Boolean valueHasDiscountLvl2 = !dependenciesMapDiscountLvl2.get(controllingValues[i]).isEmpty();
            Boolean valueHasDiscountLvl3 = !dependenciesMapDiscountLvl3.get(controllingValues[i]).isEmpty();
            if(valueHasDiscountLvl2 && valueHasDiscountLvl3){
                Transversal_Theme__c theme = new Transversal_Theme__c(Product__c = prod.Id,
                                                                      Transversal_Theme__c = controllingValues[i],
                                                                      Discount_Max_Level_2__c = dependenciesMapDiscountLvl2.get(controllingValues[i])[0],
                                                                      Discount_Max_Level_3__c = dependenciesMapDiscountLvl3.get(controllingValues[i])[0]);
                transThemeList.add(theme);
            }
            i++;
        }                
		
        System.debug('>>>>> DiscountWorkflowUtils_Test.createTransversalThemeList transThemeList = ' + transThemeList);
      	return transThemeList;
    }
    
    // Will execute first, before all other tests methods 
    // Each test method will get access to the original unmodified state of those records
    @testSetup 
    static void setup(){
        // Invoke method to create a Product without Transversal Themes
        Product2 product = createProduct();
        
        // Invoke methods that will create a Product and linked Transversal Themes
        Product2 product2 = createProduct();
        List<Transversal_Theme__c> transThemeList = createTransversalThemeList(product2);
        Try{
            Insert transThemeList;
        }
        Catch(DmlException exc){
            System.debug('>>>>> [ERROR] DiscountWorkflowUtils_Test.setup DMLException = ' + exc);
        }
    }
    
    @isTest 
    static void testTransversalThemeInsertion(){
        // Retrieve the inserted Product
        Product2 prod = [Select Id 
                         From Product2
                         Where Transversal_Theme_Discount_Max_Level_2__c = NULL
                         And Transversal_Theme_Discount_Max_Level_3__c = NULL];
        
        // Invoke the method to generate a list of Transversal Theme
        List<Transversal_Theme__c> transThemeList = createTransversalThemeList(prod);
        
        // Insert the List
        Try{
            Insert transThemeList;
        }
        Catch(DmlException exc){
            System.debug('>>>>> [ERROR] DiscountWorkflowUtils_Test.testTransversalThemeInsertion DMLException = ' + exc);
        }
        
        // Get the updated Product
        Product2 updatedProd = [Select Id, Transversal_Theme_Discount_Max_Level_2__c, 
                                Transversal_Theme_Discount_Max_Level_3__c 
                                From Product2
                                Where Id = :prod.Id];
        System.debug('>>>>> DiscountWorkflowUtils_Test.testTransversalThemeInsertion updatedProd = ' + updatedProd);
        
        // Check that the Product has been correctly updated
        Integer expectedDiscountMaxLvl2 = 100;
        Integer expectedDiscountMaxLvl3 = 100;
        for(Transversal_Theme__c theme : transThemeList){
            Integer themeDiscountMaxLvl2 = Integer.valueOf(theme.Discount_Max_Level_2__c);
            Integer themeDiscountMaxLvl3 = Integer.valueOf(theme.Discount_Max_Level_3__c);
            if(themeDiscountMaxLvl2 < expectedDiscountMaxLvl2){
                expectedDiscountMaxLvl2 = themeDiscountMaxLvl2;
            }
            if(themeDiscountMaxLvl3 < expectedDiscountMaxLvl3){
                expectedDiscountMaxLvl3 = themeDiscountMaxLvl3;
            }
        }
        System.debug('>>>>> DiscountWorkflowUtils_Test.testTransversalThemeInsertion expectedDiscountMaxLvl2 = ' + expectedDiscountMaxLvl2);
        System.debug('>>>>> DiscountWorkflowUtils_Test.testTransversalThemeInsertion expectedDiscountMaxLvl3 = ' + expectedDiscountMaxLvl3);
        
        System.assertEquals(expectedDiscountMaxLvl2, Integer.valueOf(updatedProd.Transversal_Theme_Discount_Max_Level_2__c));
        System.assertEquals(expectedDiscountMaxLvl3, Integer.valueOf(updatedProd.Transversal_Theme_Discount_Max_Level_3__c));
    }
    
    @isTest 
    static void testTransversalThemePartialDeletion(){
       // Retrieve the inserted Product with Transversal Themes
        Product2 prod = [Select Id 
                         From Product2
                         Where Transversal_Theme_Discount_Max_Level_2__c != NULL
                         And Transversal_Theme_Discount_Max_Level_3__c != NULL];
        
        // Retrieve the inserted Transverse Themes and remove one Theme from the List, the others will be deleted
        List<Transversal_Theme__c> transThemeList = [Select Id, Discount_Max_Level_2__c, Discount_Max_Level_3__c 
                                                     From Transversal_Theme__c
                                                     Where Product__c = :prod.Id];
        Transversal_Theme__c lastTheme = transThemeList.remove(0);
        
        // Delete the List
        try{
            Delete transThemeList;
        }
        catch(DmlException exc){
            System.debug('>>>>> [ERROR] DiscountWorkflowUtils_Test.testTransversalThemePartialDeletion DMLException = ' + exc);
        }
        
        // Get the updated Product
        Product2 updatedProd = [Select Id, Transversal_Theme_Discount_Max_Level_2__c, 
                                Transversal_Theme_Discount_Max_Level_3__c 
                                From Product2
                                Where Id = :prod.Id];
        System.debug('>>>>> DiscountWorkflowUtils_Test.testTransversalThemePartialDeletion updatedProd = ' + updatedProd);
        
        // Check that the Product has been correctly updated
        System.assertEquals(lastTheme.Discount_Max_Level_2__c, updatedProd.Transversal_Theme_Discount_Max_Level_2__c);
        System.assertEquals(lastTheme.Discount_Max_Level_3__c, updatedProd.Transversal_Theme_Discount_Max_Level_3__c); 
    }
    
    @isTest 
    static void testTransversalThemeFullDeletion(){
       // Retrieve the inserted Product with Transversal Themes
        Product2 prod = [Select Id 
                         From Product2
                         Where Transversal_Theme_Discount_Max_Level_2__c != NULL
                         And Transversal_Theme_Discount_Max_Level_3__c != NULL];
        
        // Retrieve the inserted Transverse Themes
        List<Transversal_Theme__c> transThemeList = [Select Id 
                                                     From Transversal_Theme__c
                                                     Where Product__c = :prod.Id];
        
        // Delete the List
        try{
            Delete transThemeList;
        }
        catch(DmlException exc){
            System.debug('>>>>> [ERROR] DiscountWorkflowUtils_Test.testTransversalThemeFullDeletion DMLException = ' + exc);
        }
        
        // Get the updated Product
        Product2 updatedProd = [Select Id, Transversal_Theme_Discount_Max_Level_2__c, 
                                Transversal_Theme_Discount_Max_Level_3__c 
                                From Product2
                                Where Id = :prod.Id];
        System.debug('>>>>> DiscountWorkflowUtils_Test.testTransversalThemeFullDeletion updatedProd = ' + updatedProd);
        
        // Check that the Product has been correctly updated
        System.assertEquals(null, updatedProd.Transversal_Theme_Discount_Max_Level_2__c);
        System.assertEquals(null, updatedProd.Transversal_Theme_Discount_Max_Level_3__c); 
    }
}