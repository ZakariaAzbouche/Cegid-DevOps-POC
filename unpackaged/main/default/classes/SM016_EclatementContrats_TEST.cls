/**
 * @author Keshav - Comforth Karoo
 * @created 2021-23-03
 * @description Test class for apex SM016_EclatementContrats
 *              
*/
@isTest
public class SM016_EclatementContrats_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static final String PRIMARY_CONTACT_EMAIL = 'primarycontact@email.com';

    @TestSetup static void setup(){ 
        //testing as admin because of issues with CBQQ rights when testing as Cegid sales
        System.runAs(adminUser){
            Test.startTest(); //to prevent SOQL limits from SBQQ package
            //create account
            Account acc = new UTIL_TestFactory.AccountFactory().createAccount();
            acc.ERP_Number__c = '99980001';
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

            SBQQ__Quote__c quote = new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteV2(opp.Id, acc.Id, primaryContact.Id, acc.Id);
            insert quote;

            List<SBQQ__Quote__c> listQ = [SELECT Id, SBQQ__PriceBook__r.Cegid_Entity__c FROM SBQQ__Quote__c WHERE Id =:quote.Id];

            Company_Labels__c cl = new UTIL_TestFactory.CompanyLabel().createCompanyLabel(listQ[0].SBQQ__PriceBook__r.Cegid_Entity__c, '', '','');
            insert cl;

            Test.stopTest();
        }
    }


    /**
    * @author Kesha M - Comforth Karoo
    * @created 2021-04-01
    * @description Test callout OK for quote with ERP number
    */
    @isTest static void testCalloutPassportOK() {
        System.runAs(adminUser){
            List<SBQQ__Quote__c> listQ = new list<SBQQ__Quote__c>();
            set<Id> setQuoteIds = new set<Id>();
            
            for(SBQQ__Quote__c q:[SELECT Id,XRP_Data_retrieved__c, SBQQ__PriceBook__r.Cegid_Entity__c FROM SBQQ__Quote__c LIMIT 1]){
                q.XRP_Data_retrieved__c = false;
                listQ.add(q);
                setQuoteIds.add(q.Id);
            }
            
            
            Test.StartTest();
            Test.setMock(HttpCalloutMock.class, new MockGetData());
            SM016_EclatementContrats.executeWebService(setQuoteIds);
            //QuoteEclatementContrats.fetchCompanyLabel(setQuoteIds);
            Test.StopTest();                                                                          
            
        }
    }




    /**
    * @author Keshav - Comforth Karoo
    * @created 2021-04-01
    * @description Mock class OK, admin SAAS found
    */
    private class MockGetData implements HttpCalloutMock {
        /**
        * @author Keshav - Comforth Karoo
        * @created 2021-04-01
        * @param req
        * @return HTTPResponse
        */
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            if(req.getMethod() == 'POST'){
               res.setBody('{"access_token": "7hwdehCZbyJPAdcAhV3DGwu-VreWWskWfV-Y3a1-X_036acsz0K_jVbZ9wP-Rna9Rn0i541DYQaQsCDeC9SH3g",     "refresh_token": "lPkolBqtiFEQwyQ3Pe71lRNHxARAMF1ZL1TBXfx4SaCzls9M_lSdER5k4Q5hpDeBZQhy1ZxYhnoCyKA5hRQjTA",     "scope": "READ",     "token_type": "Bearer",     "expires_in": 3600 }'); 
            }else if (req.getMethod() == 'GET'){
               res.setBody('{ "Success": true, "paymentMethod": "Bank Transfert", "numberOfDaysForPayment": "30", "paymentDate":"FA"}'); 
            }
                
                
                //res.setStatusCode(200);

            return res;
        }
    }


}