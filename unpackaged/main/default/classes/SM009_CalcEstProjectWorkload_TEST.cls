/**
 * @author Shamina M - Comforth Karoo
 * @date 2020-11-11
 * @description Test class for SM009_CalcEstProjectWorkload
*/
@isTest
private class SM009_CalcEstProjectWorkload_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static final String PRIMARY_CONTACT_EMAIL = 'CalcEstProjectWorkload@email.com';

    @TestSetup static void setup(){    
        //testing as admin because of issues with CPQ rights when testing as Cegid sales
        System.runAs(adminUser){     
            //enable trigger on opportunity
            BypassTrigger__c settings = BypassTrigger__c.getOrgDefaults();
            settings.Activatetrigger__c = true;
            upsert settings custSettings__c.Id;   

            Test.startTest(); //to prevent SOQL limits from SBQQ package
                //create account
                Account acc = new UTIL_TestFactory.AccountFactory().createAccount();
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

                List<Product2> listProduct = new List<Product2>();
                for(Integer i=0; i<5;i++ ){
                    Product2 prod = new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List');
                    Product2 article = new UTIL_TestFactory.ProductFactory().createProduct('Article', 'List');

                    //alternate value for StructureLevel1/ family
                    if(i==0){
                        prod.family = '140';
                        article.Service_Term__c = 'Flat Fee';
                    }
                    else if(math.mod(i, 2) == 0){ //even
                        prod.family = '140';
                        article.Service_Term__c = 'Days';
                        article.Duration__c = 2;
                    }
                    else{
                        prod.family = '140';
                        article.Service_Term__c = 'Hours';
                        article.Duration__c = 4;
                    }

                    listProduct.add(prod);
                    listProduct.add(article);
                }
                insert listProduct;

                List<PricebookEntry> listPBE = new List<PricebookEntry>();
                for(Integer i=0; i<5;i++ ){
                    PricebookEntry pbe = new UTIL_TestFactory.PricebookFactory().createPriceBookEntry(standardPricebook.id, listProduct[i].id);
                    listPBE.add(pbe);
                }
                insert listPBE;

                List<SBQQ__ProductOption__c> listProdOpt = createProductOptions();
                insert listProdOpt;

                //create quote in mass (cannot create more than that because of SOQL & CPU limit exceeded from CPQ SBQQ package)
                List<SBQQ__Quote__c> listQuotes = new List<SBQQ__Quote__c>();

                for(Integer i=0; i<1;i++ ){
                    SBQQ__Quote__c quote = new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_Quote(opp.Id, acc.Id, primaryContact.Id);
                    quote.AdminSAASContactFirstName__c = 'AAAA'+i; //used for order by SOQL
                    quote.SBQQ__Primary__c = true;
                    quote.SBQQ__PriceBook__c = standardPricebook.Id;
                    listQuotes.add(quote);
                }
                insert listQuotes;
                
            Test.stopTest();
        }
        
    }

    /*
    * @author Shamina M - Comforth Karoo
    * @created 2020-09-15
    * @description Generic method to create test data for product options
    */
    private static List<SBQQ__ProductOption__c> createProductOptions(){
        List<SBQQ__ProductOption__c> listProdOpt = new List<SBQQ__ProductOption__c>();
        List<Product2> listProd2Product = [SELECT Id from Product2 where RecordType.DeveloperName = 'Product'];
        List<Product2> listProd2Article = [SELECT Id from Product2 where RecordType.DeveloperName = 'Article'];

        for(Integer i=0; i<5;i++ ){
            SBQQ__ProductOption__c prodOpt = new UTIL_TestFactory.ProductOptionFactory().createProductOption(listProd2Article[i].Id,listProd2Product[i].Id);
            prodOpt.SBQQ__Number__c = i;
            prodOpt.SBQQ__Quantity__c =1;
            listProdOpt.add(prodOpt);
        }

        return listProdOpt;
    }

    /**
    * @author Shamina M - Comforth
    * @created 2020-09-02
    * @description Set required fields for quot line   
    * @return List<SBQQ__QuoteLine__c>            
    */
    public static List<SBQQ__QuoteLine__c> createQutLines(){
        List<SBQQ__QuoteLine__c> listQuoteLine = new List<SBQQ__QuoteLine__c>();
        List<Product2> listProduct = [SELECT Id from Product2];

        for(SBQQ__Quote__c quote : [SELECT Id, AdminSAASContactFirstName__c 
            from SBQQ__Quote__c ORDER BY AdminSAASContactFirstName__c ASC]){
            for(Integer i=0; i<5;i++){
                SBQQ__QuoteLine__c qutLine= new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteLine(quote.Id, listProduct[i].Id);
                qutLine= new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteLine(quote.Id, listProduct[i].Id);
                qutLine.SBQQ__NetPrice__c = 400;
                qutLine.StructureLevel1__c = SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_PROF_SERVICES;
                qutLine.SBQQ__ChargeType__c = SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING;
                qutLine.Category__c = '949'; //other

                listQuoteLine.add(qutLine);
            }
            
        }
        return listQuoteLine;
    }

    /*
    * @author Shamina M - Comforth Karoo
    * @created 2020-11-12
    * @description Test insert quote lines
    */
    @isTest static void testInsertQuoteLines() {
        System.runAs(adminUser){
            List<SBQQ__QuoteLine__c> listQuoteLine = createQutLines();
            Test.startTest();                
                insert listQuoteLine; //this triggers auto-creation of opp line items by CPQ package
            Test.stopTest();

            /*for(Opportunity opp: [SELECT Id,TECH_Professional_Services_Workload__c,Estimated_Project_Workload__c
                                        FROM Opportunity ]){
                System.assertEquals(true, opp.TECH_Professional_Services_Workload__c == opp.Estimated_Project_Workload__c 
                                        , 'Estimated_Project_Workload__c valid');
            }*/

        }
    }

    /*
    * @author Shamina M - Comforth Karoo
    * @created 2020-11-12
    * @description Test update quote lines
    */
    @isTest static void testUpdateQuoteLines() {
        System.runAs(adminUser){
            List<SBQQ__QuoteLine__c> listQuoteLine = createQutLines();
            insert listQuoteLine; //this triggers update opp line items based on CPQ package

            Test.startTest(); 
                listQuoteLine[0].SBQQ__Product__c = listQuoteLine[1].SBQQ__Product__c;
                listQuoteLine[1].SBQQ__Product__c = listQuoteLine[2].SBQQ__Product__c;
                listQuoteLine[2].SBQQ__Product__c = listQuoteLine[3].SBQQ__Product__c;
                listQuoteLine[3].SBQQ__Product__c = listQuoteLine[4].SBQQ__Product__c;
                listQuoteLine[4].SBQQ__Product__c = listQuoteLine[0].SBQQ__Product__c;
                update listQuoteLine;
            Test.stopTest();

            /*for(Opportunity opp: [SELECT Id,TECH_Professional_Services_Workload__c,Estimated_Project_Workload__c
                                        FROM Opportunity ]){
                System.assertEquals(true, opp.TECH_Professional_Services_Workload__c == opp.Estimated_Project_Workload__c 
                                        , 'Estimated_Project_Workload__c valid');
            }*/

        }
    }
}