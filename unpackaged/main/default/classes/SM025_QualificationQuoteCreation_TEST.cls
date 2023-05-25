/**
* @author Easyfront Consulting
* @date 2022/09
* @description Test class for SM025_QualificationQuoteCreation          
*/
@isTest
public class SM025_QualificationQuoteCreation_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static final String PRIMARY_CONTACT_EMAIL = 'primarycontact@email.com';
    @testSetup static void setup(){
        System.runAs(adminUser){ 
            Insert new BypassTrigger__c(SetupOwnerId = UserInfo.getOrganizationId(), Activatetrigger__c = True); 
            
            Test.startTest();
            //create account
            List<Account> listAcc = new List<Account>();
            for(Integer i=0; i<1;i++ ){
                listAcc.add( new UTIL_TestFactory.AccountFactory().createAccountWithNature(i));
            }
            insert listAcc;
            
            //create contact
            Contact primaryContact = new UTIL_TestFactory.ContactFactory().createContact(listAcc[0].Id);
            primaryContact.Email = PRIMARY_CONTACT_EMAIL;
            insert primaryContact;
            
            PriceBook2 standardPricebook = new UTIL_TestFactory.PricebookFactory().activateStdPriceBook();
            
            //create opportunity
            List<Opportunity> listOpp = new List<Opportunity>();
            for(Integer i=0; i<1;i++){
                listOpp.add(new UTIL_TestFactory.OpportunityFactory().createOpportunity(listAcc[i].Id, false, false));
            }
            insert listOpp;
            
            
            //create product2
            List<Product2> listProduct = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'Cost'),
                    new UTIL_TestFactory.ProductFactory().createProduct('Product', 'Cost'),
                    new UTIL_TestFactory.ProductFactory().createProduct('Product', 'Cost')
                    };
                        insert listProduct;
            
            List<PricebookEntry> listPBE = new List<PricebookEntry>{
                new UTIL_TestFactory.PricebookFactory().createPriceBookEntry(standardPricebook.id, listProduct[0].id)
                    };
                        insert listPBE; 
            
            //create oppline item
            List<OpportunityLineItem> listOppLineItem = new List<OpportunityLineItem>{
                new UTIL_TestFactory.OpportunityFactory().createOppLineItem(listOpp[0].Id, listPBE[0].Id),
                    new UTIL_TestFactory.OpportunityFactory().createOppLineItem(listOpp[0].Id, listPBE[0].Id),
                    new UTIL_TestFactory.OpportunityFactory().createOppLineItem(listOpp[0].Id, listPBE[0].Id)
                    };
                        insert listOppLineItem;
            
            //create quote in mass (cannot create more than that because of SOQL & CPU limit exceeded from CPQ SBQQ package)
            List<SBQQ__Quote__c> listQuotes = new List<SBQQ__Quote__c>();
            for(Integer i=0; i<1;i++ ){
                listQuotes.add(new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteV2(listOpp[i].Id, listAcc[i].Id, primaryContact.Id, listAcc[i].Id));
            }
            insert listQuotes;
            
            listOpp[0].SBQQ__PrimaryQuote__c = listQuotes[0].Id;
            update listOpp;
            
            //Create Quote Line
            Offer__c off = new Offer__c(Name = 'Offer Test', API_Name__c='APINameTest__c', Generate_Sheet_in_PS_Context__c = true);
            insert off;
            SBQQ__QuoteLine__c qutLine= new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteLine(listQuotes[0].Id, listProduct[0].Id);
            qutLine.StructureLevel1__c = '140';
            qutLine.Offer_Lookup__c = off.Id;
            insert qutLine;

            //Create Qualification Sheet
            List<Qualification_Sheet__c> listQS = UTIL_TestFactory.createQualificationSheetOnQuote(listQuotes);
            
            For(Qualification_Sheet__c qs:listQS){
                qs.Offer__c = off.Id;
            }
            insert listQS;
            
            Test.stopTest();
        }
    }
    
    //Test method for qualificationsheetsCreationUpdated
    static testMethod void qualificationsheetsCreationUpdated_Test(){
        List<SBQQ__Quote__c> listQuotes = [SELECT Id FROM SBQQ__Quote__c];
        Set<Id> quoteIds = new Set<Id>();
        For(SBQQ__Quote__c q:listQuotes){
            quoteIds.add(q.Id);
        }
        SM025_QualificationQuoteCreation.qualificationsheetsCreationUpdated(quoteIds);
    }
    
    //Test method for qualificationQuoteCreation
    static testMethod void qualificationQuoteCreation_Test(){
        List<SBQQ__Quote__c> listQuotes = [SELECT Id FROM SBQQ__Quote__c];
        Set<Id> quoteIds = new Set<Id>();
        For(SBQQ__Quote__c q:listQuotes){
            quoteIds.add(q.Id);
        }
        SM025_QualificationQuoteCreation.qualificationQuoteCreation(quoteIds);
    }
}