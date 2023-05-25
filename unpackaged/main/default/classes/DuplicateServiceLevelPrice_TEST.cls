/**
 * @description       : Test for Class: DuplicateServiceLevelPrice
 * @author            : Ratish ISURI
 * @group             : Comforth-Karoo
 * @created date 	  :	2022-09-23
 * @last modified on  : 2022-09-23
 * @last modified by  : Ratish ISURI
**/
@isTest
private class DuplicateServiceLevelPrice_TEST {
    
    @TestSetup
    static void makeData(){
        
        //create std pricebook
        PriceBook2 standardPricebook = new UTIL_TestFactory.PricebookFactory().activateStdPriceBook();
        
        User u = new UTIL_TestFactory.UserFactory().createUserCegidSales();
        insert u;
        User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
        System.runAs(adminUser){ 
            Entity__c  cegidEntity =  new UTIL_TestFactory.EntityFactory().createEntity();
            insert    cegidEntity;  
            
            Pricebook2 priceBook = new Pricebook2(
            Name = 'Example Price Book',
            Description = 'This is the Price Book description.',
            IsActive = true,
            Cegid_Entity__c = cegidEntity.Id,
            Currency__c = 'EUR'
            );
            insert priceBook;
              
            //create product2
            List<Product2> listProduct = new List<Product2>();
            
            Product2 prod = new UTIL_TestFactory.ProductFactory().createProduct('Article', 'List');
            prod.currencyIsoCode = 'EUR';
            listProduct.add(prod);

            Product2 prod2 = new UTIL_TestFactory.ProductFactory().createProduct('Article', 'Block');
            prod2.currencyIsoCode = 'EUR';
            listProduct.add(prod2);
            
            insert listProduct;
            
            // insert pbe with standard pb
            List<PricebookEntry> listPBE = new List<PricebookEntry>();
            for(Integer i=0; i<2;i++ ){
                PricebookEntry pbe = new UTIL_TestFactory.PricebookFactory().createPriceBookEntry(standardPricebook.id, listProduct[i].id);
                pbe.CurrencyIsoCode = 'EUR';
                listPBE.add(pbe);
            }
            insert listPBE;
            
            //insert  pbe with custom pb
            PricebookEntry pbe = new UTIL_TestFactory.PricebookFactory().createPriceBookEntry(pricebook.id, listProduct[1].id);
            pbe.CurrencyIsoCode = 'EUR';
            listPBE.add(pbe);
            insert listPBE[2];
        } 
    }

    @IsTest
    static void testWithStdPBAndRTList(){
        PricebookEntry PE = [SELECT Pricebook2Id, Product2Id FROM PricebookEntry WHERE Product2.SBQQ__PricingMethod__c = 'List' LIMIT 1];

        DuplicateServiceLevelPrice.flowInputs inputs = new DuplicateServiceLevelPrice.flowInputs();
        inputs.objServiceLevelPrice = new UTIL_TestFactory.ServiceLevelPriceFactory().createServiceLevelPrice(
                                                                PE.Product2Id,
                                                                PE.Pricebook2Id, 
                                                                'List Pricing',
                                                                new UTIL_TestFactory.DiscountSchFactory().createDiscountSch('Range','Percentage').Id 
                                                                );
        inputs.objServiceLevelPrice.Lower_Bound__c = 10.00;
        inputs.objServiceLevelPrice.Upper_Bound__c = 20.00;
        inputs.objServiceLevelPrice.Sales_Purposes__c += ';111';
        inputs.productRT = 'Article';


        List<DuplicateServiceLevelPrice.flowInputs> inputVariables = new List<DuplicateServiceLevelPrice.flowInputs>();
        inputVariables.add(inputs);
       

        // Assert data does not exist before execution
        Integer numOfSLPBeforeExecute = [SELECT COUNT() FROM Service_Level_Price__c];
        System.assertEquals(0, numOfSLPBeforeExecute, 'Num of SLP should be 0 before execution');

        User contextuser = [SELECT Id FROM User WHERE UserName LIKE 'test.sales%'];
        
        Test.startTest();
        System.runAs(contextuser){
            DuplicateServiceLevelPrice.CreateServiceLevelPrice(inputVariables);
        }
        Test.stopTest();
     
        // 1 SLP for each sales purpose
        Integer numOfSLPAfterExecute = [SELECT COUNT() FROM Service_Level_Price__c];
        System.assertEquals(2, numOfSLPAfterExecute, 'Num of SLP should be 2 after execution');

    }

    @IsTest
    static void testWithCustomPBAndRTBlock(){
        PricebookEntry PE = [SELECT Pricebook2Id, Product2Id FROM PricebookEntry WHERE Product2.SBQQ__PricingMethod__c = 'Block' AND Pricebook2.IsStandard = FALSE LIMIT 1];
        
        User contextuser = [SELECT Id FROM User WHERE UserName LIKE 'test.sales%'];

        
        DuplicateServiceLevelPrice.flowInputs inputs = new DuplicateServiceLevelPrice.flowInputs();
        inputs.objServiceLevelPrice = new UTIL_TestFactory.ServiceLevelPriceFactory().createServiceLevelPrice(
                                                                PE.Product2Id,
                                                                PE.Pricebook2Id,
                                                                'Block Pricing',
                                                                new UTIL_TestFactory.DiscountSchFactory().createDiscountSch('Range','Percentage').Id
                                                                );
        inputs.objServiceLevelPrice.Lower_Bound__c = 10.00;
        inputs.objServiceLevelPrice.Upper_Bound__c = 20.00;
        inputs.productRT = 'Block';

        List<DuplicateServiceLevelPrice.flowInputs> inputVariables = new List<DuplicateServiceLevelPrice.flowInputs>();
        inputVariables.add(inputs);

        // Assert data does not exist before execution
        Integer numOfSLPBeforeExecute = [SELECT COUNT() FROM Service_Level_Price__c];
        System.assertEquals(0, numOfSLPBeforeExecute, 'Num of SLP should be 0 before execution');

        Test.startTest();
        System.runAs(contextuser){
            DuplicateServiceLevelPrice.CreateServiceLevelPrice(inputVariables);
        }
        Test.stopTest();

        Integer numOfSLPAfterExecute = [SELECT COUNT() FROM Service_Level_Price__c];
        System.assertEquals(1, numOfSLPAfterExecute, 'Num of SLP should be 1 after execution');

        
    }
}