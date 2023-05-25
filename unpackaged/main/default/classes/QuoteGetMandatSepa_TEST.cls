/**
 * @author Brahim Boulmaarouf - Comforth
 * @date 2020-07-10
 * @modified 2020-08-14 - Shamina 
 * @description QuoteGetMandatSepa_TEST
 *              
*/
@isTest
public class QuoteGetMandatSepa_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static final String PRIMARY_CONTACT_EMAIL = 'primarycontact@email.com';
    static BypassTrigger__c bt= new BypassTrigger__c();

    @testSetup static void setup(){
        System.runAs(adminUser){ 
            bt.Activatetrigger__c = false;
            bt.SetupOwnerId = UserInfo.getOrganizationId();
            insert bt;
            
            SBQQ__Quote__c  ItemQuote = new SBQQ__Quote__c();
            Account acc = new UTIL_TestFactory.AccountFactory().createAccount();
            acc.ERP_Number__c='1';
            insert acc;

            //create contact
            Contact primaryContact = new UTIL_TestFactory.ContactFactory().createContact(acc.Id);
            primaryContact.Email = PRIMARY_CONTACT_EMAIL;
            insert primaryContact;

            PriceBook2 standardPricebook = new UTIL_TestFactory.PricebookFactory().activateStdPriceBook();               
            update standardPricebook;  
         
            //create opportunity
            Opportunity opp = new UTIL_TestFactory.OpportunityFactory().createOpportunity(acc.Id, false, false);
            opp.Pricebook2Id = standardPricebook.Id; 
            insert opp;

            //create product2
            List<Product2> listProduct = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List')
            };
            insert listProduct;

            List<PricebookEntry> listPBE = new List<PricebookEntry>{
                new UTIL_TestFactory.PricebookFactory().createPriceBookEntry(standardPricebook.id, listProduct[0].id),
                new UTIL_TestFactory.PricebookFactory().createPriceBookEntry(standardPricebook.id, listProduct[1].id),
                new UTIL_TestFactory.PricebookFactory().createPriceBookEntry(standardPricebook.id, listProduct[2].id)
            };
            insert listPBE; 

            //create oppline item
            List<OpportunityLineItem> listOppLineItem = new List<OpportunityLineItem>{
                new UTIL_TestFactory.OpportunityFactory().createOppLineItem(opp.Id, listPBE[0].Id),
                new UTIL_TestFactory.OpportunityFactory().createOppLineItem(opp.Id, listPBE[1].Id),
                new UTIL_TestFactory.OpportunityFactory().createOppLineItem(opp.Id, listPBE[2].Id)
            };
            insert listOppLineItem;
        
            Entity__c  CegidEntity =  new UTIL_TestFactory.EntityFactory().createEntity();
            insert    CegidEntity; 
            
            standardPricebook.Cegid_Entity__c=CegidEntity.id;
            update standardPricebook; 
            
            ItemQuote =new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_Quote(opp.Id, acc.Id, primaryContact.Id);
            insert ItemQuote;
             
               
            Pricebook2 priceBook = new Pricebook2(
                Name = 'Example Price Book',
                Description = 'This is the Price Book description.',
                IsActive = true,
                Cegid_Entity__c = CegidEntity.Id
            );
            insert priceBook;
              
            Opportunity opp02 = new UTIL_TestFactory.OpportunityFactory().createOpportunity(acc.Id, false, false);
            opp02.Pricebook2Id = priceBook.Id; 
            insert opp02;                       
           
            SBQQ__Quote__c  ItemQuote02 = new SBQQ__Quote__c();
            ItemQuote02 =new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_Quote(opp02.Id, acc.Id, primaryContact.Id);
            insert ItemQuote02;              
        }        
    }
    
    static testMethod void testgetData() {
        List<SBQQ__Quote__c>  ListQuote= [select Id, SBQQ__PriceBook__r.Cegid_Entity__c  FROM SBQQ__Quote__c 
            where SBQQ__PrimaryContact__r.Email = :PRIMARY_CONTACT_EMAIL];
        
        Test.setMock(HttpCalloutMock.class, new  QuoteGetMandatSepa_Mock());   
        Test.startTest();         
           for (SBQQ__Quote__c item :ListQuote )
           {
             QuoteGetMandatSepa.getData(Item.id);    
           }        
           string str='FR7616807004008100646521113-CCBPFRPPGRE-000281939037581100-BEAUREPAIRE-BEAUREPAIRE';   
           QuoteGetMandatSepa.SaveMondat(ListQuote[0].id,  str );
        Test.stopTest();
        
        //Shamina 2020-08-14 - adding missing asserts
        SBQQ__Quote__c qutUpdated= [select  IBAN__c,BIC__c, UMR__c,Bank_Name__c, Bank_City__c  FROM SBQQ__Quote__c 
            where Id =:listQuote[0].id LIMIT 1];
        system.assertEquals('FR7616807004008100646521113', qutUpdated.IBAN__c, 'IBAN updated');   
        system.assertEquals('CCBPFRPPGRE', qutUpdated.BIC__c, 'BIC updated');   
        system.assertEquals('000281939037581100', qutUpdated.UMR__c, 'UMR updated');   
        system.assertEquals('BEAUREPAIRE', qutUpdated.Bank_Name__c, 'Bank name updated');   
        system.assertEquals('BEAUREPAIRE', qutUpdated.Bank_City__c, 'Bank city updated');   
   
    }

    static testMethod void testWSError() {
        //B-0680 (Shamina 2020-08-14)
        SBQQ__Quote__c quote = [select Id, SBQQ__PriceBook__r.Cegid_Entity__c  FROM SBQQ__Quote__c 
        where SBQQ__PrimaryContact__r.Email = :PRIMARY_CONTACT_EMAIL limit 1];
        
        Test.setMock(HttpCalloutMock.class, new MockErrorResponse());   
        Test.startTest();         
           Map<String, Object> mapResp = QuoteGetMandatSepa.getData(quote.id);    
           String message = (String)mapResp.get('error');
           System.assertEquals(true, message.contains('Pas de retour sur cette sélection'), 'WS Callout failed ');    
           
        Test.stopTest();        
    }


    /*
    * @author Shamina - Comforth
    * @created 2020-08-14
    * @description Mock class error
    */
    private class MockErrorResponse implements HttpCalloutMock {
        /**
        * @author Shamina - Comforth
        * @date 2020-08-14
        * @description Generate and returns mock error
        * @param req HTTPRequest Mock request
        * @return HTTPResponse Mock response
        */    
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"error": {"errorCode": 500, "errorDateTime": "2020-08-14T02:38:54", "errorMessage": "Pas de retour sur cette sélection", "errorDescription": "Pas de retour sur cette sélection"} }');
            res.setStatusCode(500);
            return res;
        }
    }
}