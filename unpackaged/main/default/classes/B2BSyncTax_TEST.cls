/**
 * @description       : Test class for B2BSyncTax
 * @author            : Gulshan DOORGAH gulshan.doorgah@comforth-karoo.eu
 * @group             : B2B
 * @last modified on  : 2021-11-29
 * @last modified by  : Gulshan DOORGAH gulshan.doorgah@comforth-karoo.eu
**/
@IsTest
private class B2BSyncTax_TEST {
    @isTest(SeeAllData=true) static void testSyncTax() {
        Id b2bProfileId = [SELECT Id FROM Profile WHERE Name = 'B2B Customer Community Plus']?.Id;

        Account account = new Account(Name = 'TestAccount', BillingCountry ='France', BillingPostalCode = '69009');
        insert account;
        System.debug('account ' + account.Id);

        ContactPointAddress cpa1 = new ContactPointAddress(
            ParentId = account.Id,
            AddressType = 'Billing',
            IsDefault = true,
            City = 'Paris',
            Street = 'Avenue Telfair',
            Country = 'France',
            Name = 'CPA1'
        );
        insert cpa1;

        Contact con = new Contact(LastName = 'testCon', AccountId = account.Id);
        insert con; 
        
        User b2bUser = new User(Alias = 'test123', Email='B2BPaymentControllerCustTest@cegid.test',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = b2bProfileId, country='United States',IsActive =true,
                ContactId = con.Id,
                timezonesidkey='America/Los_Angeles', username='B2BPaymentControllerCustTest@cegid.test');
       
        insert b2bUser;

        //Buyer Account
        BuyerAccount buyerAccount = new BuyerAccount();
        buyerAccount.BuyerId = account.Id;
        buyerAccount.Name = 'Test Buyer Account (BA-AJ)';
        buyerAccount.IsActive = true;
        insert buyerAccount;

        Contact contact = new Contact(LastName='TestContact', AccountId=account.Id);
        insert contact;

        WebStore webStore = [SELECT Id, Name FROM WebStore WHERE Name = :Label.B2B_StoreName];
        System.debug('webStore ' + webStore.Id);

        WebCart cart = new WebCart(
            Name = 'Cart', 
            WebStoreId = webStore.Id, 
            AccountId = account.Id,
            Status = 'Active',
            BillingStreet = 'testStreet',
            BillingCity = 'testCity');
        insert cart;

        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;

        List<Product2> listProduct = new List<Product2>{
            new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
            new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
            new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List')
        };
        insert listProduct;
        
        List<CartDeliveryGroup> cartDeliveryGroups = [SELECT Id 
                                                        FROM CartDeliveryGroup 
                                                        WHERE CartId = :cart.Id 
                                                        LIMIT 1];
        CartItem cartItem = new CartItem(
            CartId=cart.Id, 
            Sku='SKU_Test1', 
            Quantity=3.0, 
            Type='Product', 
            Name='TestProduct', 
            CartDeliveryGroupId=cartDeliveryGroups[0].Id,
            Product2Id = listProduct[0].Id,
            TotalPrice = 100
        );
        insert cartItem;

        System.runAs(b2bUser){
            B2BSyncTax.syncTax(new List <Id>{cart.Id});
        }
    }
}