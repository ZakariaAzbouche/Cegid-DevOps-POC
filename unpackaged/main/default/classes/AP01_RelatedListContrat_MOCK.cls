/**
* @author Sid - Comforth
* @date 2020-015-04
* @group UTIL
* @description Classe AP01_RelatedListContrat_MOCK
*/
@isTest
global class AP01_RelatedListContrat_MOCK implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        
        
        StaticResource static_resourceSoucription = [SELECT Id,Body, SystemModStamp
                                  FROM StaticResource 
                                  WHERE Name = 'Vue360_MockUp_Souscriptions'
                                  LIMIT 1];
        
        StaticResource static_resourceToken = [SELECT Id,Body, SystemModStamp
                                  FROM StaticResource 
                                  WHERE Name = 'Vue360_Mock_Token'
                                  LIMIT 1];
        
        HttpResponse res = new HttpResponse();
        
        if(req.getMethod()=='GET'){
        	res.setBody(static_resourceSoucription.Body.toString());
        }else if(req.getMethod()=='POST'){
            res.setBody(static_resourceToken.Body.toString());
        }
        res.setStatusCode(200);
        return res;
    }
}