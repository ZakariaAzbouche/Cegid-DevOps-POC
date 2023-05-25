/**
* @author Keshav - Comforth
* @date 2021-19-01
* @modified 
* @group TH_Quote
* @object Quote
* @description 
*/
public class SM016_EclatementContrats {
    
    @future(callout=true)
    public static void executeWebService(Set<Id> setQuoteIds){

        
        
        system.debug('QuoteIds executeWebService : ' + setQuoteIds);
        List<SBQQ__Quote__c> listQuote=[SELECT Id,Billing_Account__r.ERP_Number__c,SBQQ__PriceBook__c, SBQQ__PriceBook__r.Entity_ICS__c, SBQQ__Pricebook__r.Cegid_Entity__r.Entity_Code__c  from SBQQ__Quote__c where Id IN:setQuoteIds limit 1];
        Map <string,object> mapToken = new Map<string,object>();

         //Get webservice Token 
         Http httpToken = new Http();
         HttpRequest req = new HttpRequest();
         req.setEndpoint(system.Label.EclatementContractsToken);
         req.setMethod('POST');
         HttpResponse res = httpToken.send(req);
         system.debug('res' +res.getBody());
         string TokenResponse = res.getBody();
         mapToken=(Map<String, Object>) JSON.deserializeUntyped(TokenResponse);
         String Token = string.valueof(mapToken.get('access_token'));

         //Send Data
         Http http = new Http();
         HttpRequest request = new HttpRequest();
         request.setTimeout(100000);
         String endPoint = system.Label.EclatementContrats+listQuote[0].SBQQ__PriceBook__r.Cegid_Entity__r.Entity_Code__c + '/customers/' + listQuote[0].Billing_Account__r.ERP_Number__c + '/quote/' + listQuote[0].Id;
         request.setEndpoint(endPoint);
         system.debug('Request Endpoint : ' + endPoint);
         request.setMethod('GET');
         request.setHeader('Authorization','Bearer '+Token);
         HttpResponse response = http.send(request);
         string returnData= response.getBody();

         system.debug('returnData : ' + returnData); 


         if(returnData != null ){
            Map<String, Object> mapResponse = (Map<String, Object>) JSON.deserializeUntyped(returnData);
            if( mapResponse.get('Success') == true){
                QuoteEclatementContrats.fetchCompanyLabel(setQuoteIds, mapResponse, true); 
            }else{
                QuoteEclatementContrats.fetchCompanyLabel(setQuoteIds, mapResponse, false);
            }
         }

        
    }

    
}