/**
* @author Keshav M - Comforth
* @date 2020-11-28
* @description SM012_QuotePriceRule_TEST          
*/
@isTest
public class SM012_QuotePriceRule_TEST {
 
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

            // Account accPartner = new UTIL_TestFactory.AccountFactory().createAccountPartner();
            // insert accPartner;

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
            //listOpp[0].Partner_Distributor__c  = accPartner.Id;
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


            //Create Rcc Conditions
            List<RCC_Condition__c> listRccConditon = new List<RCC_Condition__c>();
            for(Integer i=0; i<2;i++){
                listRccConditon.add(new UTIL_TestFactory.RCC_ConditionFactory().createRccCondition('CLI','Risque moyen',5,5,'0',10,'RCC Team Leader'));
            }

            insert listRccConditon;
            
        Test.stopTest();


        }
    }

    static testMethod void testQuote() {
        System.runAs(adminUser){
            List<SBQQ__Quote__c> listQut = new List<SBQQ__Quote__c>();
            List<OpportunityLineItem> listOLI = [SELECT Id FROM OpportunityLineItem LIMIT 1];
            for(SBQQ__Quote__c qut : [SELECT Id,Launch_RCC_Workflow_Lv1__c,Launch_RCC_Workflow_Lv2__c, TargetedPriceForHardware__c, Name,One_Time_Total__c,HasOneTime__c,Recurring_Total_Monthly__c,HasRecurring__c, Billing_Account__r.Nature__c,Billing_Account__r.Risk_Level__c,
                                      Billing_Account__r.Amount_of_delay_0_1_month__c, Billing_Account__r.Amount_of_delay_1_month__c,Billing_Account__r.Amount_of_delay_3_months__c,Billing_Account__r.Amount_of_delay_6_months__c,
                                      Billing_Account__r.Amount_of_delay_12_months__c,Billing_Account__r.Amount_of_delay_over_24_months__c,Billing_Account__r.Total_Amount_of_delay__c
                                      FROM SBQQ__Quote__c limit 1]){
                                          qut.Purchase_Order__c = '2';
                                          qut.Purchase_Order_Temp__c = '10';
                                          qut.TargetedPriceForHardware__c = 12;
                                          qut.SBQQ__Status__c = 'Pending PS';
                                          listQut.add(qut);
                                      }
            
            Test.startTest();        
            update listQut;  
            delete listOLI;
            Test.stopTest();
        }
        
    }

    static testMethod void testQuoteRccConditionsACCOUNTUPDATE() {
        System.runAs(adminUser){
            List<SBQQ__Quote__c> listQut = new List<SBQQ__Quote__c>();
            
            Account acc = new UTIL_TestFactory.AccountFactory().createAccountWithNature(6);
            acc.National_ID_Exception__c = 'Empty on loading';
            acc.BillingCountry='France';
            acc.BillingPostalCode = '10457';
            acc.BillingCity = 'Test Cit7';
            insert acc;
            
            for(SBQQ__Quote__c qut : [SELECT Id,SBQQ__Account__c FROM SBQQ__Quote__c limit 1]){
                qut.SBQQ__Account__c  = acc.Id;
                qut.Billing_Account__c = acc.Id;
                listQut.add(qut);
            }
            
            Test.startTest();        
            update listQut;        
            Test.stopTest();
        }
    }

    static testMethod void testQuoteRccConditionsBILLINGUPDATE() {
        System.runAs(adminUser){
            List<SBQQ__Quote__c> listQut = new List<SBQQ__Quote__c>();
            
            Account acc = new UTIL_TestFactory.AccountFactory().createAccountWithNature(5);
            acc.National_ID_Exception__c = 'Empty on loading';
            acc.BillingCountry='France';
            acc.BillingPostalCode = '10453';
            acc.BillingCity = 'Test City3';
            insert acc;
            
            for(SBQQ__Quote__c qut : [SELECT Id,Billing_Account__c FROM SBQQ__Quote__c limit 1]){
                qut.Billing_Account__c  = acc.Id;
                listQut.add(qut);
            }
            
            Test.startTest();        
            update listQut;        
            Test.stopTest();
        }
    }

    static testMethod void testQuoteRccConditionsSHIPPINGACCUPDATE() {
        System.runAs(adminUser){
            List<SBQQ__Quote__c> listQut = new List<SBQQ__Quote__c>();
            
            Account acc = new UTIL_TestFactory.AccountFactory().createAccountWithNature(4);
            acc.National_ID_Exception__c = 'Empty on loading';
            acc.BillingCountry='France';
            acc.BillingPostalCode = '10454';
            acc.BillingCity = 'Test Cit4';
            insert acc;
            
            for(SBQQ__Quote__c qut : [SELECT Id,Shipping_Account__c FROM SBQQ__Quote__c limit 1]){
                qut.Shipping_Account__c  = acc.Id;
                listQut.add(qut);
            }
            
            Test.startTest();        
            update listQut;        
            Test.stopTest();
        }
    }

    static testMethod void testQuoteRccConditionsPAYERACCUPDATE() {
        System.runAs(adminUser){
            List<SBQQ__Quote__c> listQut = new List<SBQQ__Quote__c>();
            
            Account acc = new UTIL_TestFactory.AccountFactory().createAccountWithNature(3);
            acc.National_ID_Exception__c = 'Empty on loading';
            acc.BillingCountry='France';
            acc.BillingPostalCode = '10455';
            acc.BillingCity = 'Test City5';
            insert acc;
            
            for(SBQQ__Quote__c qut : [SELECT Id,Payer_Account__c FROM SBQQ__Quote__c limit 1]){
                qut.Payer_Account__c  = acc.Id;
                listQut.add(qut);
            }
            
            Test.startTest();        
            update listQut;        
            Test.stopTest();
        }
    }


    static testMethod void testQuoteApprovalPending() {
        System.runAs(adminUser){
            List<SBQQ__Quote__c> listQut = new List<SBQQ__Quote__c>();
            
            
            for(SBQQ__Quote__c qut : [SELECT Id,ApprovalStatus__c FROM SBQQ__Quote__c limit 1]){
                qut.ApprovalStatus__c  = SM012_QuotePriceRule.APPROVALSTATUSPENDING;
                listQut.add(qut);
            }
            
            Test.startTest();        
            update listQut;        
            Test.stopTest();
        }
    }

    static testMethod void testQuoteApprovalApproved() {
        System.runAs(adminUser){
            List<SBQQ__Quote__c> listQut = new List<SBQQ__Quote__c>();
            
            
           for(SBQQ__Quote__c qut : [SELECT Id,ApprovalStatus__c, SBQQ__Primary__c FROM SBQQ__Quote__c limit 1]){
                qut.ApprovalStatus__c  = SM012_QuotePriceRule.APPROVALSTATUSAPPROVE;
                qut.SBQQ__Primary__c = true;
                listQut.add(qut);
            }
            
            Test.startTest();        
            update listQut;        
            Test.stopTest();
        }
    }

    static testMethod void testQuoteApprovalRejected() {
        System.runAs(adminUser){
            List<SBQQ__Quote__c> listQut = new List<SBQQ__Quote__c>();
            
            
            for(SBQQ__Quote__c qut : [SELECT Id,ApprovalStatus__c FROM SBQQ__Quote__c limit 1]){
                qut.ApprovalStatus__c  = SM012_QuotePriceRule.APPROVALSTATUSREJECTED;
                listQut.add(qut);
            }
            
            Test.startTest();        
            update listQut;        
            Test.stopTest();
        }
    }

    static testMethod void testQuoteStatusPSOK() {
        System.runAs(adminUser){
            List<SBQQ__Quote__c> listQut = new List<SBQQ__Quote__c>();
            
            
            for(SBQQ__Quote__c qut : [SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c limit 1]){
                qut.SBQQ__Status__c  = SM012_QuotePriceRule.STATUSPSOK;
                listQut.add(qut);
            }
            
            Test.startTest();        
            update listQut;        
            Test.stopTest();
        }
    }

    

    static testMethod void testQuotePurchaseOrder() {
        System.runAs(adminUser){
            List<SBQQ__Quote__c> listQut = new List<SBQQ__Quote__c>();
            
            for(SBQQ__Quote__c qut : [SELECT Id,Purchase_Order_Temp__c,New_Bank_City_Temp__c,POMandatoryTemp__c FROM SBQQ__Quote__c limit 1]){
                qut.Purchase_Order_Temp__c  = '10';
                qut.New_Bank_City_Temp__c = 'paris';
                qut.POMandatoryTemp__c = 'non';
                listQut.add(qut);
            }
            
            Test.startTest();        
            update listQut;        
            Test.stopTest();
        }
    }

    static testMethod void testQuoteSalesPurposeUpsellOnly() {
        System.runAs(adminUser){
            List<SBQQ__Quote__c> listQut = new List<SBQQ__Quote__c>();
            
            Account acc = new UTIL_TestFactory.AccountFactory().createAccountWithNature(2);
            acc.National_ID_Exception__c = 'Empty on loading';
            acc.BillingCountry='France';
            acc.BillingPostalCode = '10451';
            acc.BillingCity = 'Test City 1';
            insert acc;
            
            
            Contract contr = new UTIL_TestFactory.ContractFactory().createContract(acc.Id, date.today(), 3);
            insert contr;
            
            for(SBQQ__Quote__c qut : [SELECT Id,Sale_Purpose__c FROM SBQQ__Quote__c limit 1]){
                qut.Sale_Purpose__c  = SM012_QuotePriceRule.SALESPURPOSEUPSELLONLY;
                qut.SBQQ__MasterContract__c = contr.Id;
                listQut.add(qut);
            }
            
            Test.startTest();        
            update listQut;        
            Test.stopTest();
        }
    }
  
    static testMethod void tesCompliance () {
        System.runAs(adminUser){
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
            insert quote;        
            Test.stopTest();
        }
    }


     static testMethod void testQuoteStatusDocumentStatus() {
         System.runAs(adminUser){
             List<SBQQ__Quote__c> listQutUpdate = new List<SBQQ__Quote__c>();
             List<SBQQ__Quote__c> listQut = [SELECT Id,SBQQ__DocumentStatus__c,Tech_CollectionStatus_Approved__c, SBQQ__Opportunity2__c FROM SBQQ__Quote__c limit 1];
             
             Account acc = new UTIL_TestFactory.AccountFactory().createAccountWithNature(1);
             insert acc;
             
             Opportunity opp = new UTIL_TestFactory.OpportunityFactory().createOpportunity(acc.Id, false, false);
             insert opp;
             
             
             for(SBQQ__Quote__c qut :listQut){
                 qut.SBQQ__DocumentStatus__c  = SM012_QuotePriceRule.DOCUMENTSTATUS;
                 qut.Tech_CollectionStatus_Approved__c = true;
                 qut.SBQQ__Opportunity2__c = opp.Id;
                 qut.SBQQ__Primary__c = true;
                 listQutUpdate.add(qut);
             }
             
             Test.startTest();        
             update listQutUpdate;        
             Test.stopTest();
         }
     }
    
     static testMethod void qualificationQuoteCreation() {
         System.runAs(adminUser){
             List<SBQQ__Quote__c> listQut = [SELECT Id,SBQQ__DocumentStatus__c,Tech_CollectionStatus_Approved__c
                                             		, SBQQ__Opportunity2__c, SBQQ__Account__c,Email_e_Billing__c
                                             FROM SBQQ__Quote__c limit 1];
             Set<Id> quoteIds = NEW sET<Id>{listQut[0].id};
             
             Test.startTest();        
             SM012_QuotePriceRule.qualificationQuoteCreation(quoteIds);   
             Test.stopTest();
             
         }
     }

    
     static testMethod void setAccountEbilling() {
         System.runAs(adminUser){
             List<SBQQ__Quote__c> listQut = [SELECT Id,SBQQ__DocumentStatus__c,Billing_Account__c,Tech_CollectionStatus_Approved__c
                                             		, SBQQ__Opportunity2__c, SBQQ__Account__c,Email_e_Billing__c
                                             FROM SBQQ__Quote__c limit 1];
             
             Test.startTest();        
             SM012_QuotePriceRule.setAccountEbilling(listQut);   
             Test.stopTest();
             
         }
     }
    
     static testMethod void setFraisDeDeplacement() {
         System.runAs(adminUser){
             List<SBQQ__Quote__c> listQuote1 = [SELECT Id,SBQQ__DocumentStatus__c,Tech_CollectionStatus_Approved__c
                                             		, SBQQ__Opportunity2__c, SBQQ__Account__c,Email_e_Billing__c
                                             FROM SBQQ__Quote__c limit 1];
             
             Test.startTest();        
             //SM012_QuotePriceRule.setFraisDeDeplacement(listQuote1);   
             Test.stopTest();
              
         }
     }
    
    static testMethod void setPriceRule_ASTONDELAY0() {
         System.runAs(adminUser){
             List<SBQQ__Quote__c> listQuote = [SELECT Id,SBQQ__DocumentStatus__c,Tech_CollectionStatus_Approved__c
                                             		, SBQQ__Opportunity2__c, SBQQ__Account__c,Email_e_Billing__c
                                               		, Billing_Account__c,One_Time_Total__c,Recurring_Total_Monthly__c
                                             FROM SBQQ__Quote__c limit 1];
             
             listQuote[0].SBQQ__SubscriptionTerm__c = 2;
             listQuote[0].Recurring_Maintenance_Amount__c = 2;
             
             update listQuote;
             
             List<RCC_Condition__c> listRccConditon = [SELECT Id FROM RCC_Condition__c limit 1];
             listRccConditon[0].Account_Nature__c = 'PRO';
             listRccConditon[0].Account_Aston_Amount__c = 0;
             
             update listRccConditon;
             
             Test.startTest();        
             //SM012_QuotePriceRule.setPriceRule(listQuote);   
             Test.stopTest();
             
         }
     }
    
    static testMethod void setPriceRule_ASTONDELAY1() {
         System.runAs(adminUser){
             List<SBQQ__Quote__c> listQuote = [SELECT Id,SBQQ__DocumentStatus__c,Tech_CollectionStatus_Approved__c
                                             		, SBQQ__Opportunity2__c, SBQQ__Account__c,Email_e_Billing__c
                                               		, Billing_Account__c,One_Time_Total__c,Recurring_Total_Monthly__c
                                             FROM SBQQ__Quote__c limit 1];
             
             listQuote[0].SBQQ__SubscriptionTerm__c = 2;
             listQuote[0].Recurring_Maintenance_Amount__c = 2;
             
             update listQuote;
             
             List<RCC_Condition__c> listRccConditon = [SELECT Id FROM RCC_Condition__c limit 1];
             listRccConditon[0].Account_Aston_Delay__c = '1';
             listRccConditon[0].Account_Nature__c = 'PRO';
             listRccConditon[0].Account_Aston_Amount__c = 0;
             
             update listRccConditon;
             
             Test.startTest();        
             //SM012_QuotePriceRule.setPriceRule(listQuote);   
             Test.stopTest();
             
         }
     }
    
    static testMethod void setPriceRule_ASTONDELAY3() {
         System.runAs(adminUser){
             List<SBQQ__Quote__c> listQuote = [SELECT Id,SBQQ__DocumentStatus__c,Tech_CollectionStatus_Approved__c
                                             		, SBQQ__Opportunity2__c, SBQQ__Account__c,Email_e_Billing__c
                                               		, Billing_Account__c,One_Time_Total__c,Recurring_Total_Monthly__c
                                             FROM SBQQ__Quote__c limit 1];
             
             listQuote[0].SBQQ__SubscriptionTerm__c = 2;
             listQuote[0].Recurring_Maintenance_Amount__c = 2;
             
             update listQuote;
             
             List<RCC_Condition__c> listRccConditon = [SELECT Id FROM RCC_Condition__c limit 1];
             listRccConditon[0].Account_Aston_Delay__c = '3';
             listRccConditon[0].Account_Nature__c = 'PRO';
             listRccConditon[0].Account_Aston_Amount__c = 0;
             
             update listRccConditon;
             
             Test.startTest();        
             //SM012_QuotePriceRule.setPriceRule(listQuote);   
             Test.stopTest();
             
         }
     }
    
    static testMethod void setPriceRule_ASTONDELAY6() {
         System.runAs(adminUser){
             List<SBQQ__Quote__c> listQuote = [SELECT Id,SBQQ__DocumentStatus__c,Tech_CollectionStatus_Approved__c
                                             		, SBQQ__Opportunity2__c, SBQQ__Account__c,Email_e_Billing__c
                                               		, Billing_Account__c,One_Time_Total__c,Recurring_Total_Monthly__c
                                             FROM SBQQ__Quote__c limit 1];
             
             listQuote[0].SBQQ__SubscriptionTerm__c = 2;
             listQuote[0].Recurring_Maintenance_Amount__c = 2;
             
             update listQuote;
             
             List<RCC_Condition__c> listRccConditon = [SELECT Id FROM RCC_Condition__c limit 1];
             listRccConditon[0].Account_Aston_Delay__c = '6';
             listRccConditon[0].Account_Nature__c = 'PRO';
             listRccConditon[0].Account_Aston_Amount__c = 0;
             
             update listRccConditon;
             
             Test.startTest();        
             //SM012_QuotePriceRule.setPriceRule(listQuote);   
             Test.stopTest();
             
         }
     }
    
    static testMethod void setPriceRule_ASTONDELAY12() {
         System.runAs(adminUser){
             List<SBQQ__Quote__c> listQuote = [SELECT Id,SBQQ__DocumentStatus__c,Tech_CollectionStatus_Approved__c
                                             		, SBQQ__Opportunity2__c, SBQQ__Account__c,Email_e_Billing__c
                                               		, Billing_Account__c,One_Time_Total__c,Recurring_Total_Monthly__c
                                             FROM SBQQ__Quote__c limit 1];
             
             listQuote[0].SBQQ__SubscriptionTerm__c = 2;
             listQuote[0].Recurring_Maintenance_Amount__c = 2;
             
             update listQuote;
             
             List<RCC_Condition__c> listRccConditon = [SELECT Id FROM RCC_Condition__c limit 1];
             listRccConditon[0].Account_Aston_Delay__c = '12';
             listRccConditon[0].Account_Nature__c = 'PRO';
             listRccConditon[0].Account_Aston_Amount__c = 0;
             
             update listRccConditon;
             
             Test.startTest();        
             //SM012_QuotePriceRule.setPriceRule(listQuote);   
             Test.stopTest();
             
         }
     }
    
    static testMethod void setPriceRule_ASTONDELAY24() {
         System.runAs(adminUser){
             List<SBQQ__Quote__c> listQuote = [SELECT Id,SBQQ__DocumentStatus__c,Tech_CollectionStatus_Approved__c
                                             		, SBQQ__Opportunity2__c, SBQQ__Account__c,Email_e_Billing__c
                                               		, Billing_Account__c,One_Time_Total__c,Recurring_Total_Monthly__c
                                             FROM SBQQ__Quote__c limit 1];
             
             listQuote[0].SBQQ__SubscriptionTerm__c = 2;
             listQuote[0].Recurring_Maintenance_Amount__c = 2;
             
             update listQuote;
             
             List<RCC_Condition__c> listRccConditon = [SELECT Id FROM RCC_Condition__c limit 1];
             listRccConditon[0].Account_Aston_Delay__c = '24';
             listRccConditon[0].Account_Nature__c = 'PRO';
             listRccConditon[0].Account_Aston_Amount__c = 0;
             
             update listRccConditon;
             
             Test.startTest();        
             //SM012_QuotePriceRule.setPriceRule(listQuote);   
             Test.stopTest();
             
         }
     }
    
    static testMethod void setPriceRule_ASTONDELAY24UP() {
         System.runAs(adminUser){
             List<SBQQ__Quote__c> listQuote = [SELECT Id,SBQQ__DocumentStatus__c,Tech_CollectionStatus_Approved__c
                                             		, SBQQ__Opportunity2__c, SBQQ__Account__c,Email_e_Billing__c
                                               		, Billing_Account__c,One_Time_Total__c,Recurring_Total_Monthly__c
                                             FROM SBQQ__Quote__c limit 1];
             
             listQuote[0].SBQQ__SubscriptionTerm__c = 2;
             listQuote[0].Recurring_Maintenance_Amount__c = 2;
             
             update listQuote;
             
             List<RCC_Condition__c> listRccConditon = [SELECT Id FROM RCC_Condition__c limit 1];
             listRccConditon[0].Account_Aston_Delay__c = '24+';
             listRccConditon[0].Account_Nature__c = 'PRO';
             listRccConditon[0].Account_Aston_Amount__c = 0;
             
             update listRccConditon;
             
             Test.startTest();        
             //SM012_QuotePriceRule.setPriceRule(listQuote);   
             Test.stopTest();
             
         }
     }


}