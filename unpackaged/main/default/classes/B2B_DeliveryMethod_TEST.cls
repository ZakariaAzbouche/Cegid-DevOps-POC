/**
 * @description       : 
 * @author            : keshav Matabadul
 * @group             : 
 * @last modified on  : 11-30-2021
 * @last modified by  : keshav Matabadul
**/
@isTest
public with sharing class B2B_DeliveryMethod_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    @isTest static void testB2BOrderRecap() {
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

         List<Product2> listProduct = new List<Product2>{
            new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
            new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
            new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List')
        };
        insert listProduct;

        WebStore webStore = new WebStore(Name='TestWebStore');
        insert webStore;

        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id);
        insert cart;



        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;

        CartItem cartItem = new CartItem(
            CartId=cart.Id, 
            Sku='SKU_Test1', 
            Quantity=3.0, 
            Type='Product', 
            Name='TestProduct', 
            CartDeliveryGroupId=cartDeliveryGroup.Id,
            Product2Id = listProduct[0].Id
        );
        insert cartItem;

        List<Id> listCartIds = new list<Id>();
        listCartIds.add(cart.Id);
        
        system.debug('B2B_DeliveryMethod_TEST :' + listCartIds);

        Profile profile = [SELECT Id FROM Profile WHERE Name='B2B Customer Community Plus' LIMIT 1];
        User user = new User(Alias='buyer', Email='buyer@example.com', LastName='Buyer',
                TimeZoneSidKey='GMT', LocaleSidKey='en_US', Username='buyer@example.com'+cart.Id,
                EmailEncodingKey='UTF-8', ProfileId=profile.Id, LanguageLocaleKey='en_US',
                ContactId=contact.Id);
        insert user;



        System.runAs(user){ 
            B2B_DeliveryMethod.updateDeliveryMethod(listCartIds);
        }
    }
}