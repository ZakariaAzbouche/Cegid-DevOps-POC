/**
 * @author Varun Molla - Comforth Karoo
 * @date Creation 2021-11-11
 * @description Test class for apex class WS003_GetSessionsFromXRP
 *              
*/
@isTest
public class WS003_GetSessionsFromXRP_TEST {

    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    
    @TestSetup static void setup(){  
        System.runAs(adminUser){ 
            //create product List
            List<Product2> listProductList = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List')
            };
            insert listProductList;

            B2B_Settings__c settings = new B2B_Settings__c();
            settings.StoreLoginURL__c = 'Test';
            settings.CommunityId__c = 'Test';
            settings.DefaultBuyerGroup__c  = 'Test';
            settings.StoreDomain__c = 'Test';
            settings.StripePublishableKey__c = 'Test';
            settings.AccessTokenURL__c = 'cegid-oauth-provider';
            settings.AccessTokenClientID__c = 'Test';
            settings.AccessTokenClientSecret__c = 'Test';
            settings.GetUnitaryProductSessionsURL__c = 'trainings';
            insert settings;
        }
    }

    @isTest static void getUnitaryProductSessions_Test() {
        System.runAs(adminUser){
            Test.setMock(HttpCalloutMock.class, new WS003_GetSessionsFromXRP_MOCK());

            Test.startTest();
                WS003_GetSessionsFromXRP.getUnitaryProductSessions('A0001053');     
            Test.stopTest(); 
        }
    }

    public class WS003_GetSessionsFromXRP_MOCK implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            if(req.getEndpoint().contains('cegid-oauth-provider')){
                res.setBody('{"access_token":"7hwdehCZbyJPAdcAhV3DGwu-VreWWskWfV-Y3a1-X_036acsz0K_jVbZ9wP-Rna9Rn0i541DYQaQsCDeC9SH3g","refresh_token": "lPkolBqtiFEQwyQ3Pe71lRNHxARAMF1ZL1TBXfx4SaCzls9M_lSdER5k4Q5hpDeBZQhy1ZxYhnoCyKA5hRQjTA","scope": "READ","token_type": "Bearer","expires_in": 3600}');
                res.setStatusCode(200);
            }else if (req.getEndpoint().contains('trainings')){
                res.setBody('{"success": true,"Result": {"sessions": [{"Etablissement": "1002","Session": "PRU117","Libellé_session": "Test Session 1 Arnaud Serna","Article_formation": "A0001053","Libellé_formation": "Web Formation Yource","Date_début_formation": "25/10/2021","Heure_début_formation": "09:00","Date_fin_formation": "25/10/2021","Heure_fin_formation": "10:30","Lieu_formation": "Web","Quantité_totale_possible": 11.0,"Quantité_inscrits": 0.0},{"Etablissement": "1002","Session": "PRU118","Libellé_session": "Test Session 2 - Arnaud Serna","Article_formation": "A0001053","Libellé_formation": "Web Formation Yource","Date_début_formation": "08/11/2021","Heure_début_formation": "09:00","Date_fin_formation": "08/11/2021","Heure_fin_formation": "10:30","Lieu_formation": "Web","Quantité_totale_possible": 6.0,"Quantité_inscrits": 0.0},{"Etablissement": "1002","Session": "PRU119","Libellé_session": "Test Session 2 - Arnaud Serna","Article_formation": "A0001053","Libellé_formation": "Web Formation Yource","Date_début_formation": "10/11/2021","Heure_début_formation": "09:00","Date_fin_formation": "10/11/2021","Heure_fin_formation": "10:30","Lieu_formation": "Web","Quantité_totale_possible": 6.0,"Quantité_inscrits": 0.0}]}}');
                res.setStatusCode(200);
            }
            return res;
        }
    }
}