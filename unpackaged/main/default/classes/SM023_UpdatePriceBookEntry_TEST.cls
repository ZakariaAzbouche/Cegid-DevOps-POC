/**
 * @description       : 
 * @author            : keshav Matabadul
 * @group             : 
 * @last modified on  : 11-29-2021
 * @last modified by  : keshav Matabadul
**/
@isTest
public with sharing class SM023_UpdatePriceBookEntry_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();

    @testSetup static void setup(){
        System.runAs(adminUser){ 
            //create product2
            List<Product2> listProduct = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List')
            };
            for(Product2 p:listProduct){
                p.Sales_Channel__c = 'Store/CPQ';
            }
            insert listProduct;

            //Get pricebook
            Pricebook2 priceBookId = new UTIL_TestFactory.PricebookFactory().activateStdPriceBook();
            update priceBookId;

            //Create Pricebook Entry
            List<PricebookEntry> listPBE = new List<PricebookEntry>{
                new UTIL_TestFactory.PricebookFactory().createPriceBookEntry(priceBookId.Id, listProduct[0].id)
            };
            insert listPBE;

             //create Discount Schedule
            List<SBQQ__DiscountSchedule__c> listDiscountSCH = new List<SBQQ__DiscountSchedule__c>{
                new UTIL_TestFactory.DiscountSchFactory().createDiscountSch('Range','Percentage')
            };
            insert listDiscountSCH;

            Service_Level_Price__c slp = new UTIL_TestFactory.ServiceLevelPriceFactory().createServiceLevelPrice(listProduct[0].Id,priceBookId.Id,'List Pricing',listDiscountSCH[0].Id);
            slp.Default__c =true;
            insert slp;

            BypassTrigger__c bt= new BypassTrigger__c(
                Activatetrigger__c = true,
                SetupOwnerId = UserInfo.getOrganizationId()
            );

            insert bt;
            
        }
    }

    @isTest static void testServiceLevelInsert(){
        System.runAs(adminUser){
            product2 pro = [Select Id from Product2 WHERE Sales_Channel__c = 'Store/CPQ' limit 1];
            //Get pricebook
            Id priceBookId = [SELECT Id FROM Pricebook2].Id;
            SBQQ__DiscountSchedule__c discountSch = [Select Id from SBQQ__DiscountSchedule__c limit 1];
            Test.startTest();
            Service_Level_Price__c slp = new UTIL_TestFactory.ServiceLevelPriceFactory().createServiceLevelPrice(pro.Id,priceBookId,'List Pricing',discountSch.Id);
            slp.Default__c =true;
            insert slp;
            Test.stopTest();
        }
        
    }

    @isTest static void testServiceLevelDelete(){
        System.runAs(adminUser){
            Service_Level_Price__c slp = [SELECT Id,Default__c FROM Service_Level_Price__c WHERE Default__c = true limit 1];
            slp.Default__c = false;
            Test.startTest();
            update slp;
            Test.stopTest();
        }
        
    }
}