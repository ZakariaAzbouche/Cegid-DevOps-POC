/**
 * @author Akshi Boojhawon - Comforth
 * @date 2020-07-17
 * @description controller class for LC01_RelatedListAccountingSituation
 */
public class AP05_RelatedListAccSituation {

    @AuraEnabled
    public static Map <string,object> fetchData(Id recordId) {
        
        Map <string,object> mapToken = new Map<string,object>();
        Map <string,object> mapAston = new Map<string,object>();

        Account acc= [select Id,ERP_Number__c from Account where Id =: recordId];
        string erp_Number = acc.ERP_Number__c;
        
        Http httpToken = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(system.Label.Vue360SouscriptionToken);
        req.setMethod('POST');
        HttpResponse res = httpToken.send(req);
        string TokenResponse = res.getBody();
        mapToken=(Map<String, Object>) JSON.deserializeUntyped(TokenResponse);
        if(mapToken.containsKey('access_token')){
            String Token = string.valueof(mapToken.get('access_token'));
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(system.Label.Vue360_AstonURL+erp_Number+'/recovery-status');
            request.setMethod('GET');
            request.setHeader('Authorization','Bearer '+Token);
            HttpResponse response = http.send(request);
            
            if(response.getStatusCode()==200){
                string returnData= response.getBody();
                if(returnData!=null){
                    mapAston= (Map<String, Object>) JSON.deserializeUntyped(returnData);
                    return mapAston;
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
        } else {
            return new Map <String, Object>{
                'error' => system.Label.AuthentificationFailed
            };
        }
        
    }
}