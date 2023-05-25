/**
 * @description       : Stripe API Mock class
 * @author            : Gulshan DOORGAH gulshan.doorgah@comforth-karoo.eu
 * @group             : B2B
 * @last modified on  : 2021-11-30
 * @last modified by  : Gulshan DOORGAH gulshan.doorgah@comforth-karoo.eu
**/
@isTest
global class B2B_StripeAdapter_MOCK implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        System.debug(req.getEndpoint());
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(req.getEndpoint().contains('charges')){
            res.setBody('{"amount": 10000}');
        }else if(req.getEndpoint().contains('tokens')){
            res.setBody('{"id": "token"}');
        }
        
        res.setStatusCode(200);
        return res;
    }
}