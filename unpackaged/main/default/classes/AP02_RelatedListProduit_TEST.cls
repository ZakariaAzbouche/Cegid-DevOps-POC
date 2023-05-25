/**
* @author Sid - Comforth
* @date 2020-015-04
* @group UTIL
* @description Classe AP02_RelatedListProduit_TEST
*/
@isTest
public class AP02_RelatedListProduit_TEST {
    
    @testSetup static void setup(){
        
        Account acc = new Account();
        acc.Name='Test webservice produit';
        acc.ERP_Number__c='98671965';
        insert acc;
        
    }
    
    static testMethod void testFetchData() {
        User u = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
        insert u;
        
        Account accTest = [select id,Name from Account where Name LIKE 'Test webservice produit%'];
        
        Test.setMock(HttpCalloutMock.class, new AP02_RelatedListProduit_MOCK());
        Test.startTest();
        AP02_RelatedListProduit.fetchData('ASZ90-00001057',accTest.Id);
        Test.stopTest();
        
    }
}