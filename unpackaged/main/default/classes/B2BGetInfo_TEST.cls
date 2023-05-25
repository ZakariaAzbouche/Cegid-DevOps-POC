/**
 * @description       : 
 * @author            : keshav Matabadul
 * @group             : 
 * @last modified on  : 11-30-2021
 * @last modified by  : keshav Matabadul
**/
@isTest
public with sharing class B2BGetInfo_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();

    @isTest static void testB2BOrderRecap() {
        // Account and Contact are related
        Account account = new Account(Name='TestAccount');
        insert account;

        Account account2 = new Account(Name='TestAccount');
        insert account2;

        //Buyer Account
        //insert buyer Acoount
        BuyerAccount buyerAccount = new BuyerAccount();
        buyerAccount.BuyerId = account.Id;
        buyerAccount.Name = 'Test Buyer Account (BA-AJ)';
        buyerAccount.IsActive = true;
        insert buyerAccount;

        BuyerAccount buyerAccount2 = new BuyerAccount();
        buyerAccount2.BuyerId = account2.Id;
        buyerAccount2.Name = 'Test Buyer Account (BA-AJ)';
        buyerAccount2.IsActive = true;
        insert buyerAccount2;

        Contact contact = new Contact(LastName='TestContact', AccountId=account.Id);
        insert contact;

        Contact contact2 = new Contact(LastName='TestContact', AccountId=account2.Id);
        insert contact2;

        WebStore webStore = new WebStore(Name='TestWebStore');
        insert webStore;
        // WebStore webStore = [SELECT Id, Name FROM WebStore WHERE Name = :Label.B2B_StoreName];
        // System.debug('webStore ' + webStore.Id);

        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id,Status = 'Active');
        insert cart;

        WebCart cart2 = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account2.Id,Status = 'Active');
        insert cart2;
        System.debug('cart ' + cart.Id);



        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;

        CartDeliveryGroup cartDeliveryGroup2 = new CartDeliveryGroup(CartId=cart2.Id, Name='Default Delivery');
        insert cartDeliveryGroup2;

        //Create BuyerGroup
        BuyerGroup buyerG = new BuyerGroup(Name='test Buyer Group', Description='Test group for community');
        insert buyerG;

        //create BuyerGroupMember
        BuyerGroupMember buyerMember = new BuyerGroupMember(BuyerId=account.Id,BuyerGroupId=buyerG.Id);
        insert buyerMember;

        BuyerGroupMember buyerMember2 = new BuyerGroupMember(BuyerId=account2.Id,BuyerGroupId=buyerG.Id);
        insert buyerMember2;

        //Create webstoreBuyerGroup
        WebStoreBuyerGroup wsBuyerGroup = new WebStoreBuyerGroup(BuyerGroupId=buyerG.Id,WebStoreId=webStore.Id);
        insert wsBuyerGroup;

        System.debug('webStore : ' + webStore.Id);
        System.debug('webStore : ' + account.Id);
        
        // This profile name is the name of the buyer profile. The name specified here is what is installed using
        // SFDX and may be different for you.
        Profile profile = [SELECT Id FROM Profile WHERE Name='B2B Customer Community Plus' LIMIT 1];
        User user = new User(Alias='buyer', Email='buyer@example.com', LastName='Buyer',
                TimeZoneSidKey='GMT', LocaleSidKey='en_US', Username='buyer@example.com'+cart.Id,
                EmailEncodingKey='UTF-8', ProfileId=profile.Id, LanguageLocaleKey='en_US',
                ContactId=contact.Id);
        insert user;

        //Network netW = [SELECT id,Name FROM Network WHERE Name = 'test' limit 1];
        //create product2
        List<Product2> listProduct = new List<Product2>{
            new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
            new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
            new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List')
        };
        integer count = 0;
        for(Product2 pro:listProduct){
            pro.StockKeepingUnit = 'p'+count;
            count++;
        }
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
            Product2Id = listProduct[0].Id
        );
        insert cartItem;

        List<Id> listCartIds = new List<Id>();
        for(WebCart wcart:[SELECT Id FROM WebCart]){
            listCartIds.add(wcart.Id);
        }

            try{
                B2BGetInfo.getProduct(
                    String.valueOf(webStore.Id),//community Id
                    String.valueOf(listProduct[0].Id),
                    String.valueOf(cart.Id)//Effective Account Id
                );

            }catch(Exception e){
                System.debug(e.getMessage());
            }

            try{

                B2BGetInfo.checkProductIsInStock( String.valueOf(listProduct[0].Id));

            }catch(Exception e){
                System.debug(e.getMessage());
            }

            try{
                B2BGetInfo.getCartSummary(  
                    String.valueOf(webStore.Id),//community Id
                    String.valueOf(cart.Id)//Effective Account Id
                );

            }catch(Exception e){
                System.debug(e.getMessage());
            }

            try{
                B2BGetInfo.addToCart(  
                    String.valueOf(webStore.Id),//community Id
                    String.valueOf(listProduct[0].Id),
                    '1',
                    String.valueOf(cart.Id),//Effective Account Id
                    String.valueOf(cart.Id),
                    null,
                    null
                );

            }catch(Exception e){
                System.debug(e.getMessage());
            }

            try{
                B2BGetInfo.addToCart(  
                    String.valueOf(webStore.Id),//community Id
                    String.valueOf(listProduct[0].Id),
                    '1',
                    String.valueOf(cart.Id),//Effective Account Id
                    String.valueOf(cart2.Id),
                    null,
                    null
                );

            }catch(Exception e){
                System.debug(e.getMessage());
            }

            try{
                B2BGetInfo.createAndAddToList(  
                    String.valueOf(webStore.Id),//community Id
                    String.valueOf(listProduct[0].Id),
                    'testWish',
                    String.valueOf(cart.Id)//Effective Account Id
                );

            }catch(Exception e){
                System.debug(e.getMessage());
            }

            try{
                B2BGetInfo.getProductPrice(  
                    String.valueOf(webStore.Id),//community Id
                    String.valueOf(listProduct[0].Id),
                    String.valueOf(cart.Id)//Effective Account Id
                );

            }catch(Exception e){
                System.debug(e.getMessage());
            }
       
    }
}