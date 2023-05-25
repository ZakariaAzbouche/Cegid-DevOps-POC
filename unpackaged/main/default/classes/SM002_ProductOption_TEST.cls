/**
* @author Keshav M- Comforth
* @date Creation 05 June 2020
* @description Test class for trigger logic SM002_ProductOption
*              
*/
@isTest
public class SM002_ProductOption_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static final String PRIMARY_CONTACT_EMAIL = 'primarycontact@email.com';
    static BypassTrigger__c bt= new BypassTrigger__c();
    
    @TestSetup static void setup(){    
        
        System.runAs(adminUser){ 
            //create product List
            List<Product2> listProductList = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
                    new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
                    new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List')
                    };
                        
                        listProductList[0].Name = 'test ProductArticle';
            insert listProductList;
            
            
            //create Article
            List<Product2> listArticle = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Article', ''),
                    new UTIL_TestFactory.ProductFactory().createProduct('Article', ''),
                    new UTIL_TestFactory.ProductFactory().createProduct('Article', '')
                    };
                        insert listArticle;
            
            List<SBQQ__ProductOption__c> listProductArticle = new List<SBQQ__ProductOption__c>{
                new UTIL_TestFactory.ProductOptionFactory().createProductOption(listArticle[0].Id, listProductList[0].Id),
                    new UTIL_TestFactory.ProductOptionFactory().createProductOption(listArticle[1].Id, listProductList[1].Id),
                    new UTIL_TestFactory.ProductOptionFactory().createProductOption(listArticle[2].Id, listProductList[2].Id)
                    };
                        
                        insert listProductArticle;
            
            bt.Activatetrigger__c = true;
            bt.SetupOwnerId = UserInfo.getOrganizationId();
            insert bt;
            
        }
    }
    
    @isTest static void testSM002_ProductOptionUpdate() {
        System.runAs(adminUser){
            Test.startTest();
            list<SBQQ__ProductOption__c> listProductOption = new list<SBQQ__ProductOption__c>();
            
            for(SBQQ__ProductOption__c po:[SELECT id, SBQQ__OptionalSKU__c,SBQQ__ConfiguredSKU__c,SBQQ__OptionalSKU__r.Purchasing_Price__c,SBQQ__ConfiguredSKU__r.Purchasing_Price__c, name 
                                           from SBQQ__ProductOption__c where SBQQ__ConfiguredSKU__r.Name = 'test ProductArticle']){
                                               po.SBQQ__Number__c = 2;
                                               listProductOption.add(po);
                                               
                                           }
            
            update listProductOption;
            
            
            system.assertEquals(200, listProductOption[0].SBQQ__OptionalSKU__r.Purchasing_Price__c);
            
            Test.stopTest();
        }
    }
    
    
    @isTest static void testSM002_ProductOptionDelete() {
        System.runAs(adminUser){
            Test.startTest();
            list<SBQQ__ProductOption__c> listProductOption = new list<SBQQ__ProductOption__c>();
            
            for(SBQQ__ProductOption__c po:[SELECT id, SBQQ__OptionalSKU__c,SBQQ__ConfiguredSKU__c,SBQQ__OptionalSKU__r.Purchasing_Price__c,SBQQ__ConfiguredSKU__r.Purchasing_Price__c, name 
                                           from SBQQ__ProductOption__c where SBQQ__ConfiguredSKU__r.Name = 'test ProductArticle']){
                                               po.SBQQ__Number__c = 2;
                                               listProductOption.add(po);
                                           }
            
            system.debug('listProductOption delete' + listProductOption);
            delete listProductOption;
            //system.assertEquals(null, listProductOption[0].SBQQ__ConfiguredSKU__r.Purchasing_Price__c);
            Test.stopTest();
        }
    }
    
    @isTest static void testSM002_CheckDouble() {
        System.runAs(adminUser){
            
            List<Product2> listpro = [SELECT id,Name from Product2 where Name ='test ProductArticle' limit 1];
            Product2 rtarticle =  new UTIL_TestFactory.ProductFactory().createProduct('Article', '');
            
            
            Insert rtarticle;
            
            SBQQ__ProductOption__c sbqq = new UTIL_TestFactory.ProductOptionFactory().createProductOption(rtarticle.Id, listpro[0].Id);
            
            Test.startTest();
            Insert sbqq;
            Test.stopTest();
        }
    }
    
}