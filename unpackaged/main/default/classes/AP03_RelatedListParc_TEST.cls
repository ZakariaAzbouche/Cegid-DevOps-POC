/***
* @author      Comforth - SRA
* @date        08/06/2020
* @description Test class for AP03_RelatedListParc
***/
@isTest
public class AP03_RelatedListParc_TEST {
    
    @testSetup static void setup(){
        
        Account acc1 = new UTIL_TestFactory.AccountFactory().createAccount();
        acc1.ERP_Number__c='90131522';
        acc1.National_ID__c='12345677789999';
        acc1.BillingCountry='France';
        acc1.BillingPostalCode='12354';
        acc1.BillingCity='Paris';
        acc1.NumberOfEmployees=12;
        acc1.AnnualRevenue=1234;
        insert acc1;
        
    }
    
    static testMethod void testFetchData() {
        User u = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
        insert u;
        
        Account accTest = [select id,Name from Account where Name LIKE 'test Comforth%'];
        
        Test.setMock(HttpCalloutMock.class, new AP03_RelatedListParc_MOCK());
        Test.startTest();
        AP03_RelatedListParc.fetchData(accTest.Id);
        Test.stopTest();
        
    }
}