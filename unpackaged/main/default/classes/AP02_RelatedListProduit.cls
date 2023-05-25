/* 
----------------------------------------------------------------------
-- - Name          : AP02_RelatedListProduit
-- - Author        : Comforth
-- - Description   : retrieve webservice for products
-- - Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 19 Mar-2020  SRA    1.0     Initial version - 
----------------------------------------------------------------------
***********************************************************************/
public with sharing class AP02_RelatedListProduit {
    
    @AuraEnabled
    public static Map<String, Object> fetchData(string subName,Id recordId) {
        system.debug(' recordId : ' + recordId);
        system.debug(' subName : ' + subName);
        
        Map <string,object> mapProduit = new Map<string,object>();
        Map <string,object> mapToken = new Map<string,object>();

		Http httpToken = new Http();
        HttpRequest req = new HttpRequest();
		req.setEndpoint(system.Label.Vue360SouscriptionToken);
        req.setMethod('POST');
        HttpResponse res = httpToken.send(req);
        system.debug('res' +res.getBody());
        string TokenResponse = res.getBody();
        mapToken=(Map<String, Object>) JSON.deserializeUntyped(TokenResponse);
        String Token = string.valueof(mapToken.get('access_token'));
        system.debug('mapToken'+mapToken);
        system.debug('Token'+Token);
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setTimeout(100000);
        request.setEndpoint(system.Label.SubsctriptionURL+recordId+'/subscriptions/'+subName); 
        //request.setEndpoint('https://dev-exp-cegid-360view-api.de-c1.eu1.cloudhub.io/api/exp-cegid-360View-api-dev/v1/customer360/0019E000016onASQAY/subscriptions/AS003-00000036');
        request.setMethod('GET');
        request.setHeader('Authorization','Bearer '+Token);
        system.debug('request.Header' + request.getHeader('Authorization'));
        HttpResponse response = http.send(request);
        system.debug('response' +response.getBody());
        
        if(response.getStatusCode()==200){
            string returnData= response.getBody();
            if(returnData!=null){
                returnData = returnData.replaceAll('currency', 'currency1');
                mapProduit= (Map<String, Object>) JSON.deserializeUntyped(returnData);
                System.debug('$$$mapProduit: ' + mapProduit);
                return mapProduit; 
            }else{
                return new Map <String, Object>{
                'error' => system.Label.Error_Message_WS
                    };
            }
        }else{
            return new Map <String, Object>{
                'error' => system.Label.Error_Message_WS
                    };
             }
    }
}