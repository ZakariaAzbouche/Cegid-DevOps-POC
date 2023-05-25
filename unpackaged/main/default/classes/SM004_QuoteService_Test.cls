/**
 * @description       : Test class for SM004_QuoteService
 * @author            : Easyfront Consulting
 * @group             : 
 * @created on: 16-11-2022
**/
@isTest
public with sharing class SM004_QuoteService_Test {

    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static final String PRIMARY_CONTACT_EMAIL = 'calcrollupcontact@email.com';

    @TestSetup 
    static void setup(){    
        //testing as admin because of issues with CPQ rights when testing as Cegid sales
        System.runAs(adminUser){      
            Insert new BypassTrigger__c(SetupOwnerId = UserInfo.getOrganizationId(), Activatetrigger__c = true);
            
            Test.startTest(); //to prevent SOQL limits from SBQQ package
            
            //create account
            Account acc = new UTIL_TestFactory.AccountFactory().createAccount();
            acc.Nature__c = 'PRO';
            acc.Risk_Level__c = 'Risque élevé';
            insert acc;
            
            //create contact
            Contact primaryContact = new UTIL_TestFactory.ContactFactory().createContact(acc.Id);
            primaryContact.Email = PRIMARY_CONTACT_EMAIL;
            insert primaryContact;
            
            PriceBook2 standardPricebook = new UTIL_TestFactory.PricebookFactory().activateStdPriceBook();
            
            //create opportunity
            Opportunity opp = new UTIL_TestFactory.OpportunityFactory().createOpportunity(acc.Id, false, false);
            opp.Pricebook2Id = standardPricebook.Id; 
            insert opp;
            
            //create product2
            List<Product2> listProduct = new List<Product2>();
            for(Integer i=0; i<3;i++ ){
                Product2 prod = new UTIL_TestFactory.ProductFactory().createProduct('Product', 'Cost');
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
                quote.ApprovalStatus__c = 'Pending';
                quote.CurrencyIsoCode = 'EUR';
                quote.Billing_Account__c = acc.Id;
                listQuotes.add(quote);
            }
            insert listQuotes;
            
            List<SBQQ__QuoteLine__c> listQuoteLine = new List<SBQQ__QuoteLine__c>();
            for(Integer i=0; i<2;i++){
                SBQQ__QuoteLine__c qutLine= new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteLine(listQuotes[i].Id, listProduct[i].Id);
                qutLine.SBQQ__NetPrice__c = 100;
                qutLine.StructureLevel1__c = SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_MAINT;
                qutLine.SBQQ__ChargeType__c = SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING;
                qutLine.TECH_CopyDiscountResult__c = 10;
                qutLine.TECH_CopyGrossTotal__c = 100;
                qutLine.SBQQ__Discount__c = 5;
                //qutLine.SBQQ__AdditionalDiscountAmount__c = 100;
                listQuoteLine.add(qutLine);
            }
            insert listQuoteLine;
            
            //Create Approval Chain for Discount appro
            sbaa__ApprovalChain__c approChain = new sbaa__ApprovalChain__c(Name = 'Discount Workflow', sbaa__TargetObject__c='SBQQ__Quote__c');
            insert approChain;
            //Create Approval Rule
            sbaa__ApprovalRule__c approRule = new sbaa__ApprovalRule__c(sbaa__ApprovalChain__c=approChain.Id, Name='Discount > Level 1', sbaa__TargetObject__c='SBQQ__Quote__c', sbaa__ApprovalStep__c=1, sbaa__Active__c=true);
            insert approRule;
            //Create Approval
            sbaa__Approval__c appro = new sbaa__Approval__c(sbaa__ApprovalChain__c=approChain.Id, sbaa__Rule__c=approRule.Id, Quote__c=listQuotes[0].Id, sbaa__Status__c='Approved',sbaa__ApprovalStep__c =1, sbaa__RecordField__c='Quote__c');
            insert appro;
            
            //Create Approval Chain for RCC appro
            sbaa__ApprovalChain__c approChainRCC = new sbaa__ApprovalChain__c(Name = 'RCC Chain', sbaa__TargetObject__c='SBQQ__Quote__c');
            insert approChainRCC;
            //Create Approval Rule
            sbaa__ApprovalRule__c approRuleRCC = new sbaa__ApprovalRule__c(sbaa__ApprovalChain__c=approChain.Id, Name='Approval RCC - Default Level 1', sbaa__TargetObject__c='SBQQ__Quote__c', sbaa__ApprovalStep__c=1, sbaa__Active__c=true);
            insert approRuleRCC;
            //Create Approval
            sbaa__Approval__c approRCC = new sbaa__Approval__c(sbaa__ApprovalChain__c=approChainRCC.Id, sbaa__Rule__c=approRuleRCC.Id, Quote__c=listQuotes[0].Id, sbaa__Status__c='Approved',sbaa__ApprovalStep__c =1, sbaa__RecordField__c='Quote__c');
            insert approRCC;
            //Create Approval Rule
            sbaa__ApprovalRule__c approRuleRCCTeamLeader = new sbaa__ApprovalRule__c(sbaa__ApprovalChain__c=approChain.Id, Name='RCC Team Leader Validation', sbaa__TargetObject__c='SBQQ__Quote__c', sbaa__ApprovalStep__c=1, sbaa__Active__c=true);
            insert approRuleRCCTeamLeader;
            //Create Approval
            sbaa__Approval__c approRCCTeamLeader = new sbaa__Approval__c(sbaa__ApprovalChain__c=approChainRCC.Id, sbaa__Rule__c=approRuleRCCTeamLeader.Id, Quote__c=listQuotes[0].Id, sbaa__Status__c='Approved',sbaa__ApprovalStep__c =1, sbaa__RecordField__c='Quote__c');
            insert approRCCTeamLeader;
            
            //Create Approval Chain for Discount appro
            sbaa__ApprovalChain__c approChainStatus = new sbaa__ApprovalChain__c(Name = 'Discount Workflow', sbaa__TargetObject__c='SBQQ__Quote__c');
            insert approChainStatus;
            //Create Approval Rule
            sbaa__ApprovalRule__c approRuleStatus = new sbaa__ApprovalRule__c(sbaa__ApprovalChain__c=approChainStatus.Id, Name='Discount > Level 1', sbaa__TargetObject__c='SBQQ__Quote__c', sbaa__ApprovalStep__c=1, sbaa__Active__c=true);
            insert approRuleStatus;
            //Create Approval
            sbaa__Approval__c approStatus = new sbaa__Approval__c(sbaa__ApprovalChain__c=approChainStatus.Id, sbaa__Rule__c=approRuleStatus.Id, Quote__c=listQuotes[0].Id, sbaa__Status__c='Assigned',sbaa__ApprovalStep__c =1, sbaa__RecordField__c='Quote__c');
            insert approStatus;
            
            //Create RCC Conditions
            RCC_Condition__c rcc = new RCC_Condition__c(Account_Nature__c = 'PRO', RCC_Workflow_Level__c='RCC Team Leader', Account_Risk_Level__c = 'Risque élevé', One_Time_Total__c= 0, Account_Aston_Amount__c=0,Account_Aston_Delay__c='0',Recurring_Total_Monthly__c=0);
            insert rcc;
            
            Id caseProSerReqRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Professional_Services_Request').getRecordTypeId();
            Case cas = new Case(Subject='Test',Description='test',ClosedDate=date.TODAY(),Opportunity__c=opp.Id,recordTypeId = caseProSerReqRecordId,Quote__c=listQuotes[0].Id);
            insert cas;
            
            Test.stopTest();
        }
    }
    
    //Test method for approvalManagementAfterValidation
    @isTest static void approvalManagementAfterValidation_test() {
        
        List<SBQQ__Quote__c> listQuotes = [SELECT Id,SBQQ__Status__c,ApprovalStatus__c,Additional_discount_reason__c,OwnerId FROM SBQQ__Quote__c LIMIT 1];
        User u = new User(Id=listQuotes[0].OwnerId,BypassVR__c=true);
        update u;
        
        System.runAs(adminUser) {
            listQuotes[0].ApprovalStatus__c = 'Approved';
            listQuotes[0].Additional_discount_reason__c = '001';
            listQuotes[0].SBQQ__Status__c = 'Approved';
            Test.startTest();                
            update listQuotes[0];
            Test.stopTest();
        }
    }
    //Test method for rccApprovalCalculation
    @isTest static void rccApprovalCalculation_test() {
        Set<Id> setQuoteIds = new Set<Id>();
        Set<Id> setAccountIds = new Set<Id>();
        for(SBQQ__Quote__c quo:[SELECT Id,SBQQ__Status__c,ApprovalStatus__c, Billing_Account__c FROM SBQQ__Quote__c]){
            setQuoteIds.add(quo.Id);
            setAccountIds.add(quo.Billing_Account__c);
        }
        Test.startTest();                
        SM004_QuoteService.rccApprovalCalculation(setQuoteIds);
        SM004_QuoteService.rccApprovalCalculationFromAccount(setAccountIds);
        Test.stopTest();
    }
    //Test method for contractTypeApprovalCalculation
    @isTest static void contractTypeApprovalCalculation_test() {
        List<SBQQ__Quote__c> listQuotes = [SELECT Id,SBQQ__Status__c,ApprovalStatus__c FROM SBQQ__Quote__c LIMIT 1];
        listQuotes[0].OriginalPayment_Method__c = 'Debit';
        listQuotes[0].Payment_Method__c = 'Bank Transfert';
        Test.startTest();                
        update listQuotes[0];
        listQuotes[0].Payment_Method__c = 'Bank Transfert';
        update listQuotes[0];
        Test.stopTest();
    }
    
    public static List<SBQQ__QuoteLine__c> createQutLinesRecurring(){
        List<SBQQ__QuoteLine__c> listQuoteLine = new List<SBQQ__QuoteLine__c>();
        List<Product2> listProduct = [SELECT Id from Product2];
        
        for(SBQQ__Quote__c quote : [SELECT Id, AdminSAASContactFirstName__c 
                                    from SBQQ__Quote__c ORDER BY AdminSAASContactFirstName__c ASC]){
                                        for(Integer i=0; i<1;i++){
                                            SBQQ__QuoteLine__c qutLine= new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteLine(quote.Id, listProduct[i].Id);
                                            qutLine.SBQQ__NetPrice__c = 100;
                                            qutLine.StructureLevel1__c = SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_MAINT;
                                            qutLine.SBQQ__ChargeType__c = SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING;
                                            qutLine.TECH_CopyDiscountResult__c = 10;
                                            qutLine.TECH_CopyGrossTotal__c = 100;
                                            qutLine.Metric__c = '';
                                            qutLine.SBQQ__DefaultSubscriptionTerm__c = 1 ;
                                            qutLine.Waterfall_Gross_Total__c = 2;
                                            qutLine.SBQQ__Discount__c = 2;
                                            qutLine.SBQQ__ChargeType__c = 'One-Time';	
                                            qutLine.SBQQ__SubscriptionTerm__c = 1;
                                            listQuoteLine.add(qutLine);
                                            
                                        }
                                        
                                    }
        insert listQuoteLine;
        return listQuoteLine;
        
    }
    
    /*static testMethod void testCalculateSwing() {
        System.runAs(adminUser){
            List<SBQQ__QuoteLine__c> listQuoteLine = createQutLinesRecurring();
            Test.startTest();

            SBQQ__Quote__c quote = [SELECT id,Sale_Purpose__c FROM SBQQ__Quote__c LIMIT 1];
            system.debug('MCU quote.Sale_Purpose__cc : ' + quote.Sale_Purpose__c);
            quote.Sale_Purpose__c = '613';
            update quote;
            
            update listQuoteLine;
            
            SBQQ__QuoteLine__c ql = [SELECT id,Subscribed_Total__c,NetTotal_Display__c,SBQQ__Quote__r.Sale_Purpose__c  
                                           ,SBQQ__ChargeType__c
                                     FROM SBQQ__QuoteLine__c LIMIT 1 ];
            

            system.debug('MCU ql.SBQQ__Quote__r.Sale_Purpose__c : ' + ql.SBQQ__Quote__r.Sale_Purpose__c);
            system.debug('MCU ql.SBQQ__ChargeType__c : ' + ql.SBQQ__ChargeType__c);
            system.debug('MCU ql.Subscribed_Total__c : ' + ql.Subscribed_Total__c);
            system.debug('MCU ql.NetTotal_Display__c  : ' + ql.NetTotal_Display__c );
            Test.stopTest();
        }
    }*/
    
    static testMethod void testAccount0() {

        System.runAs(adminUser) {
            List<Account> lisAccount = new List<Account>();
            Set<Id> setAccIds = new set<Id>();

            for(Account acc:[SELECT Id,Name, Amount_of_delay_sup_30_days__c,Amount_of_delay_0_1_month__c FROM Account]){
                acc.Amount_of_delay_0_1_month__c = 11;
                lisAccount.add(acc);
                setAccIds.add(acc.Id);
            }

            Test.startTest();        
                update lisAccount;        
            Test.stopTest();

            List<SBQQ__Quote__c> listquote = [SELECT Id,Launch_RCC_Workflow_Lv1__c,Billing_Account__c FROM SBQQ__Quote__c WHERE Billing_Account__c IN:setAccIds AND Launch_RCC_Workflow_Lv1__c = true];

            for(SBQQ__Quote__c q:listquote){
                System.assertEquals(true,q.Launch_RCC_Workflow_Lv1__c);
            }
            
        }

    }
    
    @isTest static void updateChildRecords_TEST() {
        System.runAs(adminUser){
            List<SBQQ__Quote__c> listQuotes = [SELECT Id,SBQQ__Status__c 
                                               FROM SBQQ__Quote__c
                                               WHERE AdminSAASContactFirstName__c = 'AAAA0' limit 1];
            Set<Id> setQuoIds = new Set<Id>();
            listQuotes[0].SBQQ__Status__c = 'Rejected';
            update listQuotes[0];
            setQuoIds.add(listQuotes[0].Id);
            system.debug('MCU listQuotes : ' + listQuotes);
            Test.startTest();
				SM004_QuoteService.closeQuoteChildRecords(setQuoIds);
            Test.stopTest();
        }
    }
    
     @isTest static void manageNewQuoteAmendment_TEST() {
        System.runAs(adminUser){
            Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
            Account acc = [SELECT Id FROM Account LIMIT 1];
            Contact primaryContact = [SELECT Id FROM Contact LIMIT 1];
            SBQQ__Quote__c quote = new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_Quote(opp.Id, acc.Id, primaryContact.Id);
            quote.SBQQ__Type__c = SM004_QuoteService.TYPEAMENDMENT;
            Test.startTest();
            insert quote;
            Test.stopTest();
        }
    }
    
}