/**
 * @author Varun Molla - Comforth Karoo
 * @date Creation 2021-11-11
 * @description Test class for apex class B2B_OrderConfirmationEmail
 *              
*/
@isTest
private class B2B_OrderConfirmationEmail_TEST {

    private static User adminUser =  new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static User testUser;
    static WebCart webcart1;
    static Account acc1;
    static Participant__c participant1;
    static CartItem cartItem1;
    static CartDeliveryGroup cartDeliveryGroup1;
    static BypassTrigger__c bypasstrigger;
    static WebStore webStore1;
    
    static{       
        System.runAs(adminUser){
            //Insert BypassTrigger__c
            bypasstrigger = new BypassTrigger__c(
                Activatetrigger__c=true,
                SetupOwnerId=Userinfo.getOrganizationId()
            );
            insert bypasstrigger;

            B2B_Settings__c settings = new B2B_Settings__c();
            settings.StoreLoginURL__c = 'Test';
            settings.CommunityId__c = 'Test';
            settings.DefaultBuyerGroup__c  = 'Test';
            settings.StoreDomain__c = 'Test';
            settings.StripePublishableKey__c = 'Test';
            insert settings;
            
            // Insert Account
            acc1 = new Account(
                Name = 'Acc1',
                Type__c='001',
                BillingStreet = 'Test',
                BillingCity = 'Test',
                BillingCountry = 'Italy',
                BillingPostalCode = '12345',
                National_ID_Exception__c='Creation In progress'
                
            );
            insert acc1;
            
            //Insert webstore
            webStore1 = new WebStore(
                Name='testwebstore'
                
            );
            insert webStore1;
            
            // Insert WebCart
            webcart1 = new WebCart(
                Name = 'Cart1',
                Status='Checkout',
                AccountId=acc1.id,
                WebStoreId= webStore1.Id         
            );
            insert webcart1;  
            
            // Insert cartDeliveryGroup
            cartDeliveryGroup1 = new CartDeliveryGroup(
                Name='Default Delivery',
                CartId=webcart1.Id
            );
            insert cartDeliveryGroup1;
            
            //Insert cart item
            CartItem cartItem1 = new CartItem(
                CartId=webcart1.Id, 
                Sku='SKU_Test1', 
                Quantity=3.0,
                SalesPrice=400,
                Type='Product', 
                Name='TestProduct', 
                CartDeliveryGroupId=cartDeliveryGroup1.Id,
                TECH_SessionDate__c = '25/10/2021 09h00 - 10h30',
                TECH_SessionCode__c = 'PRU117'
            );
            insert cartItem1;
            
            //Insert participants
            participant1 = new Participant__c(
                Name='testP1',
                Civilite__c ='Mr',
                Prenom__c = 'Test',
                EmailAddress__c='test1@test.test', 
                CartItemId__c=cartItem1.Id          
            );
            insert participant1;
        }
    }

