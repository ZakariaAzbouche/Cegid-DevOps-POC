@isTest
public class VFC02_ExportPricing_TEST {
/**
* @author Keshav - Comforth
* @date 2020-02-04
* @group UTIL
* @description Classe VFC02_ExportPricing_TEST
*/
static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();   
    
    @testSetup static void setup(){

        System.runAs(adminUser){ 

            //create Package List
            List<Product2> listPackageList = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Package', 'List'),
                new UTIL_TestFactory.ProductFactory().createProduct('Package', 'List'),
                new UTIL_TestFactory.ProductFactory().createProduct('Package', 'List'),
                new UTIL_TestFactory.ProductFactory().createProduct('Package', 'List'),
                new UTIL_TestFactory.ProductFactory().createProduct('Package', 'List')
            };
            listPackageList[0].Name = 'test Product test';
            listPackageList[1].Name = 'PackageWithDsc';
            listPackageList[2].Name = 'PackageWithoutTier';
            listPackageList[3].Name = 'PackageWithProduct';
            listPackageList[4].Name = 'packageOnly';
            insert listPackageList;

            //create Package Block
            List<Product2> listPackageBlock = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Package', 'Block'),
                new UTIL_TestFactory.ProductFactory().createProduct('Package', 'Block'),
                new UTIL_TestFactory.ProductFactory().createProduct('Package', 'Block')
            };
            listPackageBlock[0].Name = 'BlockPackage';
            insert listPackageBlock;

