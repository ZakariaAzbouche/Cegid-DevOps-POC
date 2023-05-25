/**
 * @author Shamina M - Comforth Karoo
 * @date 2020-08-31
 * @description Test class for SM006_CalculateQuoteLineRollUp
*/
@isTest
private class SM006_CalculateQuoteLineRollUp_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static final String PRIMARY_CONTACT_EMAIL = 'calcrollupcontact@email.com';

    @TestSetup static void setup(){    
        //testing as admin because of issues with CPQ rights when testing as Cegid sales
        System.runAs(adminUser){             
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
                    quote.AdminSAASContactFirstName__c = 'AAAA'+i; //used for order by SOQL
                    listQuotes.add(quote);
                }
                insert listQuotes;
                
            Test.stopTest();
        }
        
    }

    /**
    * @author Shamina M - Comforth
    * @created 2020-09-02
    * @description Set required fields for quot line   
    * @return List<SBQQ__QuoteLine__c>            
    */
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
                listQuoteLine.add(qutLine);

                qutLine= new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteLine(quote.Id, listProduct[i].Id);
                qutLine.SBQQ__NetPrice__c = 200;
                qutLine.StructureLevel1__c = SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_LICENSES;
                qutLine.SBQQ__ChargeType__c = SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING;
                qutLine.TECH_CopyDiscountResult__c = 20;
                qutLine.TECH_CopyGrossTotal__c = 200;
                listQuoteLine.add(qutLine);

                qutLine= new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteLine(quote.Id, listProduct[i].Id);
                qutLine.SBQQ__NetPrice__c = 300;
                qutLine.StructureLevel1__c = SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_SAAS;
                qutLine.SBQQ__ChargeType__c = SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING;
                qutLine.TECH_CopyDiscountResult__c = 30;
                qutLine.TECH_CopyGrossTotal__c = 300;
                listQuoteLine.add(qutLine);

                qutLine= new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteLine(quote.Id, listProduct[i].Id);
                qutLine.SBQQ__NetPrice__c = 400;
                qutLine.StructureLevel1__c = SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_PROF_SERVICES;
                qutLine.SBQQ__ChargeType__c = SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING;
                qutLine.Category__c = '949'; //other
                qutLine.TECH_CopyDiscountResult__c = 40;
                qutLine.TECH_CopyGrossTotal__c = 400;
                listQuoteLine.add(qutLine);

                qutLine= new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteLine(quote.Id, listProduct[i].Id);
                qutLine.SBQQ__NetPrice__c = 500;
                qutLine.SBQQ__ChargeType__c = SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING;
                qutLine.Category__c = SM006_CalculateQuoteLineRollUp.CATEGORY_CERTIFICATION; 
                qutLine.TECH_CopyDiscountResult__c = 50;
                qutLine.TECH_CopyGrossTotal__c = 500;
                listQuoteLine.add(qutLine);
            }
            
        }
        return listQuoteLine;
    }


    /**
    * @author Shamina M - Comforth
    * @created 2020-09-02
    * @description Build test data for quote line one-time 
    * @return List<SBQQ__QuoteLine__c>            
    */
    public static List<SBQQ__QuoteLine__c> createQutLinesOneTime(){
        List<SBQQ__QuoteLine__c> listQuoteLine = new List<SBQQ__QuoteLine__c>();
        List<Product2> listProduct = [SELECT Id from Product2];

        for(SBQQ__Quote__c quote : [SELECT Id, AdminSAASContactFirstName__c 
            from SBQQ__Quote__c ORDER BY AdminSAASContactFirstName__c ASC]){
            for(Integer i=0; i<2;i++){
                SBQQ__QuoteLine__c qutLine= new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteLine(quote.Id, listProduct[i].Id);
                qutLine.SBQQ__NetPrice__c = 100;
                qutLine.StructureLevel1__c = SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_MAINT;
                qutLine.SBQQ__ChargeType__c = SM006_CalculateQuoteLineRollUp.CHARGETYPE_ONETIME;
                qutLine.TECH_CopyDiscountResult__c = 10;
                qutLine.TECH_CopyGrossTotal__c = 100;
                listQuoteLine.add(qutLine);

                qutLine= new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteLine(quote.Id, listProduct[i].Id);
                qutLine.SBQQ__NetPrice__c = 200;
                qutLine.StructureLevel1__c = SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_LICENSES;
                qutLine.SBQQ__ChargeType__c = SM006_CalculateQuoteLineRollUp.CHARGETYPE_ONETIME;
                qutLine.TECH_CopyDiscountResult__c = 20;
                qutLine.TECH_CopyGrossTotal__c = 200;
                listQuoteLine.add(qutLine);

                qutLine= new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteLine(quote.Id, listProduct[i].Id);
                qutLine.SBQQ__NetPrice__c = 300;
                qutLine.StructureLevel1__c = SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_SAAS;
                qutLine.SBQQ__ChargeType__c = SM006_CalculateQuoteLineRollUp.CHARGETYPE_ONETIME;
                qutLine.TECH_CopyDiscountResult__c = 30;
                qutLine.TECH_CopyGrossTotal__c = 300;
                listQuoteLine.add(qutLine);

                qutLine= new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteLine(quote.Id, listProduct[i].Id);
                qutLine.SBQQ__NetPrice__c = 400;
                qutLine.StructureLevel1__c = SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_PROF_SERVICES;
                qutLine.SBQQ__ChargeType__c = SM006_CalculateQuoteLineRollUp.CHARGETYPE_ONETIME;
                qutLine.Category__c = '949'; //other
                qutLine.TECH_CopyDiscountResult__c = 40;
                qutLine.TECH_CopyGrossTotal__c = 400;
                listQuoteLine.add(qutLine);

                qutLine= new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteLine(quote.Id, listProduct[i].Id);
                qutLine.SBQQ__NetPrice__c = 500;
                qutLine.SBQQ__ChargeType__c = SM006_CalculateQuoteLineRollUp.CHARGETYPE_ONETIME;
                qutLine.Category__c = SM006_CalculateQuoteLineRollUp.CATEGORY_CERTIFICATION; 
                qutLine.TECH_CopyDiscountResult__c = 50;
                qutLine.TECH_CopyGrossTotal__c = 500;
                listQuoteLine.add(qutLine);
            }

        }
        return listQuoteLine;
    }

    /**
    * @author Shamina M - Comforth
    * @created 2020-10-23
    * @description Build test data for quote line elearning and related training session
    * @return List<SBQQ__QuoteLine__c>            
    */
    public static List<SBQQ__QuoteLine__c> createQutLinesElearning(){
        List<SBQQ__QuoteLine__c> listQuoteLine = new List<SBQQ__QuoteLine__c>();
        List<Product2> listProduct = [SELECT Id from Product2];

        for(SBQQ__Quote__c quote : [SELECT Id, AdminSAASContactFirstName__c 
                            from SBQQ__Quote__c ORDER BY AdminSAASContactFirstName__c ASC]){
            for(Integer i=0; i<3;i++){
                SBQQ__QuoteLine__c qutLine= new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteLine(quote.Id, listProduct[i].Id);

                qutLine= new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteLine(quote.Id, listProduct[i].Id);
                qutLine.SBQQ__NetPrice__c = 500;
                qutLine.SBQQ__ChargeType__c = SM006_CalculateQuoteLineRollUp.CHARGETYPE_ONETIME;
                qutLine.Category__c = SM006_CalculateQuoteLineRollUp.CATEGORY_ELEARNING; 
                qutLine.SBQQ__Quantity__c = 2;
                listQuoteLine.add(qutLine);
            }

        }
        return listQuoteLine;
    }

    /*
    * @author Shamina M - Comforth
    * @created 2020-08-31
    * @description Test insert quote line for elearning
    *               (cannot insert too much of quote lines because of CPQ CPU limit exceeded error)
    */
   /* @isTest static void testInsertQutLineELearning() {
        System.runAs(adminUser){
            List<SBQQ__QuoteLine__c> listQuoteLine = createQutLinesElearning();
            Test.startTest();                
                insert listQuoteLine;
            Test.stopTest();

            
            for(SBQQ__Quote__c qut : [SELECT Id, AdminSAASContactFirstName__c, countELearningLinesWOAllTraining__c,
                (SELECT Category__c,SBQQ__ChargeType__c,StructureLevel1__c,SBQQ__NetPrice__c,SBQQ__NetTotal__c, 
                    TECH_CopyDiscountResult__c, TECH_CopyGrossTotal__c,CountEmptyTrainingSessions__c
                    FROM SBQQ__LineItems__r
                    where Id IN: listQuoteLine)
                    from SBQQ__Quote__c 
                    WHERE AdminSAASContactFirstName__c != null
                    ORDER BY AdminSAASContactFirstName__c ASC]){
                
                Integer countELearnWithoutAllTrainingSession=0;

                for(SBQQ__QuoteLine__c qutLine : qut.SBQQ__LineItems__r){
                    if(qutLine.Category__c == SM006_CalculateQuoteLineRollUp.CATEGORY_ELEARNING && qutLine.CountEmptyTrainingSessions__c > 0){
                        countELearnWithoutAllTrainingSession++;
                    }
                }

                //System.assertEquals(countELearnWithoutAllTrainingSession, qut.countELearningLinesWOAllTraining__c, 'Check CountEmptyTrainingSessions__c');
            }
        }
    }*/
    
    /*
    * @author Shamina M - Comforth
    * @created 2020-08-31
    * @description Test insert quote line for recurring charge
    *               (cannot insert too much of quote lines because of CPQ CPU limit exceeded error)
    */
    @isTest static void testInsertQutLineRecurringFull() {
        System.runAs(adminUser){
            List<SBQQ__QuoteLine__c> listQuoteLine = createQutLinesRecurring();
            Test.startTest();                
                insert listQuoteLine;
            Test.stopTest();
            
            for(SBQQ__Quote__c qut : [SELECT Id, AdminSAASContactFirstName__c, 
                Recurring_Maintenance_Amount__c,Total_Subscription_Discount__c, 
                Gross_Total_Total__c,Recurring_Licenses_Amount__c,Recurring_SaaS_Amount__c,
                Recurring_Services_Amount__c,Recurring_Training_Amount__c,
                (SELECT Category__c,SBQQ__ChargeType__c,StructureLevel1__c,SBQQ__NetPrice__c,SBQQ__NetTotal__c, 
                    TECH_CopyDiscountResult__c, TECH_CopyGrossTotal__c
                    FROM SBQQ__LineItems__r)
                    from SBQQ__Quote__c 
                    WHERE AdminSAASContactFirstName__c != null
                    ORDER BY AdminSAASContactFirstName__c ASC]){
                
                Decimal recurTrAmt = 0.00;
                Decimal recurServAmt = 0.00;
                Decimal recurSaasAmt = 0.00;
                Decimal recurMaintAmt = 0.00;
                Decimal recurLiscAmt = 0.00;
                Decimal totalSubsDisc = 0.00;
                Decimal grossTotal = 0.00;   
            
                for(SBQQ__QuoteLine__c qutLine : qut.SBQQ__LineItems__r){
                    if(qutLine.SBQQ__ChargeType__c == SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING &&
                        qutLine.StructureLevel1__c == SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_LICENSES){
                        recurLiscAmt += (qutLine.SBQQ__NetTotal__c == null ? 0: qutLine.SBQQ__NetTotal__c);
                    }
                    else if(qutLine.SBQQ__ChargeType__c == SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING &&
                        qutLine.StructureLevel1__c == SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_MAINT){
                        recurMaintAmt += (qutLine.SBQQ__NetTotal__c == null ? 0: qutLine.SBQQ__NetTotal__c);
                    }
                    else if(qutLine.SBQQ__ChargeType__c == SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING &&
                        qutLine.StructureLevel1__c == SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_SAAS){
                        recurSaasAmt += (qutLine.SBQQ__NetTotal__c == null ? 0: qutLine.SBQQ__NetTotal__c);
                    }
                    else if(qutLine.SBQQ__ChargeType__c == SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING &&
                            qutLine.StructureLevel1__c == SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_PROF_SERVICES &&
                            qutLine.Category__c == '949'){
                        recurServAmt += (qutLine.SBQQ__NetTotal__c == null ? 0: qutLine.SBQQ__NetTotal__c);
                    }
                    else if(qutLine.SBQQ__ChargeType__c == SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING && 
                            qutLine.Category__c == SM006_CalculateQuoteLineRollUp.CATEGORY_CERTIFICATION){
                        recurTrAmt += (qutLine.SBQQ__NetTotal__c == null ? 0: qutLine.SBQQ__NetTotal__c);
                    }
                    totalSubsDisc += (qutLine.TECH_CopyDiscountResult__c == null ? 0 : qutLine.TECH_CopyDiscountResult__c);
                    grossTotal += (qutLine.TECH_CopyGrossTotal__c == null ? 0: qutLine.TECH_CopyGrossTotal__c);
                }

                /*System.assertEquals(recurLiscAmt, qut.Recurring_Licenses_Amount__c, 'Check Recurring_Licenses_Amount__c');
                System.assertEquals(recurSaasAmt, qut.Recurring_SaaS_Amount__c, 'Check Recurring_SaaS_Amount__c');
                System.assertEquals(recurMaintAmt, qut.Recurring_Maintenance_Amount__c, 'Check Recurring_Maintenance_Amount__c');
                System.assertEquals(recurServAmt, qut.Recurring_Services_Amount__c, 'Check Recurring_Services_Amount__c');
                System.assertEquals(recurTrAmt, qut.Recurring_Training_Amount__c, 'Check Recurring_Training_Amount__c');

                System.assertEquals(totalSubsDisc, qut.Total_Subscription_Discount__c, 'Check Total_Subscription_Discount__c');
                System.assertEquals(grossTotal, qut.Gross_Total_Total__c, 'Check Gross_Total_Total__c');*/
            }
        }
    }

    /*
    * @author Shamina M - Comforth
    * @created 2020-08-31
    * @description Test insert quote line for One-Time charge
    *               (cannot insert too much of quote lines because of CPQ CPU limit exceeded error)
    */
    @isTest static void testInsertQutLineOneTimeFull() {
        System.runAs(adminUser){
            List<SBQQ__QuoteLine__c> listQuoteLine = createQutLinesOneTime();
            Test.startTest();                
                insert listQuoteLine;
            Test.stopTest();
            
            for(SBQQ__Quote__c qut : [SELECT Id, AdminSAASContactFirstName__c,
                Recurring_Maintenance_Amount__c,Total_Subscription_Discount__c, 
                Gross_Total_Total__c,Recurring_Licenses_Amount__c,Recurring_SaaS_Amount__c,
                Recurring_Services_Amount__c,Recurring_Training_Amount__c,
                One_Time_Training_Amount__c,One_Time_Services_Amount__c,
                One_Time_SaaS_Amount__c,One_Time_Maintenance_Amount__c,One_Time_Licenses_Amount__c,
                (SELECT Category__c,SBQQ__ChargeType__c,StructureLevel1__c,SBQQ__NetPrice__c,SBQQ__NetTotal__c, 
                    TECH_CopyDiscountResult__c, TECH_CopyGrossTotal__c
                    FROM SBQQ__LineItems__r)
                    from SBQQ__Quote__c 
                    WHERE AdminSAASContactFirstName__c != null
                    ORDER BY AdminSAASContactFirstName__c ASC]){

                Decimal oneTimeTrAmt = 0.00;
                Decimal oneTimeServAmt = 0.00;
                Decimal oneTimeSaasAmt = 0.00;
                Decimal oneTimeMaintAmt = 0.00;
                Decimal oneTimeLiscAmt = 0.00;
                Decimal totalSubsDisc = 0.00;
                Decimal grossTotal = 0.00;   
    
                for(SBQQ__QuoteLine__c qutLine : qut.SBQQ__LineItems__r){
                    if(qutLine.SBQQ__ChargeType__c == SM006_CalculateQuoteLineRollUp.CHARGETYPE_ONETIME &&
                        qutLine.StructureLevel1__c == SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_LICENSES){
                        oneTimeLiscAmt += (qutLine.SBQQ__NetTotal__c == null ? 0: qutLine.SBQQ__NetTotal__c);
                    }
                    else if(qutLine.SBQQ__ChargeType__c == SM006_CalculateQuoteLineRollUp.CHARGETYPE_ONETIME &&
                        qutLine.StructureLevel1__c == SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_MAINT){
                        oneTimeMaintAmt += (qutLine.SBQQ__NetTotal__c == null ? 0: qutLine.SBQQ__NetTotal__c);
                    }
                    else if(qutLine.SBQQ__ChargeType__c == SM006_CalculateQuoteLineRollUp.CHARGETYPE_ONETIME &&
                        qutLine.StructureLevel1__c == SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_SAAS){
                        oneTimeSaasAmt += (qutLine.SBQQ__NetTotal__c == null ? 0: qutLine.SBQQ__NetTotal__c);
                    }
                    else if(qutLine.SBQQ__ChargeType__c == SM006_CalculateQuoteLineRollUp.CHARGETYPE_ONETIME &&
                            qutLine.StructureLevel1__c == SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_PROF_SERVICES &&
                            qutLine.Category__c == '949'){
                        oneTimeServAmt += (qutLine.SBQQ__NetTotal__c == null ? 0: qutLine.SBQQ__NetTotal__c);
                    }
                    else if(qutLine.SBQQ__ChargeType__c == SM006_CalculateQuoteLineRollUp.CHARGETYPE_ONETIME && 
                            qutLine.Category__c == SM006_CalculateQuoteLineRollUp.CATEGORY_CERTIFICATION){
                        oneTimeTrAmt += (qutLine.SBQQ__NetTotal__c == null ? 0: qutLine.SBQQ__NetTotal__c);
                    }
                    totalSubsDisc += (qutLine.TECH_CopyDiscountResult__c == null ? 0 : qutLine.TECH_CopyDiscountResult__c);
                    grossTotal += (qutLine.TECH_CopyGrossTotal__c == null ? 0: qutLine.TECH_CopyGrossTotal__c);
                }
                
                /*System.assertEquals(oneTimeLiscAmt, qut.One_Time_Licenses_Amount__c, 'Check One_Time_Licenses_Amount__c');
                System.assertEquals(oneTimeSaasAmt, qut.One_Time_SaaS_Amount__c, 'Check One_Time_SaaS_Amount__c');
                System.assertEquals(oneTimeMaintAmt, qut.One_Time_Maintenance_Amount__c, 'Check One_Time_Maintenance_Amount__c');
                System.assertEquals(oneTimeServAmt, qut.One_Time_Services_Amount__c, 'Check One_Time_Services_Amount__c');
                System.assertEquals(oneTimeTrAmt, qut.One_Time_Training_Amount__c, 'Check One_Time_Training_Amount__c');

                System.assertEquals(totalSubsDisc, qut.Total_Subscription_Discount__c, 'Check Total_Subscription_Discount__c');
                System.assertEquals(grossTotal, qut.Gross_Total_Total__c, 'Check Gross_Total_Total__c');*/
            }
        }
    }


    /*
    * @author Shamina M - Comforth
    * @created 2020-08-31
    * @description Test Delete quote line for One-Time charge
    *               (cannot insert too much of quote lines because of CPQ CPU limit exceeded error)
    */
    @isTest static void testDeleteQutLineOneTimeFull() {
        System.runAs(adminUser){
            List<SBQQ__QuoteLine__c> listQuoteLine = createQutLinesOneTime();
            insert listQuoteLine;
            
            Test.startTest();  
                delete listQuoteLine;
            Test.stopTest();
            
            for(SBQQ__Quote__c qut : [SELECT Id, AdminSAASContactFirstName__c, 
                Recurring_Maintenance_Amount__c,Total_Subscription_Discount__c, 
                Gross_Total_Total__c,Recurring_Licenses_Amount__c,Recurring_SaaS_Amount__c,
                Recurring_Services_Amount__c,Recurring_Training_Amount__c,
                One_Time_Training_Amount__c,One_Time_Services_Amount__c,
                One_Time_SaaS_Amount__c,One_Time_Maintenance_Amount__c,One_Time_Licenses_Amount__c,
                (SELECT Category__c,SBQQ__ChargeType__c,StructureLevel1__c,SBQQ__NetPrice__c,SBQQ__NetTotal__c, 
                    TECH_CopyDiscountResult__c, TECH_CopyGrossTotal__c
                    FROM SBQQ__LineItems__r)
                    from SBQQ__Quote__c 
                    WHERE AdminSAASContactFirstName__c != null
                    ORDER BY AdminSAASContactFirstName__c ASC]){

                Decimal oneTimeTrAmt = 0.00;
                Decimal oneTimeServAmt = 0.00;
                Decimal oneTimeSaasAmt = 0.00;
                Decimal oneTimeMaintAmt = 0.00;
                Decimal oneTimeLiscAmt = 0.00;
                Decimal totalSubsDisc = 0.00;
                Decimal grossTotal = 0.00;   
    
                for(SBQQ__QuoteLine__c qutLine : qut.SBQQ__LineItems__r){
                    if(qutLine.SBQQ__ChargeType__c == SM006_CalculateQuoteLineRollUp.CHARGETYPE_ONETIME &&
                        qutLine.StructureLevel1__c == SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_LICENSES){
                        oneTimeLiscAmt += (qutLine.SBQQ__NetTotal__c == null ? 0: qutLine.SBQQ__NetTotal__c);
                    }
                    else if(qutLine.SBQQ__ChargeType__c == SM006_CalculateQuoteLineRollUp.CHARGETYPE_ONETIME &&
                        qutLine.StructureLevel1__c == SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_MAINT){
                        oneTimeMaintAmt += (qutLine.SBQQ__NetTotal__c == null ? 0: qutLine.SBQQ__NetTotal__c);
                    }
                    else if(qutLine.SBQQ__ChargeType__c == SM006_CalculateQuoteLineRollUp.CHARGETYPE_ONETIME &&
                        qutLine.StructureLevel1__c == SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_SAAS){
                        oneTimeSaasAmt += (qutLine.SBQQ__NetTotal__c == null ? 0: qutLine.SBQQ__NetTotal__c);
                    }
                    else if(qutLine.SBQQ__ChargeType__c == SM006_CalculateQuoteLineRollUp.CHARGETYPE_ONETIME &&
                            qutLine.StructureLevel1__c == SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_PROF_SERVICES &&
                            qutLine.Category__c == '949'){
                        oneTimeServAmt += (qutLine.SBQQ__NetTotal__c == null ? 0: qutLine.SBQQ__NetTotal__c);
                    }
                    else if(qutLine.SBQQ__ChargeType__c == SM006_CalculateQuoteLineRollUp.CHARGETYPE_ONETIME && 
                            qutLine.Category__c == SM006_CalculateQuoteLineRollUp.CATEGORY_CERTIFICATION){
                        oneTimeTrAmt += (qutLine.SBQQ__NetTotal__c == null ? 0: qutLine.SBQQ__NetTotal__c);
                    }
                    totalSubsDisc += (qutLine.TECH_CopyDiscountResult__c == null ? 0 : qutLine.TECH_CopyDiscountResult__c);
                    grossTotal += (qutLine.TECH_CopyGrossTotal__c == null ? 0: qutLine.TECH_CopyGrossTotal__c);
                }
                
                /*System.assertEquals(oneTimeLiscAmt, qut.One_Time_Licenses_Amount__c, 'Check One_Time_Licenses_Amount__c');
                System.assertEquals(oneTimeSaasAmt, qut.One_Time_SaaS_Amount__c, 'Check One_Time_SaaS_Amount__c');
                System.assertEquals(oneTimeMaintAmt, qut.One_Time_Maintenance_Amount__c, 'Check One_Time_Maintenance_Amount__c');
                System.assertEquals(oneTimeServAmt, qut.One_Time_Services_Amount__c, 'Check One_Time_Services_Amount__c');
                System.assertEquals(oneTimeTrAmt, qut.One_Time_Training_Amount__c, 'Check One_Time_Training_Amount__c');

                System.assertEquals(totalSubsDisc, qut.Total_Subscription_Discount__c, 'Check Total_Subscription_Discount__c');
                System.assertEquals(grossTotal, qut.Gross_Total_Total__c, 'Check Gross_Total_Total__c');*/
            }
        }
    }

    /*
    * @author Shamina M - Comforth
    * @created 2020-08-31
    * @description Test update quote line for recurring charge
    *               (cannot insert too much of quote lines because of CPQ CPU limit exceeded error)
    */
    @isTest static void testUpdateQutLineRecurringFull() {
        System.runAs(adminUser){
            List<SBQQ__QuoteLine__c> listQuoteLine = createQutLinesRecurring();
            insert listQuoteLine;

            for(SBQQ__QuoteLine__c qutLine : listQuoteLine){
                qutLine.SBQQ__NetPrice__c = 10;
                qutLine.TECH_CopyDiscountResult__c = 10;
                qutLine.TECH_CopyGrossTotal__c = 10;
            }

            Test.startTest();        
                update listQuoteLine;        
            Test.stopTest();
            
            for(SBQQ__Quote__c qut : [SELECT Id, AdminSAASContactFirstName__c,
                Recurring_Maintenance_Amount__c,Total_Subscription_Discount__c, 
                Gross_Total_Total__c,Recurring_Licenses_Amount__c,Recurring_SaaS_Amount__c,
                Recurring_Services_Amount__c,Recurring_Training_Amount__c,
                (SELECT Category__c,SBQQ__ChargeType__c,StructureLevel1__c,SBQQ__NetPrice__c,SBQQ__NetTotal__c, 
                    TECH_CopyDiscountResult__c, TECH_CopyGrossTotal__c
                    FROM SBQQ__LineItems__r)
                    from SBQQ__Quote__c 
                    WHERE AdminSAASContactFirstName__c != null
                    ORDER BY AdminSAASContactFirstName__c ASC]){
                
                Decimal recurTrAmt = 0.00;
                Decimal recurServAmt = 0.00;
                Decimal recurSaasAmt = 0.00;
                Decimal recurMaintAmt = 0.00;
                Decimal recurLiscAmt = 0.00;
                Decimal totalSubsDisc = 0.00;
                Decimal grossTotal = 0.00;   
            
                for(SBQQ__QuoteLine__c qutLine : qut.SBQQ__LineItems__r){
                    if(qutLine.SBQQ__ChargeType__c == SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING &&
                        qutLine.StructureLevel1__c == SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_LICENSES){
                        recurLiscAmt += (qutLine.SBQQ__NetTotal__c == null ? 0: qutLine.SBQQ__NetTotal__c);
                    }
                    else if(qutLine.SBQQ__ChargeType__c == SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING &&
                        qutLine.StructureLevel1__c == SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_MAINT){
                        recurMaintAmt += (qutLine.SBQQ__NetTotal__c == null ? 0: qutLine.SBQQ__NetTotal__c);
                    }
                    else if(qutLine.SBQQ__ChargeType__c == SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING &&
                        qutLine.StructureLevel1__c == SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_SAAS){
                        recurSaasAmt += (qutLine.SBQQ__NetTotal__c == null ? 0: qutLine.SBQQ__NetTotal__c);
                    }
                    else if(qutLine.SBQQ__ChargeType__c == SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING &&
                            qutLine.StructureLevel1__c == SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_PROF_SERVICES &&
                            qutLine.Category__c == '949'){
                        recurServAmt += (qutLine.SBQQ__NetTotal__c == null ? 0: qutLine.SBQQ__NetTotal__c);
                    }
                    else if(qutLine.SBQQ__ChargeType__c == SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING && 
                            qutLine.Category__c == SM006_CalculateQuoteLineRollUp.CATEGORY_CERTIFICATION){
                        recurTrAmt += (qutLine.SBQQ__NetTotal__c == null ? 0: qutLine.SBQQ__NetTotal__c);
                    }
                    totalSubsDisc += (qutLine.TECH_CopyDiscountResult__c == null ? 0 : qutLine.TECH_CopyDiscountResult__c);
                    grossTotal += (qutLine.TECH_CopyGrossTotal__c == null ? 0: qutLine.TECH_CopyGrossTotal__c);
                }

                /*System.assertEquals(recurLiscAmt, qut.Recurring_Licenses_Amount__c, 'Check Recurring_Licenses_Amount__c');
                System.assertEquals(recurSaasAmt, qut.Recurring_SaaS_Amount__c, 'Check Recurring_SaaS_Amount__c');
                System.assertEquals(recurMaintAmt, qut.Recurring_Maintenance_Amount__c, 'Check Recurring_Maintenance_Amount__c');
                System.assertEquals(recurServAmt, qut.Recurring_Services_Amount__c, 'Check Recurring_Services_Amount__c');
                System.assertEquals(recurTrAmt, qut.Recurring_Training_Amount__c, 'Check Recurring_Training_Amount__c');

                System.assertEquals(totalSubsDisc, qut.Total_Subscription_Discount__c, 'Check Total_Subscription_Discount__c');
                System.assertEquals(grossTotal, qut.Gross_Total_Total__c, 'Check Gross_Total_Total__c');*/
            }
        }
    }

    /*
    * @author Shamina M - Comforth
    * @created 2020-08-31
    * @description Test Bypass trigger
    */
    @isTest static void testBypassTrigger() {
        System.runAs(adminUser){
            BypassTrigger__c byPass = new BypassTrigger__c(SetupOwnerId =adminUser.Id,CalculateQuoteLineRollUp__c = true );
            insert byPass;
            
            List<SBQQ__QuoteLine__c> listQuoteLine = createQutLinesRecurring();

            Test.startTest();  
                insert listQuoteLine;
            Test.stopTest();

            for(SBQQ__Quote__c qut : [SELECT Id, AdminSAASContactFirstName__c,
                Recurring_Maintenance_Amount__c,Total_Subscription_Discount__c, 
                Gross_Total_Total__c,Recurring_Licenses_Amount__c,Recurring_SaaS_Amount__c,
                Recurring_Services_Amount__c,Recurring_Training_Amount__c,
                (SELECT Category__c,SBQQ__ChargeType__c,StructureLevel1__c,SBQQ__NetPrice__c,SBQQ__NetTotal__c, 
                    TECH_CopyDiscountResult__c, TECH_CopyGrossTotal__c
                    FROM SBQQ__LineItems__r)
                    from SBQQ__Quote__c 
                    WHERE AdminSAASContactFirstName__c != null
                    ORDER BY AdminSAASContactFirstName__c ASC]){
                
                Decimal recurTrAmt = 0.00;
                Decimal recurServAmt = 0.00;
                Decimal recurSaasAmt = 0.00;
                Decimal recurMaintAmt = 0.00;
                Decimal recurLiscAmt = 0.00;
                Decimal totalSubsDisc = 0.00;
                Decimal grossTotal = 0.00;   
            
                for(SBQQ__QuoteLine__c qutLine : qut.SBQQ__LineItems__r){
                    if(qutLine.SBQQ__ChargeType__c == SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING &&
                        qutLine.StructureLevel1__c == SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_LICENSES){
                        recurLiscAmt += (qutLine.SBQQ__NetTotal__c == null ? 0: qutLine.SBQQ__NetTotal__c);
                    }
                    else if(qutLine.SBQQ__ChargeType__c == SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING &&
                        qutLine.StructureLevel1__c == SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_MAINT){
                        recurMaintAmt += (qutLine.SBQQ__NetTotal__c == null ? 0: qutLine.SBQQ__NetTotal__c);
                    }
                    else if(qutLine.SBQQ__ChargeType__c == SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING &&
                        qutLine.StructureLevel1__c == SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_SAAS){
                        recurSaasAmt += (qutLine.SBQQ__NetTotal__c == null ? 0: qutLine.SBQQ__NetTotal__c);
                    }
                    else if(qutLine.SBQQ__ChargeType__c == SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING &&
                            qutLine.StructureLevel1__c == SM006_CalculateQuoteLineRollUp.STRUCLEVEL1_PROF_SERVICES &&
                            qutLine.Category__c == '949'){
                        recurServAmt += (qutLine.SBQQ__NetTotal__c == null ? 0: qutLine.SBQQ__NetTotal__c);
                    }
                    else if(qutLine.SBQQ__ChargeType__c == SM006_CalculateQuoteLineRollUp.CHARGETYPE_RECURRING && 
                            qutLine.Category__c == SM006_CalculateQuoteLineRollUp.CATEGORY_CERTIFICATION){
                        recurTrAmt += (qutLine.SBQQ__NetTotal__c == null ? 0: qutLine.SBQQ__NetTotal__c);
                    }

                    totalSubsDisc += (qutLine.TECH_CopyDiscountResult__c == null ? 0 : qutLine.TECH_CopyDiscountResult__c);
                    grossTotal += (qutLine.TECH_CopyGrossTotal__c == null ? 0: qutLine.TECH_CopyGrossTotal__c);
                }

                //trigger not fired
                System.assertEquals(null, qut.Recurring_Licenses_Amount__c, 'Check Recurring_Licenses_Amount__c');
                System.assertEquals(null, qut.Recurring_SaaS_Amount__c, 'Check Recurring_SaaS_Amount__c');
                System.assertEquals(null, qut.Recurring_Maintenance_Amount__c, 'Check Recurring_Maintenance_Amount__c');
                System.assertEquals(null, qut.Recurring_Services_Amount__c, 'Check Recurring_Services_Amount__c');
                System.assertEquals(null, qut.Recurring_Training_Amount__c, 'Check Recurring_Training_Amount__c');

                System.assertEquals(null, qut.Total_Subscription_Discount__c, 'Check Total_Subscription_Discount__c');
                System.assertEquals(null, qut.Gross_Total_Total__c, 'Check Gross_Total_Total__c');
            }
        }
    }

}