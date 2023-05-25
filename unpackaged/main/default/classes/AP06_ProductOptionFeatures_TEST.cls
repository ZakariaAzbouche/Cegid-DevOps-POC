/**
 * @description       : 
 * @author            : Keshav Matabadul
 * @group             : 
 * @last modified on  : 03-17-2022
 * @last modified by  : Keshav Matabadul
**/
@isTest
public with sharing class AP06_ProductOptionFeatures_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static final String PRIMARY_CONTACT_EMAIL = 'primarycontact@email.com';
    static BypassTrigger__c bt= new BypassTrigger__c();

    @isTest static void testProductOption(){  
        

            bt.Activatetrigger__c = true;
            bt.SetupOwnerId = UserInfo.getOrganizationId();
            insert bt;

            Product2 pro = new Product2();
            pro.recordtypeid = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();
            pro.Name = 'Product' ;
            pro.Marketing_Status__c = 'Marketable';
            pro.Service_Levels__c = 'C30';
            pro.SBQQ__PricingMethod__c = 'List';
            pro.Purchasing_Price__c = 122;
            pro.IsActive = true;
            pro.Metric__c='445';
            pro.Possible_Billing_Modes__c = 'Consumption';
            pro.InternalDescription__c = 'Test DESC';
            pro.SBQQ__ChargeType__c = 'One-Time';
            insert pro;

            List<Product2> listprod = new list<product2>();
            listprod.add(pro);
            
            Product2 proArticle = new Product2();
            proArticle.recordtypeid = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Article').getRecordTypeId();
            proArticle.Name = 'Product' ;
            proArticle.Marketing_Status__c = 'Marketable';
            proArticle.Service_Levels__c = 'C30';
            proArticle.SBQQ__PricingMethod__c = '';
            proArticle.Purchasing_Price__c = 122;
            proArticle.IsActive = true;
            proArticle.Metric__c='445';
            proArticle.Possible_Billing_Modes__c = 'Consumption';
            proArticle.InternalDescription__c = 'Test DESC';
            proArticle.SBQQ__ChargeType__c = 'One-Time';
            proArticle.NoRoyalty__c = true;
            proArticle.Purchasing_Price__c = 200;
            insert proArticle;



            //Product Option 
            SBQQ__ProductOption__c proOption = new SBQQ__ProductOption__c();
            proOption.SBQQ__OptionalSKU__c = proArticle.Id;
            proOption.SBQQ__ConfiguredSKU__c = pro.Id;
            proOption.OriginalFeature__c = '1';
            proOption.SBQQ__Number__c = 1;

            insert proOption;


            SBQQ__ProductFeature__c productFeature = new SBQQ__ProductFeature__c();
            productFeature.Name = 'prodFeatures';
            productFeature.SBQQ__Number__c = 10;
            productFeature.SBQQ__MinOptionCount__c = 1;
            productFeature.SBQQ__ConfiguredSKU__c = pro.Id;
            productFeature.Original_Feature_Id__c = '1';
            insert productFeature;

            System.runAs(adminUser){  
                AP06_ProductOptionFeatures.getProductOption(listprod);   
            }
    }
}