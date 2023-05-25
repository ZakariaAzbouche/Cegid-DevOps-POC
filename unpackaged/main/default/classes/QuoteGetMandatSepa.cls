/**
 * @author Brahim Boulmaarouf - Comforth
 * @date 2020-06-25
 * @modified 2020-08-14 - Shamina 
 * @description retrieve webservice for MandatSepat 
 *              
*/
public with sharing class QuoteGetMandatSepa {
    @AuraEnabled
    public static Map <string,object> getData(Id RecordId) {
        system.debug(' recordId : ' + recordId);

       SBQQ__Quote__c  itemQuote =[select  id,  name, SBQQ__Account__c, SBQQ__Account__r.ERP_Number__c, Billing_Account__r.ERP_Number__c,
          SBQQ__PriceBook__c, SBQQ__PriceBook__r.Cegid_Entity__c,
          SBQQ__PriceBook__r.Entity_ICS__c from SBQQ__Quote__c   where id=:RecordId];

        system.debug('ItemQuote ERPnum:'+  ItemQuote.SBQQ__Account__r.ERP_Number__c);
        //string account_ERPNum=ItemQuote.SBQQ__Account__r.ERP_Number__c;  
        String account_ERPNum =  ItemQuote.Billing_Account__r.ERP_Number__c; 

        string priceBook_EntityICSC =ItemQuote.SBQQ__PriceBook__r.Entity_ICS__c;            
        string priceBook_EntityCegid=ItemQuote.SBQQ__PriceBook__r.Cegid_Entity__c;

        List<Entity__c>  listEntity=[Select id,ICS__c,Entity_code__c from Entity__c where  id=:
               PriceBook_EntityCegid];    
               
        //system.debug('ItemQuote ERPnum:'+  itemQuote.SBQQ__Account__r.ERP_Number__c);
        system.debug('ItemQuote ERPnum:'+  itemQuote.Billing_Account__r.ERP_Number__c);
        
        if ( string.isBlank(itemQuote.SBQQ__PriceBook__c) ||  listEntity.size()==0 ||  string.isBlank(listEntity[0].Entity_code__c) )
        {
            return new Map <String, Object>{
               'error' => system.Label.QuotePriceBooKCegidEntity   
            };
        }
        else { 
            string cegidEntityCodeC=ListEntity[0].Entity_code__c;
            Map <string,object> mapToken = new Map<string,object>();

            Http httpToken = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(system.Label.Vue360SouscriptionToken);
            req.setMethod('POST');
            HttpResponse res = httpToken.send(req);
            system.debug('res' +res.getBody());
            string tokenResponse = res.getBody();
            mapToken=(Map<String, Object>) JSON.deserializeUntyped(TokenResponse);
            String token = string.valueof(mapToken.get('access_token'));
            system.debug('mapToken :'+mapToken);
            system.debug('Token :'+Token);

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            // Account_ERPNum='90284689'; //2 mandats = 90375811;
            //1 mandats ='90284689', '90027535', 90131486    // 0 mandats '90313594';'90001430';'90004124'
            //PriceBook_EntityICSC='1';       //Cegid_EntityCodeC='1002' ;
            //string EndPoint= 'https://dev-exp-cegid-account-mandates-api.de-c1.eu1.cloudhub.io/api/exp-cegid-account-mandates-development/v1/accounts/90085603/codeSociete/1002/ics/1/mandates';
            //https://dev-exp-cegid-account-mandates-api.de-c1.eu1.cloudhub.io/api/exp-cegid-account-mandates-development/v1/accounts/{erp_number}/codeSociete/{codeSociete}/ics/{ICS}/mandates
           
            string endPoint=system.Label.GetMandatSepa+ Account_ERPNum+ '/codeSociete/'+ 
                  CegidEntityCodeC +'/ics/'+PriceBook_EntityICSC+'/mandates';
            request.setEndpoint(EndPoint);    
            system.debug(EndPoint);
            request.setMethod('GET');
            request.setHeader('Authorization','Bearer '+Token);
            system.debug('request.Header' + request.getHeader('Authorization'));
            HttpResponse response = http.send(request);
            system.debug('response' +response.getBody());
            system.debug('response status' +response.getStatusCode());
            string returnData= response.getBody();

            if(response.getStatusCode()==200){
                if(returnData!=null){
                   QuoteGetMandatSepa_wrapper mapMandatSepas =QuoteGetMandatSepa_wrapper.parse(returnData);
                   System.debug('$$$mapMandatSepas: ' + mapMandatSepas);
                   return new Map <String, Object>{
                    'mapMandatSepas' => mapMandatSepas
                        };
                }
            }

            //B-0680 (Shamina 2020-08-14) : Show detailed error details when web service fails
            Map<String, Object> mapResp = (Map<String, Object>) JSON.deserializeUntyped(returnData);
            Map<String, Object> mapError = (Map<String, Object>)mapResp.get('error'); 
            System.debug('mapError : ' + mapError);  
            String errorMessage = '';       
            if(mapError.get('errorDescription') != null){
                errorMessage = mapError.get('errorDescription') + '';
            }else{
                errorMessage = system.Label.Error_Message_WS;
            }
            return new Map <String, Object>{
              'error' => errorMessage  };
            }
    }

    @AuraEnabled                      
	public static String  SaveMondat(string RecordId, string str ) {
       	String response = 'SUCCESS';
        try{
			
       		List<String> Parameters = str.split('-');
       		System.debug(Parameters);  // IBAN, BIC, UMR, BanKName, BanKCity
    
       		string IBAN       =Parameters[0];
       		string BIC        =Parameters[1];
       		string UMR        =Parameters[2];
       		string BankName   =Parameters[3];
       		string BankCity   =Parameters[4];

       		SBQQ__Quote__c CurrentQuote= [SELECT  IBAN__c,BIC__c, UMR__c,Bank_Name__c, Bank_City__c 
            								FROM SBQQ__Quote__c 
                                            WHERE id =: RecordId];
       
       		CurrentQuote.IBAN__c     =IBAN;
       		CurrentQuote.BIC__c      =BIC;
       		CurrentQuote.UMR__c      =UMR;
           	CurrentQuote.Bank_Name__c=BankName;
       		CurrentQuote.Bank_City__c=BankCity;
        
            update CurrentQuote;       
        }catch(Exception e){
			System.debug('Error--'+e.getMessage());
            response = e.getMessage();
		}
        return response;
    }
}