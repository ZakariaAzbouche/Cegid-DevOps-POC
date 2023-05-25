/***
* @author      Comforth - SRA
* @date        16/07/2020
* @description Class for AP04_RelatedListSupport
***/
public class AP04_RelatedListSupport {
    
    @AuraEnabled
    public static Map <string,object> fetchData(Id recordId) {
        system.debug(' recordId : ' + recordId);
        
        Map <string,object> mapCases = new Map<string,object>();
        Map <string,object> mapToken = new Map<string,object>();

        Account acc= [select Id,Name,ERP_Number__c from Account where Id =: recordId];
        string erp_Number = acc.ERP_Number__c;
        
        Http httpToken = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(system.Label.Vue360SouscriptionToken);
        req.setMethod('POST');
        HttpResponse res = httpToken.send(req);
        system.debug('res' +res.getBody());
        string TokenResponse = res.getBody();
        mapToken=(Map<String, Object>) JSON.deserializeUntyped(TokenResponse);
        
        if(mapToken.containsKey('access_token')){
            String Token = string.valueof(mapToken.get('access_token'));
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(system.Label.Vue360_CaseURL+erp_Number+'/cases');
            request.setMethod('GET');
            request.setHeader('Authorization','Bearer '+Token);
            HttpResponse response = http.send(request);
            
            if(response.getStatusCode()==200){
                string returnData= response.getBody();
                if(returnData!=null){
                    List<AP04_RelatedListSupport_Wrapper> sourceDeserialized = (List<AP04_RelatedListSupport_Wrapper>) JSON.deserialize(returnData, List<AP04_RelatedListSupport_Wrapper>.class);
                    System.debug('$$$sourceDeserialized: ' + sourceDeserialized);      
                    return new Map <String, Object>{
                        'sourceList' => JSON.deserializeUntyped(response.getBody())
                    };
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

    private class Case_Reason {
        string work_notes;
    }

    @AuraEnabled
    public static Map <string,object> raiseCase(String caseNumber, String body) {
        
        Map <string,object> mapToken = new Map<string,object>();
        
        Http httpToken = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(system.Label.Vue360SouscriptionToken);
        req.setMethod('POST');
        HttpResponse res = httpToken.send(req);
        system.debug('res' +res.getBody());
        string TokenResponse = res.getBody();
        mapToken=(Map<String, Object>) JSON.deserializeUntyped(TokenResponse);
        
        if(mapToken.containsKey('access_token')){
            String Token = string.valueof(mapToken.get('access_token'));
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            System.debug(system.Label.Vue360_RaiseCase+caseNumber);
            request.setEndpoint(system.Label.Vue360_RaiseCase+caseNumber);
            request.setMethod('PATCH');
            request.setHeader('Content-Type', 'application/json; charset=UTF-8');
            request.setHeader('Authorization','Bearer '+Token);
            request.setHeader('Connection','keep-alive');
            request.setHeader('Accept','*/*');

            JSONGenerator gen = JSON.createGenerator(true);    
            gen.writeStartObject();      
            gen.writeStringField('work_notes', body);
            gen.writeEndObject();    
            String jsonS = gen.getAsString();

            request.setBody(jsonS);
            HttpResponse response = http.send(request);
            
            System.debug(response.getStatusCode());
            System.debug(response.getBody());

            if(response.getStatusCode() == 200) {
                return new Map <String, Object>{
                    'success' => true
                };
            }

            Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            Map<String, Object> error = (Map<String, Object>) responseBody.get('error');

            return new Map <String, Object>{
                'success' => false,
                'error' => error.get('errorDescription')
            };

        } else {
            return new Map <String, Object>{
                'error' => system.Label.AuthentificationFailed
            };
        }
    }
    
    @AuraEnabled
    public static Account getAccountName(Id recordId) {
        Account acc= [select Id,Name,ERP_Number__c from Account where Id =: recordId];
        return acc;
    }
    
}