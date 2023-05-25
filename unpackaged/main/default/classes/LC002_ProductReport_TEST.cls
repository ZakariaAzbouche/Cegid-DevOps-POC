/* 
----------------------------------------------------------------------
-- - Name          : LC002_ProductReport_Test
-- - Author        : Comforth
-- - Description   : Query Product based on Id 
-- - Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 12 Feb-2020  KMM    1.0     Initial version - 
----------------------------------------------------------------------
***********************************************************************/
@istest
public class LC002_ProductReport_TEST {
    @isTest
    static void unitTest() {
        Test.startTest();
        Id RecordTypeIdProductArticle = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Article').getRecordTypeId();
        Id RecordTypeIdProductPackage = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId();
        
        Product2 proArticle = new Product2(Name = 'testpro', recordtypeid = RecordTypeIdProductArticle, Buying_Metric__c = '100', NoRoyalty__c = true , IsActive = true, Marketing_Status__c = 'Marketable');
        insert proArticle;
        
        Product2 proPackage = new Product2(Name = 'testpro', recordtypeid = RecordTypeIdProductPackage, Buying_Metric__c = '100', Possible_Billing_Modes__c='Consumption', Marketing_Status__c = 'Marketable', SBQQ__ChargeType__c = 'One-Time' , IsActive = true);
        insert proPackage;
        
        
        SBQQ__ProductOption__c proOp = new SBQQ__ProductOption__c(SBQQ__Number__c = 2 , SBQQ__ConfiguredSKU__c = proArticle.Id, SBQQ__OptionalSKU__c = proArticle.Id);
        insert proOp;
        
        SBQQ__ProductOption__c proOpPAc = new SBQQ__ProductOption__c(SBQQ__Number__c = 2 , SBQQ__ConfiguredSKU__c = proPackage.Id, SBQQ__OptionalSKU__c = proPackage.Id);
        insert proOpPAc;
        
        
        LC002_ProductReport.getProducts(String.valueOf(proArticle.Id),'Article');
        LC002_ProductReport.getProducts(String.valueOf(proPackage.Id),'Package');
        
        LC002_ProductReport.getObjMetadata();
        
        Test.stopTest();
    }
    
}