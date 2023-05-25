/**
 * @description       : Test class for B2BPaymentControllerCust
 * @author            : Gulshan DOORGAH gulshan.doorgah@comforth-karoo.eu
 * @group             : B2B
 * @last modified on  : 2021-11-29
 * @last modified by  : Gulshan DOORGAH gulshan.doorgah@comforth-karoo.eu
**/
@IsTest
private class B2BPaymentControllerCust_TEST {
    @isTest(SeeAllData=true) static void testGetPaymentInfo() {
        Id b2bProfileId = [SELECT Id FROM Profile WHERE Name = 'B2B Customer Community Plus']?.Id;

        Account account = new Account(Name = 'TestAccount');
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

        System.runAs(b2bUser){
            B2BPaymentControllerCust.getPaymentInfo(cart.Id);

            B2BPaymentControllerCust.setPayment('PurchaseOrderNumber', cart.Id, null, new Map <String, Object>{'poNumber' => 'testPoNumber'});

            try{
                B2BPaymentControllerCust.setPayment('CreditCard', cart.Id, null, new Map <String, Object>{});
            }catch(Exception e){
                
            }

            B2BPaymentControllerCust.getAddress(new Map <String, Object>{
                'street' => 'street',
                'city'  => 'city',
                'state' => 'state',
                'country' => 'country',
                'postalCode' => 'postalCode'
            });

            WebCart wCart = [SELECT Id, BillingAddress, PoNumber 
                            FROM WebCart 
                            WHERE Id = :cart.Id];

            try{
                B2BPaymentControllerCust.prependAddressToList(
                    new List<Map<String, Object>>(), 
                    wCart.BillingAddress, 
                    true, 
                    wCart.Id
                );
            }catch(Exception e){

            }
        }
        
    }
}