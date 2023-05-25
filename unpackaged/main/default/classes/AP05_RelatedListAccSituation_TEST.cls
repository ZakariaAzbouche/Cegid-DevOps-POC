/**
 * @author Akshi Boojhawon - Comforth
 * @date 2020-07-20
 * @description Test class for AP05_RelatedListAccSituation
 */
@isTest
private class AP05_RelatedListAccSituation_TEST {
    private static User adminUser =  new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
   
    @TestSetup static void setup(){
        
        Account acc = new UTIL_TestFactory.AccountFactory().createAccount();
        acc.ERP_Number__c='90131522';
        acc.National_ID__c='12345677789992';
        acc.BillingCountry='France';
        acc.BillingPostalCode='12354';
        acc.BillingCity='Paris';
        acc.NumberOfEmployees=12;
        acc.AnnualRevenue=1234;
        insert acc;
    }

 /**
  * @author Akshi Boojhawon - Comforth
  * @date 2020-07-21
  * @description test method for fetchData
  */
  @isTest
  static void testFetchData() {
        
        Account accTest = [select id,Name from Account where Name LIKE 'test Comforth%'];
               
        System.runAs(adminUser){
            Test.setMock(HttpCalloutMock.class, new AP05_RelatedListAccSituation_MOCK('success'));
            Test.startTest();
            Map <string,object> data = AP05_RelatedListAccSituation.fetchData(accTest.Id);
            Test.stopTest();
            System.assertNotEquals(null, data, 'Asserting that data is not null');
        }        
    }
 /**
  * @author Akshi Boojhawon - Comforth
  * @date 2020-07-21
  * @description test method for fetchData with error simulation
  */
  @isTest
  static void testFetchDataError401() {
        
        Account accTest = [select id,Name from Account where Name LIKE 'test Comforth%'];

        System.runAs(adminUser){
            Test.setMock(HttpCalloutMock.class, new AP05_RelatedListAccSituation_MOCK('error'));
            Test.startTest();
            Map <string,object> data = AP05_RelatedListAccSituation.fetchData(accTest.Id);
            Test.stopTest();
            System.assertEquals(system.Label.Error_Message_WS, data.get('error'), 'Asserting that WS is not available');
        }
    }
 /**
  * @author Akshi Boojhawon - Comforth
  * @date 2020-07-21
  * @description test method for fetchData with authentification failure
  */
  @isTest
  static void testFetchDataAuthFailure() {
        
        Account accTest = [select id,Name from Account where Name LIKE 'test Comforth%'];

        System.runAs(adminUser){
            Test.setMock(HttpCalloutMock.class, new AP05_RelatedListAccSituation_MOCK('authFailed'));
            Test.startTest();
            Map <string,object> data = AP05_RelatedListAccSituation.fetchData(accTest.Id);
            Test.stopTest();
            System.assertEquals(system.Label.AuthentificationFailed, data.get('error'), 'Asserting that Authentification Failed');
        }
    }
}