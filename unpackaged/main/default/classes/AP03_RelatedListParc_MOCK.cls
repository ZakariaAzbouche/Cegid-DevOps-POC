/* 
----------------------------------------------------------------------
-- - Name          : AP03_RelatedListParc_MOCK
-- - Author        : Comforth
-- - Description   : Mock class for test class
-- - Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 08 Jun-2020  SRA    1.0     Initial version - 
----------------------------------------------------------------------
***********************************************************************/
@isTest
global class AP03_RelatedListParc_MOCK implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        
        
        StaticResource static_resourceParc = [SELECT Id,Body, SystemModStamp
                                  FROM StaticResource 
                                  WHERE Name = 'Vue360_Mock_Parc'
                                  LIMIT 1];
        
        StaticResource static_resourceToken = [SELECT Id,Body, SystemModStamp
                                  FROM StaticResource 
                                  WHERE Name = 'Vue360_Mock_Token'
                                  LIMIT 1];
        
        HttpResponse res = new HttpResponse();
        
        if(req.getMethod()=='GET'){
        	res.setBody(static_resourceParc.Body.toString());
        }else if(req.getMethod()=='POST'){
            res.setBody(static_resourceToken.Body.toString());
        }
        res.setStatusCode(200);
        return res;
    }
}