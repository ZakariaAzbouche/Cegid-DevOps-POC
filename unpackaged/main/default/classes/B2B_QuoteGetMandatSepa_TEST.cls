/***
* @author      : Trilochnah - Comforth Karoo
* @date		   : 26/10/21
* @description : Test class for B2B_QuoteGetMandatSepa
***/
@isTest
public class B2B_QuoteGetMandatSepa_TEST {
    private static User adminUser =  new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static User testUser;
    static WebCart webcart1;
    static Account acc1;
    static WebStore Ws1;
    static CartItem cartItem1;
    static CartDeliveryGroup cartDeliveryGroup1;
    static Pricebook2 pricebook2;
    static Entity__c entityc;
    
    static{       
        System.runAs(adminUser){
            // Insert Account
            acc1 = new Account(
                Name = 'Acc1',
                Type__c='001',
                BillingStreet = 'Test',
                BillingCity = 'Test',
                BillingCountry = 'Italy',
                BillingPostalCode = '12345',
                National_ID_Exception__c='Creation In progress',
                ERP_Number__c='ERP_000004'
                
            );
            insert acc1;
            
            //Insert Webstore
            ws1= new WebStore(
                Name='wstest'
            );
            insert ws1;
            
            // Insert WebCart
            webcart1 = new WebCart(
                Name = 'Cart1',
                Status='Closed',
                AccountId=acc1.id,
                WebStoreId=ws1.Id
                // Bank_City__c='bankcity',
                // Bank_Name__c='neuflize paris',
                // BIC__c='NSMBFRPPXXX',
                // IBAN__c='FR7630788009000134418000167',
                // UMR__c='++0019839008560300'
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
                Type='Product', 
                Name='TestProduct', 
                CartDeliveryGroupId=cartDeliveryGroup1.Id
            );
            insert cartItem1;

            //Insert entity
            // entityc= new Entity__c(
            //     Name='testentityc',
            //     City__c ='Lyon', 
            //     Country__c='France', 
            //     ICS__c='123', 
            //     Postal_Code__c='69009', 
            //     Street__c='52 quai Paul Sedallian',
            //     Entity_code__c = '1002'
            // );
            // insert entityc;

            Entity__c  CegidEntity =  new UTIL_TestFactory.EntityFactory().createEntity();
            insert CegidEntity; 
            
            //Insert Pricebook2
            pricebook2 pb= new Pricebook2(
                Name='TestPricebook',
                Cegid_Entity__c= CegidEntity.id,
                //Entity_ICS__c='To be defined',
                IsActive = true
                
            );
            insert pb;
            
           
            
        }
    }
    /***
    * @author      : Trilochnah - Comforth Karoo
    * @date		   : 27/10/21
    * @description : 
    ***/
    static testMethod void testGetData(){
        
        System.runAs(adminUser){
            
            List<Id> listWebCart= new List<Id>();
            for(WebCart wc:[SELECT Id,AccountId,Account.Name,WebStore.Name,WebStoreId,Owner.Name  FROM WebCart 
            where Name = 'Cart1']){
                listWebCart.add(wc.Id);
            }
        
            Test.setMock(HttpCalloutMock.class, new  QuoteGetMandatSepa_Mock());   
            Test.startTest();
                B2B_QuoteGetMandatSepa.getData(listWebCart);       
            Test.stopTest();  
   
        }
            
    }

    static testMethod void testWSError() {
        List<Id> listWebCart= new List<Id>();
        for(WebCart wc:[SELECT Id,AccountId,Account.Name,WebStore.Name,WebStoreId,Owner.Name  FROM WebCart 
        where Name = 'Cart1']){
            listWebCart.add(wc.Id);
        }
        
        Test.setMock(HttpCalloutMock.class, new MockErrorResponse());   
        Test.startTest();         
           Map<String, Object> mapResp = B2B_QuoteGetMandatSepa.getData(listWebCart); 
        Test.stopTest();        
    }

    private class MockErrorResponse implements HttpCalloutMock {  
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"error": {"errorCode": 500, "errorDateTime": "2020-08-14T02:38:54", "errorMessage": "Pas de retour sur cette sélection", "errorDescription": "Pas de retour sur cette sélection"} }');
            res.setStatusCode(500);
            return res;
        }
    }
    
}