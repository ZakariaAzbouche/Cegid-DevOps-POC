/***
* @author      Comforth - SRA
* @date        24/07/2020
* @description Test class for Ap04_RelatedListSupport
***/
@isTest
public class Ap04_RelatedListSupport_TEST {
    private static User adminUser =  new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    
    @testSetup static void setup(){
        
        Account acc1 = new UTIL_TestFactory.AccountFactory().createAccount();
        acc1.ERP_Number__c='90069796';
        acc1.National_ID__c='12345677789992';
        acc1.BillingCountry='France';
        acc1.BillingPostalCode='12354';
        acc1.BillingCity='Paris';
        acc1.NumberOfEmployees=12;
        acc1.AnnualRevenue=1234;
        insert acc1;
        
    }
    
    static testMethod void testFetchData() {
        
        Account accTest = [select id,Name from Account where Name LIKE 'test Comforth%'];
        
        System.runAs(adminUser){
            Test.setMock(HttpCalloutMock.class, new AP04_RelatedListSupport_MOCK('success'));
            Test.startTest();
            Ap04_RelatedListSupport.fetchData(accTest.Id);
            Test.stopTest();
        }
    }

    static testMethod void testRaiseCase() {
        
        Account accTest = [select id,Name from Account where Name LIKE 'test Comforth%'];
        
        System.runAs(adminUser){
            Test.setMock(HttpCalloutMock.class, new AP04_RelatedListSupport_MOCK('success'));
            Test.startTest();
            Ap04_RelatedListSupport.raiseCase('TST001', 'test');
            Test.stopTest();
        }
    }
    
    static testMethod void testGetAccountName() {
        
        Account accTest = [select id,Name from Account where Name LIKE 'test Comforth%'];
        System.runAs(adminUser){
            Test.startTest();
            Ap04_RelatedListSupport.getAccountName(accTest.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testFetchDataAuthFailure() {
        
        Account accTest = [select id,Name from Account where Name LIKE 'test Comforth%'];
        
        System.runAs(adminUser){
            Test.setMock(HttpCalloutMock.class, new AP04_RelatedListSupport_MOCK('authFailed'));
            Test.startTest();
            Map <string,object> data = AP04_RelatedListSupport.fetchData(accTest.Id);
            Ap04_RelatedListSupport.raiseCase('TST001', 'test');
            Test.stopTest();
            System.assertEquals(system.Label.AuthentificationFailed, data.get('error'), 'Asserting that Authentification Failed');
        }
    }
}