    @isTest static void createTrainingSessionRecords_Test(){ 
        System.runAs(adminUser){ 
            Account acct = new Account(Name='tAccount');
            insert acct;

            Product2 pd = new Product2(Name='Pord A',isActive=true);
            pd.IsActive = true;
            insert pd;

            Product2 p = new Product2();
            p.Name = ' Test Product ';
            p.Description='Test Product Entry 1';
            p.productCode = 'ABC';
            p.isActive = true;
            insert p;

            ContentVersion cv=new Contentversion();
            cv.title='ABC';
            cv.PathOnClient ='test';
            Blob b=Blob.valueOf('Unit Test Attachment Body');
            cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
            insert cv;

            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=p.id;
            contentlink.contentdocumentid=[SELECT contentdocumentid FROM contentversion WHERE Id = :cv.id].contentdocumentid;
            contentlink.ShareType = 'I';
            contentlink.Visibility = 'AllUsers'; 
            insert contentlink;

            //PriceBook2 pb2Standard = [SELECT Id FROM Pricebook2 WHERE isStandard=true];
            Id standardPriceBookId = Test.getStandardPricebookId();

            PricebookEntry standardPrice = new PricebookEntry();
            standardPrice.Pricebook2Id = standardPriceBookId;
            standardPrice.Product2Id = p.Id;
            standardPrice.UnitPrice = 1;
            standardPrice.IsActive = true;
            standardPrice.UseStandardPrice = false;
            insert standardPrice;

            Order od = new Order();
            od.Name = '14TPE000001';
            od.AccountId = acct.Id;
            od.EffectiveDate = Date.Today();
            od.Status = 'Draft';
            od.BIC__c = 'CDEFGHIJ';
            od.IBAN__c = 'CDEFGHIJABCDEFGHIJABCDEFG';
            od.Pricebook2Id = standardPriceBookId;
            od.B2BOrder__c = true;
            od.Cart__c = webcart1.Id;
            insert od;

            PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=pd.Id, UnitPrice=99, isActive=true);
            insert pbe;
            Product2 p2ex = [SELECT Name FROM Product2 WHERE Id = :pd.Id];

            OrderItem ordPd = new OrderItem(PriceBookEntryId=standardPrice.Id, OrderId=od.Id, Quantity=1, UnitPrice=99, Product2Id = p.Id);
            insert ordPd;

            CartCheckoutSession ccs = new CartCheckoutSession();
            ccs.OrderId = od.Id;
            ccs.WebCartId = webcart1.Id;
            ccs.Name = 'TestCCS';
            ccs.State='InProcessing';
            insert ccs;

            List<CartCheckoutSession> listMainCheckoutSession = new List<CartCheckoutSession>{ccs};

            Test.startTest();
                B2B_OrderConfirmationEmail.createTrainingSessionRecords(listMainCheckoutSession);
            Test.stopTest();
        }   
    }

    @isTest static void createTrainingSessionRecords_Test_CreditCard(){ 
        System.runAs(adminUser){ 
            Account acct = new Account(Name='tAccount');
            insert acct;

            Product2 pd = new Product2(Name='Pord A',isActive=true);
            pd.IsActive = true;
            insert pd;

            Product2 p = new Product2();
            p.Name = ' Test Product ';
            p.Description='Test Product Entry 1';
            p.productCode = 'ABC';
            p.isActive = true;
            insert p;

            //PriceBook2 pb2Standard = [SELECT Id FROM Pricebook2 WHERE isStandard=true];
            Id standardPriceBookId = Test.getStandardPricebookId();

            PricebookEntry standardPrice = new PricebookEntry();
            standardPrice.Pricebook2Id = standardPriceBookId;
            standardPrice.Product2Id = p.Id;
            standardPrice.UnitPrice = 1;
            standardPrice.IsActive = true;
            standardPrice.UseStandardPrice = false;
            insert standardPrice;

            Order od = new Order();
            od.Name = '14TPE000001';
            od.AccountId = acct.Id;
            od.EffectiveDate = Date.Today();
            od.Status = 'Draft';
            od.BIC__c = 'CDEFGHIJ';
            od.Pricebook2Id = standardPriceBookId;
            od.B2BOrder__c = true;
            od.Cart__c = webcart1.Id;
            insert od;

            PricebookEntry pbe = new PricebookEntry(Pricebook2Id=standardPriceBookId, Product2Id=pd.Id, UnitPrice=99, isActive=true);
            insert pbe;
            Product2 p2ex = [SELECT Name FROM Product2 WHERE Id = :pd.Id];

            OrderItem ordPd = new OrderItem(PriceBookEntryId=standardPrice.Id, OrderId=od.Id, Quantity=1, UnitPrice=99);
            insert ordPd;

            CartCheckoutSession ccs = new CartCheckoutSession();
            ccs.OrderId = od.Id;
            ccs.WebCartId = webcart1.Id;
            ccs.Name = 'TestCCS';
            ccs.State='InProcessing';
            insert ccs;

            List<CartCheckoutSession> listMainCheckoutSession = new List<CartCheckoutSession>{ccs};

            Test.startTest();
                B2B_OrderConfirmationEmail.createTrainingSessionRecords(listMainCheckoutSession);
            Test.stopTest();
        }   
    }
}