/**
* @author Brahim - Comforth
* @date 2020-015-04
* @group UTIL
* @description Classe AP01_RelatedListContrat_MOCK
*/
@isTest
  global class QuoteGetMandatSepa_Mock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {           
        StaticResource static_resourceSoucription = [SELECT Id,Body, SystemModStamp
             From StaticResource where Name = 'Vue360_MockUp_MondatSepa' Limit 1];
        
        StaticResource static_resourceToken = [SELECT Id,Body, SystemModStamp
            from StaticResource where Name = 'Vue360_Mock_Token' Limit 1];        
        HttpResponse res = new HttpResponse();
        
        if(req.getMethod()=='GET'){
        	res.setBody(static_resourceSoucription.Body.toString());            
        }else if(req.getMethod()=='POST'){
            res.setBody(static_resourceToken.Body.toString());
        }
        
        HttpResponse[] responses = new HttpResponse[0];
        res.setStatusCode(200);
        return res;
    }
}