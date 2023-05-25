/**
* @author Keshav M - Comforth
* @date 2021-07-05
* @description SM021_UpdateServiceLevelPrice_TEST          
*/
@isTest
public class SM021_UpdateServiceLevelPrice_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static final String PRIMARY_CONTACT_EMAIL = 'primarycontact@email.com';
    @testSetup static void setup(){
        System.runAs(adminUser){ 
            Insert new BypassTrigger__c(SetupOwnerId = UserInfo.getOrganizationId(), Activatetrigger__c = True);
            Test.startTest();

            List<Product_Line__c> listProductLine = new List<Product_Line__c>{
                new UTIL_TestFactory.ProductLineFactory().createProductLinePrice('ProductLineTest', 'tyhjy')
           };
           insert listProductLine;

           //Entity
            Entity__c entity = new Entity__c(
            Active__c = true,
            name ='CEGID SA',
            ICS__c = 'FR14ZZZ497659',
            Street__c = '52, quai Sedallian',
            City__c = 'Lyon',
            Postal_Code__c = '69009',
            Country__c = 'France'
            );
            insert entity;

            //PriceBook
            Pricebook2 customPB = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true, Cegid_Entity__c = entity.Id );
            insert customPB;

            Pricebook2 customPBv2 = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true, Cegid_Entity__c = entity.Id );
            insert customPBv2;

            
            PriceBook2 standardPricebook = new UTIL_TestFactory.PricebookFactory().activateStdPriceBook();
            
            //create product2
            List<Product2> listProduct = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'Cost'),
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'Cost'),
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'Cost')
            };

            listProduct[2].Product_Line__c = listProductLine[0].Id;
            listProduct[2].Name = 'Test Product line ';
            insert listProduct;

            system.debug('listProduct '+ listProduct[2]);
            
            List<PricebookEntry> listPBE = new List<PricebookEntry>{
                new UTIL_TestFactory.PricebookFactory().createPriceBookEntry(standardPricebook.id, listProduct[0].id),
                new UTIL_TestFactory.PricebookFactory().createPriceBookEntry(standardPricebook.id, listProduct[2].id)
            };
            insert listPBE; 

            List<PricebookEntry> listPBECustomPriceBook = new List<PricebookEntry>{
                new UTIL_TestFactory.PricebookFactory().createPriceBookEntry(customPB.id, listProduct[2].id),
                new UTIL_TestFactory.PricebookFactory().createPriceBookEntry(customPBv2.id, listProduct[2].id)
            };
            insert listPBECustomPriceBook; 
            
            //create Discount Schedule
            List<SBQQ__DiscountSchedule__c> listDiscountSCH = new List<SBQQ__DiscountSchedule__c>{
                new UTIL_TestFactory.DiscountSchFactory().createDiscountSch('Range','Percentage'),
                new UTIL_TestFactory.DiscountSchFactory().createDiscountSch('Range','Percentage'),
                new UTIL_TestFactory.DiscountSchFactory().createDiscountSch('Range','Percentage'),
                new UTIL_TestFactory.DiscountSchFactory().createDiscountSch('Range','Percentage'),
                new UTIL_TestFactory.DiscountSchFactory().createDiscountSch('Range','Percentage'),
                new UTIL_TestFactory.DiscountSchFactory().createDiscountSch('Range','Percentage'),
                new UTIL_TestFactory.DiscountSchFactory().createDiscountSch('Range','Percentage')
            };
            insert listDiscountSCH;
            
            //Create SLP
            Service_Level_Price__c slp = new UTIL_TestFactory.ServiceLevelPriceFactory().createServiceLevelPrice(listProduct[0].Id,standardPricebook.Id,'List Pricing',listDiscountSCH[0].Id);
            insert slp;
            Test.stopTest();
        }
    }
    
    static testMethod void testServiceLevelInsert(){
        product2 pro = [Select Id from Product2 limit 1];
        PriceBook2 priceBook = [Select Id from PriceBook2 limit 1];
        SBQQ__DiscountSchedule__c discountSch = [Select Id from SBQQ__DiscountSchedule__c limit 1];
        Service_Level_Price__c slp = new UTIL_TestFactory.ServiceLevelPriceFactory().createServiceLevelPrice(pro.Id,priceBook.Id,'List Pricing',discountSch.Id);
        insert slp;
    }
    
    static testMethod void testServiceLevelDelete(){        
        Service_Level_Price__c slp = [SELECT Id from Service_Level_Price__c Limit 1];
        delete slp;
    }

    @isTest static void testProductLine(){
        System.runAs(adminUser){
            product2  pro= [SELECT id FROM Product2 WHERE Name='Test Product line' limit 1]; 
            Pricebook2 pb = [SELECT id FROM pricebook2 WHERE name = 'Standard Price Book 2009' limit 1];
            SBQQ__DiscountSchedule__c discount = [SELECT id FROM SBQQ__DiscountSchedule__c limit 1];
            Test.startTest();
            Service_Level_Price__c slp = new UTIL_TestFactory.ServiceLevelPriceFactory().createServiceLevelPrice(pro.Id,pb.Id,'List Pricing',discount.Id);
            insert slp;
            Test.stopTest();
        }
        
    }
}