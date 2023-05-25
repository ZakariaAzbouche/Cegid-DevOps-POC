/**
 * @author Keshav M - Comforth Karoo
 * @date 2020-12-15
 * @description 
*/
public with sharing class WS002_FindContrat {
    @AuraEnabled
    public static resultWrapper getWebservice(String EntityName,Id recordId){
        system.debug(' EntityName : ' + EntityName);
        resultWrapper rw = new resultWrapper();
        
        Map <string,object> mapContract = new Map<string,object>();
        List<object> listContract = new List<object>();
        List<opportunity> listopp=[SELECT AccountId from opportunity where Id =:recordId limit 1];
        List<Account> listAcc = [SELECT ERP_Number__c FROM Account where Id =:listopp[0].AccountId limit 1];
        system.debug('listopp : ' + listopp);
        Map <string,object> mapToken = new Map<string,object>();
        
        try { 
            //Get webservice Token 
            Http httpToken = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(system.Label.RecuperationDesContratsToken);
            req.setMethod('POST');
            HttpResponse res = httpToken.send(req);
            system.debug('res' +res.getBody());
            string TokenResponse = res.getBody();
            mapToken=(Map<String, Object>) JSON.deserializeUntyped(TokenResponse);
            String Token = string.valueof(mapToken.get('access_token'));
            system.debug('mapToken'+mapToken);
            system.debug('Token'+Token);
            
            
            //Get Data
            
            //Custom label (Endpoint_CegidSubscriptions,Client_id,client_secret)
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setTimeout(120000);
            system.debug('listAcc[0].ERP_Number__c : '  + listAcc[0].ERP_Number__c);
            system.debug('EntityName : ' + EntityName);
            //request.setEndpoint('https://dev-exp-cegid-sync-subscriptions-api.de-c1.eu1.cloudhub.io/api/exp-cegid-synchronisation-subscriptions-api-development/v1/subscriptions/accounts/90504702?zuoraEntityName='+EntityName );
            String endPoint = system.Label.RecuperationDesContrats+listAcc[0].ERP_Number__c+'/subscriptions?zuoraEntityName='+EntityName;
            request.setEndpoint(endPoint);
            system.debug('request Endpoint : ' + endPoint);
            //request.setEndpoint(system.Label.Endpoint_CegidSubscriptions+EntityName);
            request.setMethod('GET');
            request.setHeader('Authorization','Bearer '+Token);
            //request.setHeader('client_id',system.Label.Client_id);
            //request.setHeader('client_secret',system.Label.client_secret);
            HttpResponse response = http.send(request);
            string returnData= response.getBody();
            system.debug('response' +response.getBody());
            system.debug('response status' +response.getStatusCode());
            rw.Statuscode = String.valueof(response.getStatusCode());
            if(String.isNotBlank(returnData)){
                rw.webResponse = (List<subscription>) System.JSON.deserialize(returnData, List<subscription>.class);
                rw.webResponse = manageWebResponse(rw.webResponse);
            }
            rw.message = String.valueof(response.getStatus());
            
        } catch(System.CalloutException e) { 
            system.debug('e.getMessage()' + e.getMessage());
            //rw.Statuscode = e.getStatusCode();
            rw.message = e.getMessage();
            
        }  
        catch(DmlException e) {
            rw.message = e.getMessage();    
        } catch(SObjectException e) {
            rw.message = e.getMessage();   
        } catch(Exception e) {
            rw.message = e.getMessage();    
        }
        system.debug('rw.message '+rw.message);
        system.debug('rw.webResponse '+rw.webResponse);
        
        return rw;
    }
    
    public static List<subscription> manageWebResponse(List<subscription> webResponse){
        //Calculate when the subscription is selectable by the user
        For(subscription sub:webResponse){
            if(sub.status == 'Pending Activation'){
                sub.isDisable = true;
                sub.message = 'The contract is not selectable because its status is "Pending Activation".';
            }/*else if(!sub.ratePlans.isEmpty()){
                string firstLevelService = null;
                for(ratePlan rt:sub.ratePlans){
                    if(rt.levelService != null && rt.name != 'Commentaire'){
                        if(firstLevelService == null){ //Fil the first level service not null
                            firstLevelService = rt.levelService;
                        }
                        if(firstLevelService != rt.levelService){ //If multiple level services, sub not selectable
                            sub.isDisable = true;
                            sub.message = 'The contract is not selectable because it is multi service levels.';
                        }
                    }
                }
            }*/
        }
        return webResponse;
    }
    
    
    
    @AuraEnabled
    public static resultWrapper saveWebservice(String EntityName, String subscriptionId, String customerId, Id recordId){
        resultWrapper rw = new resultWrapper();
        system.debug('EntityName :' + EntityName);
        system.debug('subscriptionId :' + subscriptionId);
        system.debug('customerId :' + customerId);
        
        Map <string,object> mapResult = new Map<string,object>();
        List<object> listContract = new List<object>();
        
        Map <string,object> mapToken = new Map<string,object>();
        
        try{
            //Get webservice Token 
            Http httpToken = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(system.Label.RecuperationDesContratsToken);
            req.setMethod('POST');
            HttpResponse res = httpToken.send(req);
            system.debug('res' +res.getBody());
            string TokenResponse = res.getBody();
            mapToken=(Map<String, Object>) JSON.deserializeUntyped(TokenResponse);
            String Token = string.valueof(mapToken.get('access_token'));
            
            //Get Data
            
            //Custom label (Endpoint_CegidSubscriptions,Client_id,client_secret)
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setTimeout(120000);
            //request.setEndpoint(system.Label.Endpoint_CegidSubscriptions+EntityName);
            system.debug('subscriptionId : ' + subscriptionId);
            system.debug('EntityName : ' + EntityName);
            system.debug('customerId : ' + customerId);
            String endPoint = system.Label.CreationDesContrats+subscriptionId+'?zuoraEntityName='+EntityName+'&accountId='+customerId+'&oppyId='+recordId;
            request.setEndpoint(endPoint);
            system.debug('Request Endpoint : ' + endPoint);
            //request.setEndpoint('https://dev-exp-cegid-sync-subscriptions-api.de-c1.eu1.cloudhub.io/api/exp-cegid-synchronisation-subscriptions-api-development/v1/subscriptions/8adc8f99763b6a7001764310b8474d50?zuoraEntityName=002&accountId=90475300');
            request.setMethod('GET');
            request.setHeader('Authorization','Bearer '+token);
            
            HttpResponse response = http.send(request);
            string returnData= response.getBody();
            system.debug('returnData ' +returnData);
            rw.Statuscode = String.valueof(response.getStatusCode());
            rw.message = String.valueof(response.getStatus());
            if(String.isNotBlank(returnData)){
                rw.getContractId = (Map<String, Object>) JSON.deserializeUntyped(returnData);
            }
        } catch(System.CalloutException e) { 
            system.debug('e.getMessage()' + e.getMessage());
            rw.message = e.getMessage();
            
        }  
        catch(DmlException e) {
            rw.message = e.getMessage();    
        } catch(SObjectException e) {
            rw.message = e.getMessage();   
        } catch(Exception e) {
            rw.message = e.getMessage();    
        }
        system.debug('rw.message '+rw.message);
        system.debug('rw.Statuscode '+rw.Statuscode);
        system.debug('rw.getContractId '+rw.getContractId);
        system.debug('rw.webResponse '+rw.webResponse);
        return rw;

    }

    //Use wrapper to send respond to JS
    public class resultWrapper{
        @AuraEnabled public string Statuscode ;
        @AuraEnabled public List<subscription> webResponse ;
        @AuraEnabled public string message;
        @AuraEnabled public Map<String, Object> getContractId;
    }
    public class subscription{
        @AuraEnabled public string subscriptionNumber;
        @AuraEnabled public string subscriptionId;
        @AuraEnabled public string status;
        @AuraEnabled public string entity;
        @AuraEnabled public string ordering;
        @AuraEnabled public string billing;
        @AuraEnabled public string paymentMethod;
        @AuraEnabled public string totalCustomerValue;
        @AuraEnabled public string meanRecurringRevenue;
        @AuraEnabled public string paymentTerm;
        @AuraEnabled public string serviceActivationDate;
        @AuraEnabled public string currentTermEndDate;
        @AuraEnabled public string paymentDate;
        @AuraEnabled public string initialTerm;
        @AuraEnabled public string currentTerm;
        @AuraEnabled public string billingfrequency;
        @AuraEnabled public string renewalTerm;
        @AuraEnabled public string resiliationDate;
        @AuraEnabled public string increaseMode;
        @AuraEnabled public boolean autoRenew;
        @AuraEnabled public string increaseType;
        @AuraEnabled public boolean isDisable;
        @AuraEnabled public string message;
        @AuraEnabled public custom customer;
        @AuraEnabled public List<ratePlan> ratePlans;
    }
    public class custom{
        @AuraEnabled public string name;
        @AuraEnabled public string Id;
    }
    public class ratePlan{
        @AuraEnabled public string name;
        @AuraEnabled public string levelService;
    }
}