/**
 * @author Varun Molla - Comforth Karoo
 * @date Creation 2021-11-11
 * @description Test class for apex class B2B_AssociatedProducts
 *              
*/
@isTest
private class B2B_AssociatedProducts_TEST {

    private static User adminUser =  new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();

    @isTest static void getProducts_Test(){ 
        System.runAs(adminUser){ 
            List<Product2> listProductList = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List')
            };
            listProductList[0].Name = 'test ProductArticle';
            //listProductList[0].Reference_Number__c = 'A0001053';
            insert listProductList;

            List<Product2> listArticle = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Article', '')
            };
            insert listArticle;
    
            List<SBQQ__ProductOption__c> listProductArticle = new List<SBQQ__ProductOption__c>{
                new UTIL_TestFactory.ProductOptionFactory().createProductOption(listArticle[0].Id, listProductList[0].Id)
            };
            //listProductArticle[0].Reference_Number__c = 'A0001053';          
            insert listProductArticle;

            B2B_Settings__c settings = new B2B_Settings__c();
            settings.StoreLoginURL__c = 'Test';
            settings.CommunityId__c = 'Test';
            settings.DefaultBuyerGroup__c  = 'Test';
            settings.StoreDomain__c = 'Test';
            settings.StripePublishableKey__c = 'Test';
            settings.AccessTokenURL__c = 'cegid-oauth-provider';
            settings.AccessTokenClientID__c = 'Test';
            settings.AccessTokenClientSecret__c = 'Test';
            settings.GetUnitaryProductSessionsURL__c = 'trainings';
            insert settings;
    
            Test.startTest();
                B2B_AssociatedProducts.getProducts(listProductList[0].Id, null);
            Test.stopTest();
        } 
    }

    @isTest static void getProductCategoryLabel_Test(){ 
        System.runAs(adminUser){ 
            List<Product2> listProductList = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List')
            };
            //listProductList[0].Category__c = '505';
            listProductList[0].Name = 'test ProductArticle';
            //listProductList[0].Reference_Number__c = 'A0001053';
            insert listProductList;
    
            Test.startTest();
                B2B_AssociatedProducts.getProductCategoryLabel(listProductList[0].Id);
            Test.stopTest();
        } 
    }
}