/**
 * @author Keshav - Comforth Karoo
 * @created 2021-04-01
 * @description Test class for apex WS002_FindContrat
 *              
*/
@isTest
public class WS002_FindContrat_TEST {
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

            PriceBook2 standardPricebook = new UTIL_TestFactory.PricebookFactory().activateStdPriceBook();

            //create opportunity
            Opportunity opp = new UTIL_TestFactory.OpportunityFactory().createOpportunity(acc.Id, false, false);
            opp.Pricebook2Id = standardPricebook.Id; 
            insert opp;

            Test.stopTest();
        }
    }

    @isTest static void testWebServiceLogin() { 
        List<Opportunity> listOpp = [SELECT Id from opportunity limit 1];
        Test.setMock(HttpCalloutMock.class, new MockGetData());
        Test.StartTest();
        WS002_FindContrat.resultWrapper testWrapper = new WS002_FindContrat.resultWrapper();
        testWrapper = WS002_FindContrat.getWebservice('002', listOpp[0].Id);
        Test.StopTest();
    }
    
    @isTest static void testManageWebResponse() { 
        List<WS002_FindContrat.subscription> webResponse = new List<WS002_FindContrat.subscription>();
        List<WS002_FindContrat.ratePlan> listRatePlans = new List<WS002_FindContrat.ratePlan>();
        
        WS002_FindContrat.subscription sub1 = new WS002_FindContrat.subscription();
        sub1.status = 'Pending Activation';
        
        WS002_FindContrat.ratePlan rt1 = new WS002_FindContrat.ratePlan();
        rt1.levelService = 'levelService1';
        WS002_FindContrat.ratePlan rt2 = new WS002_FindContrat.ratePlan();
        rt2.levelService = 'levelService2';
        listRatePlans.add(rt1);listRatePlans.add(rt2);
        
        WS002_FindContrat.subscription sub2 = new WS002_FindContrat.subscription();
        sub2.status = 'Active';
        sub2.ratePlans = listRatePlans;
        
        webResponse.add(sub1);webResponse.add(sub2);
        Test.StartTest();
        WS002_FindContrat.manageWebResponse(webResponse);
        Test.StopTest();
    }
    
    @isTest static void testSaveData() { 
        List<Opportunity> listOpp = [SELECT Id from opportunity limit 1];
        Test.setMock(HttpCalloutMock.class, new MockGetData());
        Test.StartTest();
        WS002_FindContrat.resultWrapper testWrapper1 = new WS002_FindContrat.resultWrapper();
        testWrapper1 = WS002_FindContrat.saveWebservice('002','00000','111111', listOpp[0].Id);
        Test.StopTest();
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
            }/*else if(req.getMethod() == 'GET'){
                res.setBody('[{ "personEmail": "abc@cegid.com", "serviceCode": "13", "folderNumber": null, "accountId": "99980001", "validatorEmail": "xyz@cegid.com", "requestDate": "2017-09-25T12:03:00.713Z", "validityEndDate": null, "status": "Active", "catalogStatus": "Delivered" }, { "personEmail": "aaa@cegid.com", "serviceCode": "13", "folderNumber": null, "accountId": "99980001", "validatorEmail": "slescure@cegid.com", "requestDate": "2018-09-17T18:03:15.277Z", "validityEndDate": null, "status": "Active", "catalogStatus": "Delivered" }, { "personEmail": "eyildiz@cegid.com", "serviceCode": "13", "folderNumber": null, "accountId": "99980001", "validatorEmail": null, "requestDate": "2019-02-19T10:05:21.983Z", "validityEndDate": null, "status": "Active", "catalogStatus": "Delivered" }, { "personEmail": "dddd@cegid.com", "serviceCode": "13", "folderNumber": null, "accountId": "99980001", "validatorEmail": null, "requestDate": "2019-02-19T10:05:20.937Z", "validityEndDate": null, "status": "Active", "catalogStatus": "Delivered" } ]');
                
            }*/
                //res.setBody('{"access_token": "7hwdehCZbyJPAdcAhV3DGwu-VreWWskWfV-Y3a1-X_036acsz0K_jVbZ9wP-Rna9Rn0i541DYQaQsCDeC9SH3g",     "refresh_token": "lPkolBqtiFEQwyQ3Pe71lRNHxARAMF1ZL1TBXfx4SaCzls9M_lSdER5k4Q5hpDeBZQhy1ZxYhnoCyKA5hRQjTA",     "scope": "READ",     "token_type": "Bearer",     "expires_in": 3600 }');
                //res.setStatusCode(200);

            return res;
        }
    }
}