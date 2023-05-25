/* 
----------------------------------------------------------------------
-- - Name          : AP01_RelatedListContrat_TEST
-- - Author        : Comforth
-- - Description   : Test class for webservice souscritption AP01_RelatedListContrat 
-- - Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 2020-15-04  SRA    1.0     Initial version - 
----------------------------------------------------------------------
***********************************************************************/
@isTest
public class AP01_RelatedListContrat_TEST {
    
    @testSetup static void setup(){
        
        Account acc = new Account();
        acc.Name='Test webservice souscription';
        acc.ERP_Number__c='98671965';
        insert acc;
        
    }
    
    static testMethod void testFetchData() {
        User u = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
        insert u;
        
        Account accTest = [select id,Name from Account where Name LIKE 'Test webservice souscription%'];
        
        Test.setMock(HttpCalloutMock.class, new AP01_RelatedListContrat_MOCK());
        Test.startTest();
        AP01_RelatedListContrat.fetchData(accTest.Id);
        Test.stopTest();
        
    }
}