/**
 * @author Keshav M - Comforth Karoo
 * @date 2020-09-11
 * @description Test AmendCopyLineItemsController_TEST
*/
@isTest
public with sharing class AmendCopyLineItemsController_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static final String PRIMARY_CONTACT_EMAIL = 'AmendCopyLineItemsController@email.com';

    @TestSetup static void setup(){ 
        System.runAs(adminUser){ 
            
                //create account
                Account acc = new UTIL_TestFactory.AccountFactory().createAccount();
                insert acc;

                //create contact
                Contact primaryContact = new UTIL_TestFactory.ContactFactory().createContact(acc.Id);
                primaryContact.Email = PRIMARY_CONTACT_EMAIL;
                insert primaryContact;

                PriceBook2 standardPricebook = new UTIL_TestFactory.PricebookFactory().activateStdPriceBook();

                //List<Territory2> listTerritory = [Select Id , Expertise__c from Territory2 where  Expertise__c='200']; 
                //create opportunity
                Opportunity opp = new UTIL_TestFactory.OpportunityFactory().createOpportunity(acc.Id, false, false);
                //opp.Territory2Id = listTerritory[0].Id; //required by flow Quote Init - RCC
                opp.Pricebook2Id = standardPricebook.Id; 
                insert opp;

                //create product2
                List<Product2> listProduct = new List<Product2>();
                for(Integer i=0; i<3;i++ ){
                    Product2 prod = new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List');
                    listProduct.add(prod);
                }
                insert listProduct;

                List<PricebookEntry> listPBE = new List<PricebookEntry>();
                for(Integer i=0; i<3;i++ ){
                    PricebookEntry pbe = new UTIL_TestFactory.PricebookFactory().createPriceBookEntry(standardPricebook.id, listProduct[i].id);
                    listPBE.add(pbe);
                }
                insert listPBE;

                //create quote in mass (cannot create more than that because of SOQL & CPU limit exceeded from CPQ SBQQ package)
                List<SBQQ__Quote__c> listQuotes = new List<SBQQ__Quote__c>();

                for(Integer i=0; i<2;i++ ){
                    SBQQ__Quote__c quote = new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_Quote(opp.Id, acc.Id, primaryContact.Id);
                    listQuotes.add(quote);
                }
                insert listQuotes;

                List<SBQQ__QuoteLine__c> listQuotesLine = new List<SBQQ__QuoteLine__c>();
                //for(Integer i=0; i<2;i++ ){
                    SBQQ__QuoteLine__c quote = new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteLineCPQ(listQuotes[0].Id,listProduct[0].id,true);
                    listQuotesLine.add(quote);
                //}
                insert listQuotesLine;

                //Insert Group 
                List<SBQQ__QuoteLineGroup__c> listQuotesGroup = new List<SBQQ__QuoteLineGroup__c>();
                for(Integer i=0; i<2;i++ ){
                    SBQQ__QuoteLineGroup__c quoteGroup = new UTIL_TestFactory.SBQQ_QuoteFactory().createQuoteLineGroupCPQ(listQuotes[i].Id,'Test',1);
                    listQuotesGroup.add(quoteGroup);
                }
                insert listQuotesGroup;

               
        }
    }

    @isTest static void TestCopyLineItems() {
        System.runAs(adminUser){
            List<SBQQ__Quote__c> listQuotes = [SELECT Id FROM SBQQ__Quote__c limit 1];
            Test.startTest();
                ApexPages.currentPage().getParameters().put('quoteId', listQuotes[0].Id);
                AmendCopyLineItemsController testCopyLineItems = new AmendCopyLineItemsController();
                testCopyLineItems.copyQuoteLineItems();
            Test.stopTest();
        }
    }

    @isTest static void TestCopyLineItemsNoId() {
        System.runAs(adminUser){
            Test.startTest();
                ApexPages.currentPage().getParameters().put('quoteId', null);
                AmendCopyLineItemsController testCopyLineItems = new AmendCopyLineItemsController();
                testCopyLineItems.copyQuoteLineItems();
            Test.stopTest();
        }
    }
    
}