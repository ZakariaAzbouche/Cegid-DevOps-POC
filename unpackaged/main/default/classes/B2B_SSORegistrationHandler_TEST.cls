/**
 * @description       : Passeport SSO registration handler
 * @author            : Gulshan DOORGAH gulshan.doorgah@comforth-karoo.eu
 * @group             : B2B
 * @last modified on  : 2021-11-28
 * @last modified by  : Gulshan DOORGAH gulshan.doorgah@comforth-karoo.eu
**/
@IsTest
private class B2B_SSORegistrationHandler_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static final String ASSERTION = 'PHNhbWxwOlJlc3BvbnNlIHhtbG5zOnNhbWw9InVybjpvYXNpczpuYW1lczp0YzpTQU1MOjIuMDphc3NlcnRpb24iIHhtbG5zOnhzaT0iaHR0cDovL3d3dy53My5vcmcvMjAwMS9YTUxTY2hlbWEtaW5zdGFuY2UiIElEPSJfMmYxYzQ3MTgtYWNmNi00NjFmLTkxZWYtNjI2ZDllNDEzNWRhIiBWZXJzaW9uPSIyLjAiIElzc3VlSW5zdGFudD0iMjAyMS0xMi0wMlQxMzo0NTozNC45MTQyODc5WiIgeG1sbnM6c2FtbHA9InVybjpvYXNpczpuYW1lczp0YzpTQU1MOjIuMDpwcm90b2NvbCI+Cgk8c2FtbDpBc3NlcnRpb24geG1sbnM6c2FtbHA9InVybjpvYXNpczpuYW1lczp0YzpTQU1MOjIuMDpwcm90b2NvbCIgeG1sbnM6eHNpPSJodHRwOi8vd3d3LnczLm9yZy8yMDAxL1hNTFNjaGVtYS1pbnN0YW5jZSIgSUQ9Il8xZjkyZDJjOC03YTdhLTQ4MDMtOGQxMy1mZjBmYWY2MDY3MTciIFZlcnNpb249IjIuMCIgSXNzdWVJbnN0YW50PSIyMDIxLTEyLTAyVDEzOjQ1OjM0LjgzNjE1ODNaIiB4bWxuczpzYW1sPSJ1cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6YXNzZXJ0aW9uIj4KCQk8c2FtbDpJc3N1ZXIgRm9ybWF0PSJ1cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6bmFtZWlkLWZvcm1hdDplbnRpdHkiPmh0dHBzOi8vaW50ZS1zaWduaW4uY2VnaWQuY29tPC9zYW1sOklzc3Vlcj4KCQk8c2FtbDpBdHRyaWJ1dGVTdGF0ZW1lbnQgeG1sbnM6eHM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDEvWE1MU2NoZW1hIj4KCQkJPHNhbWw6QXR0cmlidXRlIE5hbWU9Imh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvcm9sZSIgTmFtZUZvcm1hdD0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOmF0dHJuYW1lLWZvcm1hdDp1cmkiIEZyaWVuZGx5TmFtZT0iUm9sZSI+CgkJCQk8c2FtbDpBdHRyaWJ1dGVWYWx1ZSB4c2k6dHlwZT0ieHM6YW55VHlwZSI+QV9DT01NVU5JVFlfQ1BBLDwvc2FtbDpBdHRyaWJ1dGVWYWx1ZT4KCQkJCTxzYW1sOkF0dHJpYnV0ZVZhbHVlIHhzaTp0eXBlPSJ4czphbnlUeXBlIj5BX1NUT1JFX0IyQjwvc2FtbDpBdHRyaWJ1dGVWYWx1ZT4KCQkJPC9zYW1sOkF0dHJpYnV0ZT4KCQkJPHNhbWw6QXR0cmlidXRlIE5hbWU9Imh0dHA6Ly9wYXNzZXBvcnQuY2VnaWQuY29tL0V4dGVuZGVkUm9sZSIgTmFtZUZvcm1hdD0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOmF0dHJuYW1lLWZvcm1hdDp1cmkiIEZyaWVuZGx5TmFtZT0iRXh0ZW5kZWQgUm9sZSI+CgkJCQk8c2FtbDpBdHRyaWJ1dGVWYWx1ZSB4c2k6dHlwZT0ieHM6YW55VHlwZSI+QV9DT01NVU5JVFlfQ1BBLCA5OTk4MDAxNjwvc2FtbDpBdHRyaWJ1dGVWYWx1ZT4KCQkJCTxzYW1sOkF0dHJpYnV0ZVZhbHVlIHhzaTp0eXBlPSJ4czphbnlUeXBlIj5BX1NUT1JFX0IyQiwgOTk5ODAwMDE8L3NhbWw6QXR0cmlidXRlVmFsdWU+CgkJCQk8c2FtbDpBdHRyaWJ1dGVWYWx1ZSB4c2k6dHlwZT0ieHM6YW55VHlwZSI+QV9TVE9SRV9CMkIsIDk5OTgwMDE2PC9zYW1sOkF0dHJpYnV0ZVZhbHVlPgoJCQk8L3NhbWw6QXR0cmlidXRlPgoJCTwvc2FtbDpBdHRyaWJ1dGVTdGF0ZW1lbnQ+Cgk8L3NhbWw6QXNzZXJ0aW9uPgo8L3NhbWxwOlJlc3BvbnNlPg==';

    @TestSetup
    static void dataSetup(){
        
    }

    static Map<String, String> attributes = new Map <String, String>{
        B2B_SSORegistrationHandler.EMAIL_PATH => 'cegid@test.b2b',
        B2B_SSORegistrationHandler.PHONE_PATH => '1234567890',
        B2B_SSORegistrationHandler.FIRSTNAME_PATH => 'TestFirstName',
        B2B_SSORegistrationHandler.LASTNAME_PATH => 'TestLastName',
        B2B_SSORegistrationHandler.TITLE_PATH => 'M.',
        B2B_SSORegistrationHandler.COMPANY_PATH => 'CEGID',
        B2B_SSORegistrationHandler.EMPLOYEE_NUMBER_PATH => '0987654321',
        B2B_SSORegistrationHandler.ACCOUNTID_PATH => '9999999999',
        B2B_SSORegistrationHandler.SALUTATION_PATH => 'M',
        B2B_SSORegistrationHandler.MOBILEPHONE_PATH => '1234567891'
            
    };

    @IsTest static void testHandleJitUpdateUser() {
        insert adminUser;
        B2B_SSORegistrationHandler handler = new B2B_SSORegistrationHandler();
        
        handler.updateUser(adminUser.Id, null, null, null, null, attributes, null);
    }

    @IsTest static void testHandleJitCreateUser() {
        insert adminUser;
        B2B_SSORegistrationHandler handler = new B2B_SSORegistrationHandler();

        handler.createUser(null, null, null, null, attributes, null);
    }

    @IsTest static void testHandleJitCreateUserCommunity() {
        insert adminUser;
        Account acc = new UTIL_TestFactory.AccountFactory().createAccount();
        acc.ERP_Number__c = '9999999999';
        insert acc;

        Network community = [SELECT Id FROM Network LIMIT 1];

        //Create BuyerGroup
        BuyerGroup buyerG = new BuyerGroup(Name='B2B_SSORegistrationHandler_TEST Buyer Group', Description='Test group for community');
        insert buyerG;

        B2B_Settings__c settings = new B2B_Settings__c();
            settings.StoreLoginURL__c = 'Test';
            settings.CommunityId__c = community.Id;
            settings.DefaultBuyerGroup__c = buyerG.Name;
            settings.StoreDomain__c = 'Test';
            settings.StripePublishableKey__c = 'Test';
            settings.SetupOwnerId = UserInfo.getOrganizationId();
        insert settings;
        
        Test.startTest();
        B2B_SSORegistrationHandler handler = new B2B_SSORegistrationHandler();
        System.debug('settings ' + B2B_SSORegistrationHandler.B2B_SETTINGS);
        handler.handleJit(true, adminUser, null, community.Id, null, null, attributes, ASSERTION);
        Test.stopTest();
    }

    @IsTest static void testHandleJitCreateUserFromLead() {
        adminUser.BypassPB__c = true;
        insert adminUser;
        Account acc = new UTIL_TestFactory.AccountFactory().createAccount();
        acc.ERP_Number__c = '9999999999';
        insert acc;

        insert new Lead(
            FirstName = attributes.get(B2B_SSORegistrationHandler.FIRSTNAME_PATH), 
            LastName = attributes.get(B2B_SSORegistrationHandler.LASTNAME_PATH),
            Company = attributes.get(B2B_SSORegistrationHandler.COMPANY_PATH),
            Email = attributes.get(B2B_SSORegistrationHandler.EMAIL_PATH),
            Sales_Purpose__c = '511'
        );

        Network community = [SELECT Id FROM Network LIMIT 1];
        
        System.runAs(adminUser){
            Test.startTest();
            B2B_SSORegistrationHandler handler = new B2B_SSORegistrationHandler();
            handler.handleJit(true, new User(), null, community.Id, null, null, attributes, ASSERTION);
            Test.stopTest();
        }
    }
}