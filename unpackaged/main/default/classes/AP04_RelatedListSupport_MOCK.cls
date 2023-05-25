/***
* @author      Comforth - SRA
* @date        16/07/2020
* @description Class for AP04_RelatedListSupport_MOCK
***/
@isTest
global class AP04_RelatedListSupport_MOCK implements HttpCalloutMock{
    private String indicatorVar;

    global AP04_RelatedListSupport_MOCK(String indicatorVar) {
        this.indicatorVar = indicatorVar;
    }

    global HTTPResponse respond(HTTPRequest req) {
        
        
        StaticResource static_resourceParc = [SELECT Id,Body, SystemModStamp
                                              FROM StaticResource 
                                              WHERE Name = 'Vue360_Mock_support'
                                              LIMIT 1];
        
        StaticResource static_resourceToken = [SELECT Id,Body, SystemModStamp
                                               FROM StaticResource 
                                               WHERE Name = 'Vue360_Mock_Token'
                                               LIMIT 1];
        
        HttpResponse res = new HttpResponse();
        if (indicatorVar == 'success') {  
            if(req.getMethod()=='GET'){
                res.setBody(static_resourceParc.Body.toString());
            }
            if(req.getMethod()=='POST'){
                res.setBody(static_resourceToken.Body.toString());
            }
            if(req.getMethod()=='PATCH'){
                res.setBody('{"success": true}');
            }
            res.setStatusCode(200);
        }else if (indicatorVar == 'error') {
            if(req.getMethod()=='GET'){
        	    res.setBody(static_resourceParc.Body.toString());
            }
            if(req.getMethod()=='POST'){
                res.setBody(static_resourceParc.Body.toString());
            }
            if(req.getMethod()=='PATCH'){
                res.setBody('"error": {"errorCorrelationId": "873e2aa224e343f9845d72e47082fd78","errorCode": "API-HTTP-415","errorTimestamp": "2023-05-11T13:14:31.416+0000","errorDescription": "API exception: UNSUPPORTED_MEDIA_TYPE"}');
            }
            res.setStatusCode(401);

        } else if (indicatorVar == 'authFailed') {
            if(req.getMethod()=='GET'){
        	    res.setBody(static_resourceParc.Body.toString());
            }else if(req.getMethod()=='POST'){
                res.setBody('{}');
            }
            res.setStatusCode(401);
        }
        return res;
    }
    
}