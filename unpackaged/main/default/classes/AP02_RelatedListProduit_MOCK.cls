/**
* @author Sid - Comforth
* @date 2020-015-04
* @group UTIL
* @description Classe AP02_RelatedListProduit_MOCK
*/
@isTest
global class AP02_RelatedListProduit_MOCK implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        
        
        StaticResource static_resourceProduit = [SELECT Id,Body, SystemModStamp
                                  FROM StaticResource 
                                  WHERE Name = 'Vue360_Mock_Produit'
                                  LIMIT 1];
        
        StaticResource static_resourceToken = [SELECT Id,Body, SystemModStamp
                                  FROM StaticResource 
                                  WHERE Name = 'Vue360_Mock_Token'
                                  LIMIT 1];
        
        HttpResponse res = new HttpResponse();
        
        if(req.getMethod()=='GET'){
        	res.setBody(static_resourceProduit.Body.toString());
        }else if(req.getMethod()=='POST'){
            res.setBody(static_resourceToken.Body.toString());
        }
        res.setStatusCode(200);
        return res;
    }
}