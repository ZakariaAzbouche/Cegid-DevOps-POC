/**
 * @description       : 
 * @author            : keshav Matabadul
 * @group             : 
 * @last modified on  : 11-28-2021
 * @last modified by  : keshav Matabadul
**/

@isTest
public class B2BUtils_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static BypassTrigger__c bt= new BypassTrigger__c();

    @isTest(SeeAllData=true) static void testB2BOrderRecap() {
        // Account and Contact are related
        Account account = new Account(Name='TestAccount');
        insert account;

        //Buyer Account
        //insert buyer Acoount
        BuyerAccount buyerAccount = new BuyerAccount();
        buyerAccount.BuyerId = account.Id;
        buyerAccount.Name = 'Test Buyer Account (BA-AJ)';
        buyerAccount.IsActive = true;
        insert buyerAccount;

        Contact contact = new Contact(LastName='TestContact', AccountId=account.Id);
        insert contact;

        WebStore webStore = new WebStore(Name='TestWebStore');
        insert webStore;

        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id);
        insert cart;

        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;

        
        // This profile name is the name of the buyer profile. The name specified here is what is installed using
        // SFDX and may be different for you.
        Profile profile = [SELECT Id FROM Profile WHERE Name='B2B Customer Community Plus' LIMIT 1];
        User user = new User(Alias='buyer', Email='buyer@example.com', LastName='Buyer',
                TimeZoneSidKey='GMT', LocaleSidKey='en_US', Username='buyer@example.com'+cart.Id,
                EmailEncodingKey='UTF-8', ProfileId=profile.Id, LanguageLocaleKey='en_US',
                ContactId=contact.Id);
        insert user;

        B2BUtils.resolveCommunityIdToWebstoreId('0DB2D0000004Xz7');
        System.runAs(user){ 
            B2BUtils.getUserAccountID();
            B2BUtils.resolveSortParam('');
        }
        
    }


}