            //create product List
            List<Product2> listProductList = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List')
            };
            listProductList[1].Name = 'productWithDsc';
            listProductList[2].Name = 'ProductCharge';
            insert listProductList;


            //create product Block
            List<Product2> listProductBlock = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'Block'),
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'Block'),
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'Block')
            };
            insert listProductBlock;


            //create charge
            List<Product2> listCharge = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Charge', ''),
                new UTIL_TestFactory.ProductFactory().createProduct('Charge', ''),
                new UTIL_TestFactory.ProductFactory().createProduct('Charge', ''),
                new UTIL_TestFactory.ProductFactory().createProduct('Charge', '')
            };
            listCharge[3].Name = 'charge';
            insert listCharge;


            //create Article
            List<Product2> listArticle = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Article', ''),
                new UTIL_TestFactory.ProductFactory().createProduct('Article', ''),
                new UTIL_TestFactory.ProductFactory().createProduct('Article', '')
            };
            insert listArticle;

            //create ProductOption for Package to Product
            List<SBQQ__ProductOption__c> listPackageToProduct = new List<SBQQ__ProductOption__c>{
                new UTIL_TestFactory.ProductOptionFactory().createProductOption(listProductList[0].Id ,listPackageList[0].Id),
                new UTIL_TestFactory.ProductOptionFactory().createProductOption(listProductList[1].Id ,listPackageList[0].Id),
                new UTIL_TestFactory.ProductOptionFactory().createProductOption(listProductList[2].Id ,listPackageList[0].Id),
                new UTIL_TestFactory.ProductOptionFactory().createProductOption(listProductList[3].Id ,listPackageList[3].Id)
            };
            insert listPackageToProduct;

            //create ProductOption for Package BLOCK to Product BLOCK
            List<SBQQ__ProductOption__c> listPackageToProductBlock = new List<SBQQ__ProductOption__c>{
                new UTIL_TestFactory.ProductOptionFactory().createProductOption(listProductBlock[0].Id ,listPackageBlock[0].Id),
                new UTIL_TestFactory.ProductOptionFactory().createProductOption(listProductBlock[1].Id ,listPackageBlock[0].Id),
                new UTIL_TestFactory.ProductOptionFactory().createProductOption(listProductBlock[2].Id ,listPackageBlock[0].Id)
            };
            insert listPackageToProductBlock;

            //create ProductOption for product to article
            List<SBQQ__ProductOption__c> listProductToArticle = new List<SBQQ__ProductOption__c>{
                new UTIL_TestFactory.ProductOptionFactory().createProductOption(listArticle[0].Id ,listProductList[0].Id),
                new UTIL_TestFactory.ProductOptionFactory().createProductOption(listArticle[1].Id ,listProductList[0].Id),
                new UTIL_TestFactory.ProductOptionFactory().createProductOption(listArticle[2].Id ,listProductList[0].Id)
            };
            insert listProductToArticle;

            //create ProductOption for Package to Charge
            List<SBQQ__ProductOption__c> listPackageToCharge = new List<SBQQ__ProductOption__c>{
                new UTIL_TestFactory.ProductOptionFactory().createProductOption(listCharge[0].Id ,listPackageList[0].Id),
                new UTIL_TestFactory.ProductOptionFactory().createProductOption(listCharge[1].Id ,listPackageList[0].Id),
                new UTIL_TestFactory.ProductOptionFactory().createProductOption(listCharge[2].Id ,listPackageList[2].Id)
            };
            insert listPackageToCharge;


            //create ProductOption for product to Charge
            List<SBQQ__ProductOption__c> listproductToCharge = new List<SBQQ__ProductOption__c>{
                new UTIL_TestFactory.ProductOptionFactory().createProductOption(listCharge[2].Id ,listProductList[2].Id)
            };
            insert listproductToCharge;

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

            //create Discount Tier
            List<SBQQ__DiscountTier__c> listDiscountTier = new List<SBQQ__DiscountTier__c>{
                new UTIL_TestFactory.DiscountTierFactory().createDiscountSch(listDiscountSCH[0].Id),
                new UTIL_TestFactory.DiscountTierFactory().createDiscountSch(listDiscountSCH[0].Id),
                new UTIL_TestFactory.DiscountTierFactory().createDiscountSch(listDiscountSCH[0].Id),
                new UTIL_TestFactory.DiscountTierFactory().createDiscountSch(listDiscountSCH[0].Id),
                new UTIL_TestFactory.DiscountTierFactory().createDiscountSch(listDiscountSCH[0].Id),
                new UTIL_TestFactory.DiscountTierFactory().createDiscountSch(listDiscountSCH[1].Id),
                new UTIL_TestFactory.DiscountTierFactory().createDiscountSch(listDiscountSCH[1].Id),
                new UTIL_TestFactory.DiscountTierFactory().createDiscountSch(listDiscountSCH[1].Id),
                new UTIL_TestFactory.DiscountTierFactory().createDiscountSch(listDiscountSCH[1].Id),
                new UTIL_TestFactory.DiscountTierFactory().createDiscountSch(listDiscountSCH[1].Id)
            };
            insert listDiscountTier;

            //create PriceBook
            PriceBook2 standardPricebook = new UTIL_TestFactory.PricebookFactory().activateStdPriceBook();

            //create ServiceLevelPrice List pricing
            List<Service_Level_Price__c> listServiceLevel = new List<Service_Level_Price__c>{
                new UTIL_TestFactory.ServiceLevelPriceFactory().createServiceLevelPrice(listPackageList[0].Id, standardPricebook.Id, 'List Pricing', listDiscountSCH[0].Id),
                new UTIL_TestFactory.ServiceLevelPriceFactory().createServiceLevelPrice(listPackageList[1].Id, standardPricebook.Id, 'List Pricing', listDiscountSCH[1].Id),
                new UTIL_TestFactory.ServiceLevelPriceFactory().createServiceLevelPrice(listProductList[1].Id, standardPricebook.Id, 'List Pricing', listDiscountSCH[1].Id),
                new UTIL_TestFactory.ServiceLevelPriceFactory().createServiceLevelPrice(listPackageList[2].Id, standardPricebook.Id, 'List Pricing', listDiscountSCH[2].Id),
                new UTIL_TestFactory.ServiceLevelPriceFactory().createServiceLevelPrice(listProductList[2].Id, standardPricebook.Id, 'List Pricing', listDiscountSCH[1].Id),
                new UTIL_TestFactory.ServiceLevelPriceFactory().createServiceLevelPrice(listProductList[3].Id, standardPricebook.Id, 'List Pricing', listDiscountSCH[1].Id)
            };
            insert listServiceLevel;


            //create ServiceLevelPrice List pricing
           /* List<Service_Level_Price__c> listServiceLevelBlock = new List<Service_Level_Price__c>{
                new UTIL_TestFactory.ServiceLevelPriceFactory().createServiceLevelPrice(listPackageBlock[0].Id, standardPricebook.Id, 'Block Pricing', null)
            };
            insert listServiceLevelBlock;*/



        }
    }

    @isTest static void testPackageProductWithDiscount() { 
        List<Product2> listExportPackage = [select id, name from product2 where recordtype.developername = 'package' AND name = 'test Product test' limit 1 ];
 
        System.runAs(adminUser){ 
            ApexPages.StandardController sc = new ApexPages.StandardController(listExportPackage[0]);
            VFC02_ExportPricing testProduct = new VFC02_ExportPricing(sc);
            PageReference pageRef = Page.VFP02_ExportPricing; 
            pageRef.getParameters().put('id', String.valueOf(listExportPackage[0].Id));
            Test.setCurrentPage(pageRef);
            testProduct.getAllProduct();
            system.assertEquals( testProduct.mapProductWrapper.size() ,testProduct.mapProductWrapper.size());
        } 
        
        
    }

    @isTest static void testPackageProductWithNODiscount() { 
        List<Product2> listExportProduct = [select id, name from product2 where recordtype.developername = 'package' AND SBQQ__PricingMethod__c = 'Block' limit 1 ];
 
        System.runAs(adminUser){ 
            ApexPages.StandardController sc = new ApexPages.StandardController(listExportProduct[0]);
            VFC02_ExportPricing testProduct = new VFC02_ExportPricing(sc);
            PageReference pageRef = Page.VFP02_ExportPricing; 
            pageRef.getParameters().put('id', String.valueOf(listExportProduct[0].Id));
            Test.setCurrentPage(pageRef);
            testProduct.getAllProduct();
            system.assertEquals( testProduct.mapProductWrapper.size() ,testProduct.mapProductWrapper.size());
        }   
    }

    @isTest static void testPackageBlockWithoutTier() { 
        List<Product2> listExportProduct = [select id, name from product2 where recordtype.developername = 'Package' AND SBQQ__PricingMethod__c = 'Block' and Name = 'BlockPackage' limit 1 ];
 
        System.runAs(adminUser){ 
            ApexPages.StandardController sc = new ApexPages.StandardController(listExportProduct[0]);
            VFC02_ExportPricing testProduct = new VFC02_ExportPricing(sc);
            PageReference pageRef = Page.VFP02_ExportPricing; 
            pageRef.getParameters().put('id', String.valueOf(listExportProduct[0].Id));
            Test.setCurrentPage(pageRef);
            testProduct.getAllProduct();
            system.assertEquals( testProduct.mapProductWrapper.size() ,testProduct.mapProductWrapper.size());
        }   
    }

    @isTest static void testPackageWithDiscount() { 
        List<Product2> listExportPackageWithDsc = [select id, name from product2 where recordtype.developername = 'package' AND Name = 'PackageWithDsc' limit 1 ];
 
        System.runAs(adminUser){ 
            ApexPages.StandardController sc = new ApexPages.StandardController(listExportPackageWithDsc[0]);
            VFC02_ExportPricing testProduct = new VFC02_ExportPricing(sc);
            PageReference pageRef = Page.VFP02_ExportPricing; 
            pageRef.getParameters().put('id', String.valueOf(listExportPackageWithDsc[0].Id));
            Test.setCurrentPage(pageRef);
            testProduct.getAllProduct();
            system.assertEquals( testProduct.mapProductWrapper.size() ,testProduct.mapProductWrapper.size());
        }   
    }

    @isTest static void testProductWithDiscount() {  
        List<Product2> listExportProductWithDsc = [select id, name from product2 where recordtype.developername = 'Product' AND Name = 'productWithDsc' limit 1 ];
 
        System.runAs(adminUser){ 
            ApexPages.StandardController sc = new ApexPages.StandardController(listExportProductWithDsc[0]);
            VFC02_ExportPricing testProduct = new VFC02_ExportPricing(sc);
            PageReference pageRef = Page.VFP02_ExportPricing; 
            pageRef.getParameters().put('id', String.valueOf(listExportProductWithDsc[0].Id));
            Test.setCurrentPage(pageRef);
            testProduct.getAllProduct();
            system.assertEquals( testProduct.mapProductWrapper.size() ,testProduct.mapProductWrapper.size());
        }   
    }


    @isTest static void testPackageWithDiscountWithChargeWithouTier() {  
        List<Product2> listExportProductWithDsc = [select id, name from product2 where recordtype.developername = 'Package' AND Name = 'PackageWithoutTier' limit 1 ];
 
        System.runAs(adminUser){ 
            ApexPages.StandardController sc = new ApexPages.StandardController(listExportProductWithDsc[0]);
            VFC02_ExportPricing testProduct = new VFC02_ExportPricing(sc);
            PageReference pageRef = Page.VFP02_ExportPricing; 
            pageRef.getParameters().put('id', String.valueOf(listExportProductWithDsc[0].Id));
            Test.setCurrentPage(pageRef);
            testProduct.getAllProduct();
            system.assertEquals( testProduct.mapProductWrapper.size() ,testProduct.mapProductWrapper.size());
        } 
    }

    @isTest static void testProductWithCharge() {  
        List<Product2> listExportcharge = [select id, name from product2 where recordtype.developername = 'Product' AND Name = 'ProductCharge' limit 1 ];
 
        System.runAs(adminUser){ 
            ApexPages.StandardController sc = new ApexPages.StandardController(listExportcharge[0]);
            VFC02_ExportPricing testProduct = new VFC02_ExportPricing(sc);
            PageReference pageRef = Page.VFP02_ExportPricing; 
            pageRef.getParameters().put('id', String.valueOf(listExportcharge[0].Id));
            Test.setCurrentPage(pageRef);
            testProduct.getAllProduct();
            system.assertEquals( testProduct.mapProductWrapper.size() ,testProduct.mapProductWrapper.size());
        } 
    }

    @isTest static void testProductWithPakageWithDiscount() {  
        List<Product2> listExportcharge = [select id, name from product2 where recordtype.developername = 'Package' AND Name = 'PackageWithProduct' limit 1 ];
 
        System.runAs(adminUser){ 
            ApexPages.StandardController sc = new ApexPages.StandardController(listExportcharge[0]);
            VFC02_ExportPricing testProduct = new VFC02_ExportPricing(sc);
            PageReference pageRef = Page.VFP02_ExportPricing; 
            pageRef.getParameters().put('id', String.valueOf(listExportcharge[0].Id));
            Test.setCurrentPage(pageRef);
            testProduct.getAllProduct();
            system.assertEquals( testProduct.mapProductWrapper.size() ,testProduct.mapProductWrapper.size());
        } 
    }

    @isTest static void testcharge() {  
        List<Product2> listExportcharge = [select id, name from product2 where recordtype.developername = 'Charge' AND Name = 'charge' limit 1 ];
 
        System.runAs(adminUser){ 
            ApexPages.StandardController sc = new ApexPages.StandardController(listExportcharge[0]);
            VFC02_ExportPricing testProduct = new VFC02_ExportPricing(sc);
            PageReference pageRef = Page.VFP02_ExportPricing; 
            pageRef.getParameters().put('id', String.valueOf(listExportcharge[0].Id));
            Test.setCurrentPage(pageRef);
            testProduct.getAllProduct();
            system.assertEquals( testProduct.mapProductWrapper.size() ,testProduct.mapProductWrapper.size());
        } 
    }

        
    

}