/**
 * @description       : 
 * @author            : keshav Matabadul
 * @group             : 
 * @last modified on  : 11-30-2021
 * @last modified by  : keshav Matabadul
**/
@isTest
public with sharing class SM024_ProductSLP_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static final String PRIMARY_CONTACT_EMAIL = 'primarycontact@email.com';

    @testSetup static void setup(){
        System.runAs(adminUser){ 

            List<Product2> listProduct = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List')
            };
            insert listProduct;
            // for(Product2 p:listProduct){
            //     p.Sales_Channel__c = 'Store/CPQ';
            // }
            // insert listProduct;

            //PriceBook
            PriceBook2 standardPricebook = new UTIL_TestFactory.PricebookFactory().activateStdPriceBook();               
            update standardPricebook;

            //Create Pricebook Entry
            List<PricebookEntry> listPBE = new List<PricebookEntry>{
                new UTIL_TestFactory.PricebookFactory().createPriceBookEntry(standardPricebook.Id, listProduct[0].id)
            };
            insert listPBE;

             //create Discount Schedule
            List<SBQQ__DiscountSchedule__c> listDiscountSCH = new List<SBQQ__DiscountSchedule__c>{
                new UTIL_TestFactory.DiscountSchFactory().createDiscountSch('Range','Percentage')
            };
            insert listDiscountSCH;

            Service_Level_Price__c slp = new UTIL_TestFactory.ServiceLevelPriceFactory().createServiceLevelPrice(listProduct[0].Id,standardPricebook.Id,'List Pricing',listDiscountSCH[0].Id);
            slp.Default__c =true;
            insert slp;
        }
    }

    @isTest static void testServiceLevelUpdate(){
        System.runAs(adminUser){
           
            Test.startTest();
            try{
                product2 pro = [Select Id from Product2 limit 1];
            pro.Sales_Channel__c = 'Store/CPQ';
            update pro;
            }catch(exception e){
                
            }
            
            Test.stopTest();
        }
        
    }

    @isTest static void testServiceLevelInsert(){
        System.runAs(adminUser){
           
            Test.startTest();

            try{
                List<Product2> listProduct = new List<Product2>{
                    new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List')
                };
                listProduct[0].Sales_Channel__c = 'Store/CPQ';
            }catch(exception e){
                
            }
            
            Test.stopTest();
        }
        
    }

}