/**
* @author Keshav M - Comforth Karoo
* @date 2021-19-03
* @description Test class for SM013_QuoteLineCalculation
*/
@isTest
public class SM013_QuoteLineCalculation_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static final String PRIMARY_CONTACT_EMAIL = 'calcrollupcontact@email.com';
     
    @TestSetup static void setup(){ 
        System.runAs(adminUser){ 
            Insert new BypassTrigger__c(SetupOwnerId = UserInfo.getOrganizationId(), Activatetrigger__c = True); 

            Test.startTest(); //to prevent SOQL limits from SBQQ package
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
                Product2 prod = new UTIL_TestFactory.ProductFactory().createProduct('Product', 'Cost');
                prod.Family = '130';
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
                quote.AdminSAASContactFirstName__c = 'AAAA'+i; //used for order by SOQL
                quote.SBQQ__Status__c = 'Approved';
                listQuotes.add(quote);
            }
            insert listQuotes;
            Test.stopTest();
        }
    }
    
    public static List<SBQQ__QuoteLine__c> createQutLinesRecurring(){
        List<SBQQ__QuoteLine__c> listQuoteLine = new List<SBQQ__QuoteLine__c>();
        List<Product2> listProduct = [SELECT Id from Product2];
        
        for(SBQQ__Quote__c quote : [SELECT Id, AdminSAASContactFirstName__c 
                                    from SBQQ__Quote__c ORDER BY AdminSAASContactFirstName__c ASC]){
                                        for(Integer i=0; i<2;i++){
                                            SBQQ__QuoteLine__c qutLine= new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteLine(quote.Id, listProduct[i].Id);
                                            qutLine.SBQQ__NetPrice__c = 100;
                                            qutLine.StructureLevel1__c = SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_MAINT;
                                            qutLine.SBQQ__ChargeType__c = SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING;
                                            qutLine.TECH_CopyDiscountResult__c = 10;
                                            qutLine.TECH_CopyGrossTotal__c = 100;
                                            qutLine.Metric__c = '';
                                            qutLine.SBQQ__DefaultSubscriptionTerm__c = 1 ;
                                            listQuoteLine.add(qutLine);
                                            
                                            qutLine= new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteLine(quote.Id, listProduct[i].Id);
                                            qutLine.SBQQ__NetPrice__c = 200;
                                            qutLine.StructureLevel1__c = SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_LICENSES;
                                            qutLine.SBQQ__ChargeType__c = SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING;
                                            qutLine.TECH_CopyDiscountResult__c = 20;
                                            qutLine.TECH_CopyGrossTotal__c = 200;
                                            qutLine.Metric__c = '';
                                            qutLine.SBQQ__DefaultSubscriptionTerm__c = 1 ;
                                            listQuoteLine.add(qutLine);
                                            
                                            qutLine= new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteLine(quote.Id, listProduct[i].Id);
                                            qutLine.SBQQ__NetPrice__c = 300;
                                            qutLine.StructureLevel1__c = SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_SAAS;
                                            qutLine.SBQQ__ChargeType__c = SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING;
                                            qutLine.TECH_CopyDiscountResult__c = 30;
                                            qutLine.TECH_CopyGrossTotal__c = 300;
                                            qutLine.Metric__c = '';
                                            qutLine.SBQQ__DefaultSubscriptionTerm__c = 1 ;
                                            listQuoteLine.add(qutLine);
                                            
                                            qutLine= new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteLine(quote.Id, listProduct[i].Id);
                                            qutLine.SBQQ__NetPrice__c = 400;
                                            qutLine.StructureLevel1__c = SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_PROF_SERVICES;
                                            qutLine.SBQQ__ChargeType__c = SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING;
                                            qutLine.Category__c = '949'; //other
                                            qutLine.TECH_CopyDiscountResult__c = 40;
                                            qutLine.TECH_CopyGrossTotal__c = 400;
                                            qutLine.Metric__c = '';
                                            qutLine.SBQQ__DefaultSubscriptionTerm__c = 1 ;
                                            listQuoteLine.add(qutLine);
                                            
                                            qutLine= new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteLine(quote.Id, listProduct[i].Id);
                                            qutLine.SBQQ__NetPrice__c = 500;
                                            qutLine.SBQQ__ChargeType__c = SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING;
                                            qutLine.Category__c = SM006_CalculateQuoteLineRollUp.CATEGORY_CERTIFICATION; 
                                            qutLine.TECH_CopyDiscountResult__c = 50;
                                            qutLine.TECH_CopyGrossTotal__c = 500;
                                            qutLine.Metric__c = '';
                                            qutLine.SBQQ__DefaultSubscriptionTerm__c = 1 ;
                                            listQuoteLine.add(qutLine);
                                        }
                                        
                                    }
        return listQuoteLine;
        
    }
    
    /*static testMethod void testProcessBuilderAfter() {
        System.runAs(adminUser){
        	List<Product2> listProduct = [SELECT Id from Product2];
            List<SBQQ__Quote__c> listQuote =  [SELECT Id from SBQQ__Quote__c Limit 1];
            List<SBQQ__QuoteLine__c> listQuoteLine = new List<SBQQ__QuoteLine__c>();
            
            Case cas = new Case();
                
            Account acc = new UTIL_TestFactory.AccountFactory().createAccountWithNature(1);
            acc.ERP_Number__c = '90550294';
            acc.Industry = 'Association';
            acc.Phone = '12548541215';
            acc.BillingStreet = '3 Broughton Street';
            acc.BillingCountry='France';
            acc.BillingPostalCode = '2150';
            acc.BillingCity = 'Parramatta';
            acc.Tech_Contact_Direct__c = true;
            acc.Status__c = 'Validated';
            acc.BillingCountryCode = 'FR';
            acc.National_ID__c = '35896587421357';
            acc.IntercommunityVATnumber__c = 'FR45358965874';
            insert acc;
                
            Opportunity opp = new UTIL_TestFactory.OpportunityFactory().createOpportunity(acc.Id, false, false);
            insert opp;
            
            Contact primaryContact = new UTIL_TestFactory.ContactFactory().createContact(acc.Id);
            primaryContact.Email = PRIMARY_CONTACT_EMAIL+'Amendment';  
            insert primaryContact;
            
            SBQQ__Quote__c quote = new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteV2(opp.Id,acc.Id, primaryContact.Id, acc.Id);
            quote.SBQQ__DocumentStatus__c  = SM012_QuotePriceRule.DOCUMENTSTATUS;
            quote.Tech_CollectionStatus_Approved__c = true;
            quote.SBQQ__Opportunity2__c = opp.Id;

            Test.startTest();
            insert listQuoteLine;
            Test.stopTest();
        }
    }
    
    static testMethod void testTriggerBeforeInsert() {
        System.runAs(adminUser){
            List<SBQQ__QuoteLine__c> listQuoteLine = createQutLinesRecurring();
            Test.startTest();
            insert listQuoteLine;
            Test.stopTest();
        }
    }
    
    static testMethod void testTriggerBeforeUpdate() {
        System.runAs(adminUser){
            
            List<SBQQ__QuoteLine__c> listQuoteLine = createQutLinesRecurring();
            insert listQuoteLine;
            
            for(SBQQ__QuoteLine__c qutLine : listQuoteLine){
                qutLine.TECH_Subscription_Term__c = 2;
                qutLine.TECH_Saas_MRR__c = 10;
            }
            
            Test.startTest();        
            update listQuoteLine;        
            Test.stopTest();
            
            
        }
    }
	*/
    
    static testMethod void processBuilderAfter() {
        System.runAs(adminUser){
            List <SBQQ__QuoteLine__c> listQuoteLine1 = createQutLinesRecurring();
            //List<Case> lstCases = new List<Case>();
            insert listQuoteLine1;
            List <SBQQ__QuoteLine__c>listQuoteLine2 = [SELECT Id, Name,SBQQ__Quote__c,SBQQ__Product__c,SBQQ__Quantity__c,LastModifiedDate
                                                       		,Catalog__c,Metric__c,SBQQ__DefaultSubscriptionTerm__c
                                                            ,SBQQ__Product__r.Service_Book__c
                                                       FROM SBQQ__QuoteLine__c];
            
            Test.startTest();
            for(SBQQ__QuoteLine__c sql : listQuoteLine2){
                SBQQ__Quote__c quote = [SELECT Id,SBQQ__Status__c,ApprovalStatus__c,TECH_Passed_in_PS_OK_Status__c
                                        		,Payslips__c,Terms_of_Sale_and_Service_Booklets__c,Max_Saas_Contract_Duration__c
                                                ,SBQQ__Opportunity2__c
                                        FROM SBQQ__Quote__c 
                                        WHERE Id =:sql.SBQQ__Quote__c ];

                quote.SBQQ__Status__c = 'Approved';
                TH_QuoteLine.mapAllQuote.put(quote.Id,quote);
            }
            
            SM013_QuoteLineCalculation.processBuilderAfter(listQuoteLine2,true);
            //Test updateStatusToDraft
            SBQQ__QuoteLine__c sql3 = [SELECT Id, Name,SBQQ__Quote__c FROM SBQQ__QuoteLine__c LIMIT 1];
            SBQQ__Quote__c quote = [SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id =: sql3.SBQQ__Quote__c];
            quote.SBQQ__Status__c = 'PS Ok';
            update quote;
            delete sql3;
            Test.stopTest();
        }
    }
}