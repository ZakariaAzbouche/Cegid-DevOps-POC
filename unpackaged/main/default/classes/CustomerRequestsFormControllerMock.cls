/**
 * @author           : Soufiane LOGDALI soufiane.logdali@comforth-karoo.eu
 * created on  : 20/07/2022
**/


@isTest
global class CustomerRequestsFormControllerMock implements HttpCalloutMock {
    private String type;

    global CustomerRequestsFormControllerMock(String type) {
        this.type = type;
    }

    global HTTPResponse respond(HTTPRequest req) {
        
        StaticResource static_resourceToken = [SELECT Id,Body, SystemModStamp
        FROM StaticResource 
        WHERE Name = 'Vue360_Mock_Token'
        LIMIT 1];

        StaticResource static_invoiceLines = [SELECT Id,Body, SystemModStamp
                                  FROM StaticResource 
                                  WHERE Name = 'INT01_Mock_InvoiceLines'
                                  LIMIT 1];

        StaticResource static_subscriptionLines = [SELECT Id,Body, SystemModStamp
                                  FROM StaticResource 
                                  WHERE Name = 'INT02_Mock_SubscriptionLines'
                                  LIMIT 1];
        
        HttpResponse res = new HttpResponse();
        
        if(req.getMethod()=='GET'){
            if(type == 'InvoiceLines'){
                res.setBody(static_invoiceLines.Body.toString());
            } else {
                res.setBody(static_subscriptionLines.Body.toString());
            }        	
        }else if(req.getMethod()=='POST'){
            res.setBody(static_resourceToken.Body.toString());
        }
        res.setStatusCode(200);
        return res;
    }
}