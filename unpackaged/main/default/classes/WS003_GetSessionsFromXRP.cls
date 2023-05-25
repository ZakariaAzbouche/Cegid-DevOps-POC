/**
 * @author Varun Molla - Comforth Karoo
 * @date 2021-08-01
 * @description 
 * @US W-001638 BtoB_US12TCH_Product Session
*/
public without sharing class WS003_GetSessionsFromXRP {
    
    @testVisible
    private static final B2B_Settings__c B2B_SETTINGS = B2B_Settings__c.getOrgDefaults();
    @testVisible
    private static final String ACCESS_TOKEN_URL = B2B_SETTINGS.AccessTokenURL__c;
    @testVisible
    private static final String CLIENT_ID = B2B_SETTINGS.AccessTokenClientID__c;
    @testVisible
    private static final String CLIENT_SECRET = B2B_SETTINGS.AccessTokenClientSecret__c;
    @testVisible
    private static final String UNITARY_PRODUCT_SESSIONS_URL = B2B_SETTINGS.GetUnitaryProductSessionsURL__c;

    /* @AuraEnabled
    public static Map<String, Object> getProductSessions(String strProductReferenceNumber){
        String strAccessToken = getAccessToken();

        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setMethod('GET');

        String endpoint = 'https://dev-exp-cegid-training-api.de-c1.eu1.cloudhub.io/api/exp-cegid-training-api-development/v1/trainingSessions?article=' +strProductReferenceNumber;

        request.setEndpoint(endpoint);

        request.setHeader('Authorization', 'Bearer ' +strAccessToken);

        HttpResponse res = http.send(request);

        Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());

        return mapResponse;
    }

    public static String getAccessToken(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setTimeout(120000);
        request.setHeader('Content-Type','application/x-www-form-urlencoded;charset=UTF-8');
        request.setHeader('Accept', 'application/json');    
        request.setMethod('GET');

        request.setEndpoint('https://dev-cegid-oauth-provider.de-c1.eu1.cloudhub.io/v2/access-token?');

        String body = 'grant_type=' + 'client_credentials' 
        + '&client_id=' + EncodingUtil.urlEncode('efc7ccce78e54c1fabc3018cf07311d7', 'UTF-8') 
        + '&client_secret=' + EncodingUtil.urlEncode('f9D11291edCD4627A3026315413A64e2','UTF-8') 
        + '&scope=' + EncodingUtil.urlEncode('READ', 'UTF-8');

        request.setBody(body);

        HttpResponse res = http.send(request);
        
        Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());

        return (String)mapResponse.get('access_token');
    } */

    @AuraEnabled
    public static Map<String, Object> getUnitaryProductSessions(String strProductReferenceNumber){
        String strAccessToken = getAccessToken();

        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setMethod('GET');

        String endpoint = UNITARY_PRODUCT_SESSIONS_URL + strProductReferenceNumber;

        request.setEndpoint(endpoint);

        request.setHeader('Authorization', 'Bearer ' +strAccessToken);

        HttpResponse res = http.send(request);

        Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());

        return mapResponse;
    }

    public static String getAccessToken(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setTimeout(120000);
        request.setHeader('Content-Type','application/x-www-form-urlencoded;charset=UTF-8');
        request.setHeader('Accept', 'application/json');    
        request.setMethod('GET');

        request.setEndpoint(ACCESS_TOKEN_URL);

        String body = 'grant_type=' + 'client_credentials' 
        + '&client_id=' + EncodingUtil.urlEncode(CLIENT_ID, 'UTF-8') 
        + '&client_secret=' + EncodingUtil.urlEncode(CLIENT_SECRET,'UTF-8') 
        + '&scope=' + EncodingUtil.urlEncode('READ', 'UTF-8');

        request.setBody(body);

        HttpResponse res = http.send(request);
        
        Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());

        return (String)mapResponse.get('access_token');
    }
}