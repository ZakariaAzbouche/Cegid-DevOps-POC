@isTest
public class TH_OpportunityLineItem_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator(); 

    @testSetup static void setup() {
        System.runAs(adminUser) {       
            
            insert new BypassTrigger__c(SetupOwnerId = UserInfo.getOrganizationId(), Activatetrigger__c = True);
            
            
            
            Test.startTest();
            List<Account> accs = new List<Account>();
            for(Integer i = 0 ; i < 5 ; i++) {
                Account acc = new Account();
                acc.Name= 'Test Account AZA2 '+i;
                acc.National_ID_Exception__c ='Empty on loading';
                acc.BillingPostalCode ='75009';
                acc.BillingCountry ='France';
                acc.BillingCity ='Paris';
                acc.No_of_Employees_Group__c = 15;
                acc.No_of_Stores__c = 7;
                acc.NumberOfEmployees = 14;

                accs.add(acc);
            }
                        

            insert accs;
                  
            Opportunity oppToInsert = new Opportunity();
            oppToInsert.Name='test azas2';
            oppToInsert.AccountId=accs[0].Id;
            oppToInsert.StageName='G - MQL';
            oppToInsert.Sales_Purpose__c='121';
            oppToInsert.CurrencyIsoCode='EUR';
            oppToInsert.Forecast_Category_EDIT__c='Omitted';
            oppToInsert.CloseDate=date.today();
            oppToInsert.LeadSource='Sales Prospecting';
            oppToInsert.Competitors__c = 'ADP';  
            
            insert oppToInsert;

            Product2 pdct = new Product2(Name='testProduct');

            insert pdct;

            PricebookEntry pbe = new PricebookEntry(IsActive= true, Product2Id = pdct.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 400);

            insert pbe;
        }
    }

    @isTest static void computeSaasAmountTest() {

        List<OpportunityLineItem> oppLines = new List<OpportunityLineItem>();
        Integer nbLigne = 10;
        for(Integer i = 0; i < nbLigne; i++) {
            oppLines.add(new OpportunityLineItem(Saas_Amount__c = 0));
        }

        new TH_OpportunityLineItem().computeSaasAmount(oppLines);
        

    }
    @isTest static void beforeInsertTEST() {
        List<Opportunity> opps = [SELECT Id FROM Opportunity];
        List<PricebookEntry> pbes = [SELECT Id FROM PricebookEntry];

        List<OpportunityLineItem> oppLines = new List<OpportunityLineItem>();
        Integer nbLigne = 100;
        for(Integer i = 0; i < nbLigne; i++) {
            oppLines.add(new OpportunityLineItem(OpportunityId = opps[0].Id, Quantity=3, TotalPrice = 500,  PricebookEntryId= pbes[0].Id));
        }


        Test.startTest();    
        List<Database.SaveResult> results = Database.insert(oppLines, false);
        Test.stopTest();

        System.debug(results);

    }

    @isTest static void beforeUpdateTEST() {
        List<Opportunity> opps = [SELECT Id FROM Opportunity];
        List<PricebookEntry> pbes = [SELECT Id FROM PricebookEntry];

        List<OpportunityLineItem> oppLines = new List<OpportunityLineItem>();
        Integer nbLigne = 100;
        for(Integer i = 0; i < nbLigne; i++) {
            
            oppLines.add(new OpportunityLineItem(OpportunityId = opps[0].Id, Quantity=3, TotalPrice = 500, PricebookEntryId= pbes[0].Id));
        }

        insert oppLines;


        for(OpportunityLineItem oppLine : oppLines) {
            oppLine.Quantity = 5;
        }

        Test.startTest();    
        List<Database.SaveResult> results = Database.update(oppLines, false);
        Test.stopTest();

        System.debug(results);

    }
    
}