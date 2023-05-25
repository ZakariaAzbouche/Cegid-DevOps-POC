/**
* @author Keshav M - Comforth
* @date 2020-04-20
* @description SM018_RedistributionOfDiscount_TEST   
* @last modified on  : 2022-10-03
* @last modified by  : Ratish ISURI
*/
@isTest
public class SM018_RedistributionOfDiscount_TEST {
    //
    static User adminUser = new User(
        alias = 'Test',
        email = 'test.magellan-admin@example.com',
        emailencodingkey = 'UTF-8',
        BypassPB__c = true,
        BypassVR__c = true,
        BypassWF__c = true,
        lastname = 'testAdmin',
        languagelocalekey = 'fr',
        localesidkey = 'fr_FR',
        profileid = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
            OR Name = 'Administrateur système'
            LIMIT 1
        ][0].Id,
        timezonesidkey = 'Europe/Paris',
        username = 'SM018_RedistributionOfDiscount_TEST' + System.now().millisecond()
        + UserInfo.getOrganizationId() + '@example.com'
    );
    static final String PRIMARY_CONTACT_EMAIL = 'primarycontact@email.com';

    @testSetup static void setup(){
        
        List< Map<String,Object>> listQuoteLinesData = new  List<Map<String,Object>>{
        
            (new Map<String,Object>{'Family'=> '110' , 'ListPrice_Display__c' => 50, 'ListUnitPrice_Display__c' => 50, 'Purchasing_Price__c' => 700, 'SBQQ__NonDiscountable__c' => false, 'SBQQ__Quantity__c' => 1, 'SBQQ__AdditionalDiscountAmount__c' => 10, 'SBQQ__Discount__c' => 10})
            , 
            (new Map<String,Object>{'Family'=> '110' , 'ListPrice_Display__c' => 600, 'ListUnitPrice_Display__c' => 2, 'Purchasing_Price__c' => 10, 'SBQQ__NonDiscountable__c' => false, 'SBQQ__Quantity__c' => 1,  'SBQQ__AdditionalDiscountAmount__c' => null, 'SBQQ__Discount__c' => 10})
            ,
            (new Map<String,Object>{'Family'=> '110' , 'ListPrice_Display__c' => 1000, 'ListUnitPrice_Display__c' => 1000, 'Purchasing_Price__c' => 400, 'SBQQ__NonDiscountable__c' => false, 'SBQQ__Quantity__c' => 1,  'SBQQ__AdditionalDiscountAmount__c' => 10, 'SBQQ__Discount__c' => 10})
            ,
            (new Map<String,Object>{'Family'=> '120' , 'ListPrice_Display__c' => 50, 'ListUnitPrice_Display__c' => 50, 'Purchasing_Price__c' => 700, 'SBQQ__NonDiscountable__c' => false, 'SBQQ__Quantity__c' => 1,  'SBQQ__AdditionalDiscountAmount__c' => 10, 'SBQQ__Discount__c' => 10})
            , 
            (new Map<String,Object>{'Family'=> '120' , 'ListPrice_Display__c' => 600, 'ListUnitPrice_Display__c' => 2, 'Purchasing_Price__c' => 10, 'SBQQ__NonDiscountable__c' => false, 'SBQQ__Quantity__c' => 1,  'SBQQ__AdditionalDiscountAmount__c' => null, 'SBQQ__Discount__c' => 10})
            ,
            (new Map<String,Object>{'Family'=> '120' , 'ListPrice_Display__c' => 1000, 'ListUnitPrice_Display__c' => 1000, 'Purchasing_Price__c' => 400, 'SBQQ__NonDiscountable__c' => false, 'SBQQ__Quantity__c' => 1,  'SBQQ__AdditionalDiscountAmount__c' => 10, 'SBQQ__Discount__c' => 10})
            ,
            (new Map<String,Object>{'Family'=> '130' , 'ListPrice_Display__c' => 50, 'ListUnitPrice_Display__c' => 50, 'Purchasing_Price__c' => 700, 'SBQQ__NonDiscountable__c' => false, 'SBQQ__Quantity__c' => 1,  'SBQQ__AdditionalDiscountAmount__c' => null, 'SBQQ__Discount__c' => 10})
            , 
            (new Map<String,Object>{'Family'=> '130' , 'ListPrice_Display__c' => 600, 'ListUnitPrice_Display__c' => 2, 'Purchasing_Price__c' => 10, 'SBQQ__NonDiscountable__c' => false, 'SBQQ__Quantity__c' => 1,  'SBQQ__AdditionalDiscountAmount__c' => 10, 'SBQQ__Discount__c' => 10})
            ,
            (new Map<String,Object>{'Family'=> '130' , 'ListPrice_Display__c' => 1000, 'ListUnitPrice_Display__c' => 1000, 'Purchasing_Price__c' => 400, 'SBQQ__NonDiscountable__c' => false, 'SBQQ__Quantity__c' => 1,  'SBQQ__AdditionalDiscountAmount__c' => null, 'SBQQ__Discount__c' => 10})
            ,
            (new Map<String,Object>{'Family'=> '140' , 'ListPrice_Display__c' => 50, 'ListUnitPrice_Display__c' => 50, 'Purchasing_Price__c' => 700, 'SBQQ__NonDiscountable__c' => false, 'SBQQ__Quantity__c' => 1,  'SBQQ__AdditionalDiscountAmount__c' => 10, 'SBQQ__Discount__c' => 10})
           , 
            (new Map<String,Object>{'Family'=> '140' , 'ListPrice_Display__c' => 600, 'ListUnitPrice_Display__c' => 2, 'Purchasing_Price__c' => 10, 'SBQQ__NonDiscountable__c' => false, 'SBQQ__Quantity__c' => 1,  'SBQQ__AdditionalDiscountAmount__c' => 10, 'SBQQ__Discount__c' => 10})
            ,
            (new Map<String,Object>{'Family'=> '140' , 'ListPrice_Display__c' => 1000, 'ListUnitPrice_Display__c' => 1000, 'Purchasing_Price__c' => 400, 'SBQQ__NonDiscountable__c' => false, 'SBQQ__Quantity__c' => 1,  'SBQQ__AdditionalDiscountAmount__c' => 10, 'SBQQ__Discount__c' => 10})
            ,
            (new Map<String,Object>{'Family'=> '190' , 'ListPrice_Display__c' => 50, 'ListUnitPrice_Display__c' => 50, 'Purchasing_Price__c' => 700, 'SBQQ__NonDiscountable__c' => false, 'SBQQ__Quantity__c' => 1,  'SBQQ__AdditionalDiscountAmount__c' => 10, 'SBQQ__Discount__c' => 10})
           , 
            (new Map<String,Object>{'Family'=> '190' , 'ListPrice_Display__c' => 600, 'ListUnitPrice_Display__c' => 2, 'Purchasing_Price__c' => 10, 'SBQQ__NonDiscountable__c' => false, 'SBQQ__Quantity__c' => 1,  'SBQQ__AdditionalDiscountAmount__c' => 10, 'SBQQ__Discount__c' => 10})
            ,
            (new Map<String,Object>{'Family'=> '190' , 'ListPrice_Display__c' => 1000, 'ListUnitPrice_Display__c' => 1000, 'Purchasing_Price__c' => 400, 'SBQQ__NonDiscountable__c' => false, 'SBQQ__Quantity__c' => 1,  'SBQQ__AdditionalDiscountAmount__c' => 10, 'SBQQ__Discount__c' => 10})
          
        };

        System.runAs(adminUser){ 
            Insert new BypassTrigger__c(SetupOwnerId = UserInfo.getOrganizationId(), Activatetrigger__c = False);
        
            //create account
            List<Account> listAcc = new List<Account>();
            for(Integer i=0; i<1;i++ ){
                listAcc.add( new UTIL_TestFactory.AccountFactory().createAccountWithNature(i));
            }
            listAcc[0].National_ID__c = '00000000000011';
            listAcc[0].Collection_Status__c = 'Green';
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
        
            createQuoteLines(listQuoteLinesData,standardPricebook,listOpp,listAcc,primaryContact);
        }


    }
    
    
    @IsTest
    static void testTriggerAfterUpdateMaxDis(){
        
        List<SBQQ__Quote__c> listQuoteToUpdate = new list<SBQQ__Quote__c>();
        
        BypassTrigger__c byp = [SELECT Activatetrigger__c FROM BypassTrigger__c limit 1];
        
        byp.Activatetrigger__c = True;
        update byp;
        
        List<SBQQ__QuoteLine__c> lstQuoteLines = [SELECT id,SBQQ__Product__r.Family,SBQQ__Product__r.Purchasing_Price__c, SBQQ__Product__r.SBQQ__NonDiscountable__c
                                                  FROM SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Product__r.Family ='150'];
		system.debug('MCU lstQuoteLines : ' + lstQuoteLines);   
        
        for(SBQQ__Quote__c quo:[SELECT Id,TargetedPriceForHardware__c,TargetedPriceForSaas__c,TargetedPriceForLicense__c,TargetedPriceForMaintenance__c,TargetedPriceForProfessional_Services__c
                                From SBQQ__Quote__c]){
            quo.TargetedPriceForHardware__c = 1200;
            quo.TargetedPriceForSaas__c = 1200;
            quo.TargetedPriceForLicense__c = 1200;
            quo.TargetedPriceForMaintenance__c = 1200;
            quo.TargetedPriceForProfessional_Services__c = 1200;
            listQuoteToUpdate.add(quo);
        }

        Test.startTest();
        System.runAs(adminUser){
            try{
				update listQuoteToUpdate;
            }
            catch(exception ex){
            	system.debug(ex.getMessage());
        	}
            
        }
        Test.stopTest();

        // exclude family 150 as not available
        List<SBQQ__QuoteLine__c> listQuoteLine = [SELECT SBQQ__AdditionalDiscountAmount__c FROM SBQQ__QuoteLine__c WHERE SBQQ__QuoteLine__c.SBQQ__ProductFamily__c != '150'];


      


        for ( Integer i= 0; i< listQuoteLine.size(); i++) {  
            //System.assertEquals(-650, listQuoteLine[i].SBQQ__AdditionalDiscountAmount__c, 'Additional discount not as exxpected') ;
            //System.assertEquals(590, listQuoteLine[++i].SBQQ__AdditionalDiscountAmount__c, 'Additional discount not as exxpected') ;
            //System.assertEquals(346, (Integer) (listQuoteLine[++i].SBQQ__AdditionalDiscountAmount__c), 'Additional discount not as exxpected') ;
            
        }

        
    }
    
     @IsTest
    static void testTriggerAfterUpdateGlobal(){
        
        List<SBQQ__Quote__c> listQuoteToUpdate = new list<SBQQ__Quote__c>();
        
        BypassTrigger__c byp = [SELECT Activatetrigger__c FROM BypassTrigger__c limit 1];
        
        byp.Activatetrigger__c = True;
        update byp;
        
        List<SBQQ__QuoteLine__c> lstQuoteLines = [SELECT id,SBQQ__Product__r.Family,SBQQ__Product__r.Purchasing_Price__c, SBQQ__Product__r.SBQQ__NonDiscountable__c
                                                  FROM SBQQ__QuoteLine__c];
		system.debug('MCU lstQuoteLines : ' + lstQuoteLines);   
        
        for(SBQQ__Quote__c quo:[SELECT Id,TargetedPriceForHardware__c,TargetedPriceForSaas__c,TargetedPriceForLicense__c,TargetedPriceForMaintenance__c,TargetedPriceForProfessional_Services__c
                                From SBQQ__Quote__c]){
            quo.TargetedPriceForGlobal__c = 1200;
            listQuoteToUpdate.add(quo);
        }

        Test.startTest();
        System.runAs(adminUser){
            try{
				update listQuoteToUpdate;
            }
            catch(exception ex){
            	system.debug(ex.getMessage());
        	}
            
        }
        Test.stopTest();
        
    }


    @IsTest
    static void testTriggerAfterUpdateError110(){
		System.runAs(adminUser){
        delete [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__ProductFamily__c != '110' ];
        List<SBQQ__Quote__c> listQuoteToUpdate = new list<SBQQ__Quote__c>();
        
        BypassTrigger__c byp = [SELECT Activatetrigger__c FROM BypassTrigger__c limit 1];

        byp.Activatetrigger__c = True;
        update byp;
        for(SBQQ__Quote__c quo:[SELECT Id,TargetedPriceForHardware__c,TargetedPriceForSaas__c From SBQQ__Quote__c]){
            quo.TargetedPriceForHardware__c = 100;
            quo.TargetedPriceForSaas__c = 200;
            quo.TargetedPriceForLicense__c = 100;
            quo.TargetedPriceForMaintenance__c = 100;
            quo.TargetedPriceForProfessional_Services__c = 100;
            listQuoteToUpdate.add(quo);
        }
        
        String errorTypeName = null;

        Test.startTest();
        
            try {
                update listQuoteToUpdate;
            } catch (Exception e) {
                errorTypeName = e.getTypeName();
            } 
        }
        Test.stopTest();
        
        //System.assertEquals('System.DmlException', errorTypeName, 'Error TypeName was incorrect');
    }

    @IsTest
    static void testTriggerAfterUpdateError120(){
		System.runAs(adminUser){
        delete [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__ProductFamily__c != '120' ];
        List<SBQQ__Quote__c> listQuoteToUpdate = new list<SBQQ__Quote__c>();
        
        BypassTrigger__c byp = [SELECT Activatetrigger__c FROM BypassTrigger__c limit 1];

        byp.Activatetrigger__c = True;
        update byp;
        for(SBQQ__Quote__c quo:[SELECT Id,TargetedPriceForHardware__c,TargetedPriceForSaas__c From SBQQ__Quote__c]){
            quo.TargetedPriceForHardware__c = 100;
            quo.TargetedPriceForSaas__c = 200;
            quo.TargetedPriceForLicense__c = 100;
            quo.TargetedPriceForMaintenance__c = 100;
            quo.TargetedPriceForProfessional_Services__c = 100;
            listQuoteToUpdate.add(quo);
        }
        
         String errorTypeName = null;

        Test.startTest();
        
            try {
                update listQuoteToUpdate;
            } catch (Exception e) {
                errorTypeName = e.getTypeName();
            } 
        }
        Test.stopTest();
        
        //System.assertEquals('System.DmlException', errorTypeName, 'Error TypeName was incorrect');
    }

    @IsTest
    static void testTriggerAfterUpdateError130(){
		System.runAs(adminUser){
        delete [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__ProductFamily__c != '130' ];
        List<SBQQ__Quote__c> listQuoteToUpdate = new list<SBQQ__Quote__c>();
        
        BypassTrigger__c byp = [SELECT Activatetrigger__c FROM BypassTrigger__c limit 1];

        byp.Activatetrigger__c = True;
        update byp;
        for(SBQQ__Quote__c quo:[SELECT Id,TargetedPriceForHardware__c,TargetedPriceForSaas__c From SBQQ__Quote__c]){
            quo.TargetedPriceForHardware__c = 100;
            quo.TargetedPriceForSaas__c = 200;
            quo.TargetedPriceForLicense__c = 100;
            quo.TargetedPriceForMaintenance__c = 100;
            quo.TargetedPriceForProfessional_Services__c = 100;
            listQuoteToUpdate.add(quo);
        }
        
         String errorTypeName = null;

        Test.startTest();
        //System.runAs(adminUser){
            try {
                update listQuoteToUpdate;
            } catch (Exception e) {
                errorTypeName = e.getTypeName();
            } 
        }
        Test.stopTest();
        
        //System.assertEquals('System.DmlException', errorTypeName, 'Error TypeName was incorrect');
    }

    @IsTest
    static void testTriggerAfterUpdateError140(){
		System.runAs(adminUser){
        delete [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__ProductFamily__c != '140' ];
        
        List<SBQQ__Quote__c> listQuoteToUpdate = new list<SBQQ__Quote__c>();
        
        BypassTrigger__c byp = [SELECT Activatetrigger__c FROM BypassTrigger__c limit 1];

        byp.Activatetrigger__c = True;
        update byp;
        for(SBQQ__Quote__c quo:[SELECT Id,TargetedPriceForHardware__c,TargetedPriceForSaas__c From SBQQ__Quote__c]){
            quo.TargetedPriceForHardware__c = 100;
            quo.TargetedPriceForSaas__c = 200;
            quo.TargetedPriceForLicense__c = 100;
            quo.TargetedPriceForMaintenance__c = 100;
            quo.TargetedPriceForProfessional_Services__c = 100;
            listQuoteToUpdate.add(quo);
        }
        
         String errorTypeName = null;

        Test.startTest();
        //System.runAs(adminUser){
            try {
                update listQuoteToUpdate;
            } catch (Exception e) {
                errorTypeName = e.getTypeName();
            } 
        }
        Test.stopTest();
        
        //System.assertEquals('System.DmlException', errorTypeName, 'Error TypeName was incorrect');
    }
    //******************************************************************* */
    /// family 150 does not exist in current org instance
    // @IsTest
    // static void testTriggerAfterUpdateError150(){

    //     delete [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__ProductFamily__c != '150' ];
    //     List<SBQQ__Quote__c> listQuoteToUpdate = new list<SBQQ__Quote__c>();
        
    //     BypassTrigger__c byp = [SELECT Activatetrigger__c FROM BypassTrigger__c limit 1];

    //     byp.Activatetrigger__c = True;
    //     update byp;
    //     for(SBQQ__Quote__c quo:[SELECT Id,TargetedPriceForHardware__c,TargetedPriceForSaas__c From SBQQ__Quote__c]){
    //         quo.TargetedPriceForHardware__c = 100;
    //         quo.TargetedPriceForSaas__c = 200;
    //         quo.TargetedPriceForLicense__c = 100;
    //         quo.TargetedPriceForMaintenance__c = 100;
    //         quo.TargetedPriceForProfessional_Services__c = 100;
    //         listQuoteToUpdate.add(quo);
    //     }
        
    //     String errorMsg = null;

    //     Test.startTest();
    //     System.runAs(adminUser){
    //         try {
    //             update listQuoteToUpdate;
    //         } catch (Exception e) {
    //             errorMsg = e.getMessage();
    //         } 
    //     }
    //     Test.stopTest();
        
    //     System.assertEquals('Targeted Price too low, please review your objective !', errorMsg, 'Expected error message "Targeted Price too low..."');
    // }


    @IsTest
    static void testTriggerAfterUpdateNonDiscTrue(){

        delete [SELECT Id From SBQQ__Quote__c];
        delete [SELECT Id FROM SBQQ__QuoteLine__c];
        
        List< Map<String,Object>> listQuoteLinesData = new  List<Map<String,Object>>{
        
            (new Map<String,Object>{'Family'=> '110' , 'ListPrice_Display__c' => 50, 'ListUnitPrice_Display__c' => 50, 'Purchasing_Price__c' => 700, 'SBQQ__NonDiscountable__c' => true, 'SBQQ__Quantity__c' => 1, 'SBQQ__AdditionalDiscountAmount__c' => 10, 'SBQQ__Discount__c' => 10})
            , 
            (new Map<String,Object>{'Family'=> '120' , 'ListPrice_Display__c' => 600, 'ListUnitPrice_Display__c' => 2, 'Purchasing_Price__c' => 10, 'SBQQ__NonDiscountable__c' => true, 'SBQQ__Quantity__c' => 1,  'SBQQ__AdditionalDiscountAmount__c' => null, 'SBQQ__Discount__c' => 10})
            ,
            (new Map<String,Object>{'Family'=> '130' , 'ListPrice_Display__c' => 1000, 'ListUnitPrice_Display__c' => 1000, 'Purchasing_Price__c' => 400, 'SBQQ__NonDiscountable__c' => true, 'SBQQ__Quantity__c' => 1,  'SBQQ__AdditionalDiscountAmount__c' => 10, 'SBQQ__Discount__c' => 10})
            ,
            (new Map<String,Object>{'Family'=> '140' , 'ListPrice_Display__c' => 50, 'ListUnitPrice_Display__c' => 50, 'Purchasing_Price__c' => 700, 'SBQQ__NonDiscountable__c' => true, 'SBQQ__Quantity__c' => 1,  'SBQQ__AdditionalDiscountAmount__c' => 10, 'SBQQ__Discount__c' => 10})
            , 
            (new Map<String,Object>{'Family'=> '150' , 'ListPrice_Display__c' => 600, 'ListUnitPrice_Display__c' => 2, 'Purchasing_Price__c' => 10, 'SBQQ__NonDiscountable__c' => true, 'SBQQ__Quantity__c' => 1,  'SBQQ__AdditionalDiscountAmount__c' => null, 'SBQQ__Discount__c' => 10})
            
        };

        ///create data
        System.runAs(adminUser){
        
            //Get data to create quotelines
            List<Account> listAcc = [select id from  Account];
            Contact primaryContact = [select id from Contact limit 1];
            PriceBook2 standardPricebook = [select id from PriceBook2 limit 1];
            List<Opportunity> listOpp = [select id from Opportunity];
            
            createQuoteLines(listQuoteLinesData,standardPricebook,listOpp,listAcc,primaryContact) ;
        }
        
        List<SBQQ__Quote__c> listQuoteToUpdate = new list<SBQQ__Quote__c>();
        
        BypassTrigger__c byp = [SELECT Activatetrigger__c FROM BypassTrigger__c limit 1];

        byp.Activatetrigger__c = True;
        update byp;
        for(SBQQ__Quote__c quo:[SELECT Id,TargetedPriceForHardware__c,TargetedPriceForSaas__c From SBQQ__Quote__c]){
            quo.TargetedPriceForHardware__c = 100;
            quo.TargetedPriceForSaas__c = 1200;
            quo.TargetedPriceForLicense__c = 25;
            quo.TargetedPriceForMaintenance__c = 100;
            quo.TargetedPriceForProfessional_Services__c = 100;
            listQuoteToUpdate.add(quo);
        }

        Test.startTest();
        update listQuoteToUpdate;
        Test.stopTest();
        
        List<SBQQ__QuoteLine__c> listQuoteLine = [SELECT SBQQ__AdditionalDiscountAmount__c FROM SBQQ__QuoteLine__c];
        for (SBQQ__QuoteLine__c quoteline : [SELECT SBQQ__AdditionalDiscountAmount__c FROM SBQQ__QuoteLine__c]) {  
            //System.assertEquals(null, quoteline.SBQQ__AdditionalDiscountAmount__c, 'Additional discount not as exxpected') ;      
        }
       
    }

    
    private static void createQuoteLines(List<Map<String,Object>> listQuoteLinesData, Pricebook2 standardPricebook, List<Opportunity> listOpp, List<Account> listAcc, Contact primaryContact){
    
        //create product2 for family ...
        List<Product2> listProduct = new List<Product2>();
        for (Map<String,Object> mapQLineData: listQuoteLinesData) {
             Product2 p = new UTIL_TestFactory.ProductFactoryV1().createProduct('Product', 'Cost', (String)mapQLineData.get('Family'));
             p.Purchasing_Price__c = (Decimal)mapQLineData.get('Purchasing_Price__c');
             p.SBQQ__NonDiscountable__c = (Boolean)mapQLineData.get('SBQQ__NonDiscountable__c');
             listProduct.add(p);
            }
         insert listProduct;
         
         List<PricebookEntry> listPBE = new List<PricebookEntry>();
         for(Integer i=0; i<listProduct.size();i++){
             PricebookEntry pb = new UTIL_TestFactory.PricebookFactory().createPriceBookEntry(standardPricebook.id, listProduct[i].id);
             listPBE.add(pb);
            }
         insert listPBE; 
         // create quote
         SBQQ__Quote__c q = new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteV2(listOpp[0].Id, listAcc[0].Id, primaryContact.Id, listAcc[0].Id);
         q.Additional_discount_reason__c = '001';
         insert q;
         
         listOpp[0].SBQQ__PrimaryQuote__c = q.Id;
         update listOpp;
         
         List<SBQQ__QuoteLine__c> lstQuoteLine = new   List<SBQQ__QuoteLine__c> ();
         
         Integer i = 0;
         for (Map<String,Object> mapQLData: listQuoteLinesData) {
             SBQQ__QuoteLine__c ql = new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteLineV1(q.Id, listProduct[i].Id);
             ql.Waterfall_Gross_Unit_Price__c = (Double)mapQLData.get('ListUnitPrice_Display__c');
             ql.Waterfall_Gross_Total__c = (Double)mapQLData.get('ListPrice_Display__c');
             ql.SBQQ__Quantity__c = (Double)mapQLData.get('SBQQ__Quantity__c');
             ql.SBQQ__AdditionalDiscountAmount__c = (Double)mapQLData.get('SBQQ__AdditionalDiscountAmount__c');
             lstQuoteLine.add(ql);
             ++i;
            }
            insert lstQuoteLine;
            
    } 
        
}