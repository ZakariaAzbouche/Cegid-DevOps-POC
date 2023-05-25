/**
 * @author Akshi Boojhawon - Comforth
 * @date 2020-07-20
 * @description Mock class for Test class AP05_RelatedListAccSituation_TEST
 */
@isTest
global class AP05_RelatedListAccSituation_MOCK implements HttpCalloutMock {
    private String indicatorVar;

    global AP05_RelatedListAccSituation_MOCK(String indicatorVar) {
        this.indicatorVar = indicatorVar;
    }
    global HTTPResponse respond(HTTPRequest req) {
        
        
        StaticResource static_resourceAston = [SELECT Id,Body, SystemModStamp
                                  FROM StaticResource 
                                  WHERE Name = 'Vue360_Mock_Aston'
                                  LIMIT 1];
        
        StaticResource static_resourceToken = [SELECT Id,Body, SystemModStamp
                                  FROM StaticResource 
                                  WHERE Name = 'Vue360_Mock_Token'
                                  LIMIT 1];

        HttpResponse res = new HttpResponse();

        if (indicatorVar == 'success') {        
            if(req.getMethod()=='GET'){
        	    res.setBody(static_resourceAston.Body.toString());
            }else if(req.getMethod()=='POST'){
                res.setBody(static_resourceToken.Body.toString());
            }
            res.setStatusCode(200);

        } else if (indicatorVar == 'error') {
            if(req.getMethod()=='GET'){
        	    res.setBody(static_resourceAston.Body.toString());
            }else if(req.getMethod()=='POST'){
                res.setBody(static_resourceToken.Body.toString());
            }
            res.setStatusCode(401);

        } else if (indicatorVar == 'authFailed') {
            if(req.getMethod()=='GET'){
        	    res.setBody(static_resourceAston.Body.toString());
            }else if(req.getMethod()=='POST'){
                res.setBody('{}');
            }
            res.setStatusCode(401);
        }
        return res;
    }
}