@IsTest
public with sharing class Utility_TEST {

    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();

    @TestSetup
    static void makeData() {
        insert adminUser;
    }

    @isTest static void mentionTextPostTest() {

        Account acc = new UTIL_TestFactory.AccountFactory().createAccount();
        acc.National_Id__c = '32345545656769';
        acc.BillingCountryCode = 'FR';
        acc.ERP_Number__c = 'TESTER';
        acc.Phone = '0143434543';
        acc.BillingStreet = 'Rue du Test';
        acc.BillingPostalCode = '69007';
        acc.BillingCity = 'LYON';
        acc.IntercommunityVATnumber__c = 'TESTVAT';
        acc.Siren_Siret__c = '';
        
        insert acc;

        Test.startTest();
            Utility.mentionTextPost(adminUser.Id, 'Test mention', acc.Id, 'body test mention');
        Test.stopTest();
    }

    @isTest static void createBatchInputTest() {

        Account acc = new UTIL_TestFactory.AccountFactory().createAccount();
        acc.National_Id__c = '32345545656769';
        acc.BillingCountryCode = 'FR';
        acc.ERP_Number__c = 'TESTER';
        acc.Phone = '0143434543';
        acc.BillingStreet = 'Rue du Test';
        acc.BillingPostalCode = '69007';
        acc.BillingCity = 'LYON';
        acc.IntercommunityVATnumber__c = 'TESTVAT';
        acc.Siren_Siret__c = '';
        

        insert acc;
        Test.startTest();
            Utility.createBatchInput(adminUser.Id, acc.Id, 'body test batch input');
        Test.stopTest();
    }

    @isTest static void isEmptyTest() {
        String testStr = '';
        Test.startTest();
            Boolean resultStr = Utility.isEmpty(testStr);
        Test.stopTest();
        System.assertEquals(true, resultStr, 'string is empty result should be true');
    }
}