/**
 * @description       : 
 * @author            : keshav Matabadul
 * @group             : 
 * @last modified on  : 11-28-2021
 * @last modified by  : keshav Matabadul
**/
public class B2B_QuoteGetMandatSepa {

    @AuraEnabled
    public static Map <string,object> getData(List<Id> listCartIds) {

        String pricebookB2B = System.Label.B2BStorePricebookId;// PriceBook Used For Store

        Set<Id> accIds = new set<Id>();
        Set<Id> storeIds = new set<Id>();
        List<Entity__c>  listEntity = new List<Entity__c>();

        //List<WebCart> listCart = [SELECT Id,AccountId,Account.Name,WebStore.Name,WebStoreId,Owner.Name FROM  WebCart WHERE Id=:listCartIds];
        

        for(WebCart car:[SELECT Id,AccountId,Account.Name,WebStore.Name,WebStoreId,Owner.Name FROM  WebCart WHERE Id=:listCartIds]){
            accIds.add(car.AccountId);
            storeIds.add(car.WebStoreId);
        }

        //Get Erp number of the account 
        String account_ERPNum = [SELECT Id,ERP_Number__c   From Account WHERE Id IN:accIds].ERP_Number__c;

         //Get Store Pricebook
         Pricebook2 pb;
        if(Test.isRunningTest()){
            pb = [SELECT id,Cegid_Entity__c,Entity_ICS__c FROM Pricebook2  WHERE IsActive = True LIMIT 1];
        }else{
            pb = [SELECT id,Cegid_Entity__c,Entity_ICS__c FROM Pricebook2  WHERE Id =:pricebookB2B  AND IsActive = True LIMIT 1]; 
        }
       
       

        //List<WebStorePricebook> listWSP = [SELECT Id,Pricebook2Id,WebStoreID,Pricebook2.Cegid_Entity__c,Pricebook2.Entity_ICS__c  FROM WebStorePricebook WHERE WebStoreID IN:storeIds limit 1 ];

        //String account_ERPNum = accERP.ERP_Number__c;
        String priceBook_EntityICSC = pb.Entity_ICS__c;

        //Used to select Entity
        String priceBook_EntityCegid = pb.Cegid_Entity__c;

        if(priceBook_EntityCegid != null){
            listEntity=[Select id,ICS__c,Entity_code__c from Entity__c where  id=:PriceBook_EntityCegid];
        }

        if(listEntity.size()==0 ||  string.isBlank(listEntity[0].Entity_code__c)){
            return new Map <String, Object>{
                'error' => system.Label.QuotePriceBooKCegidEntity   
             };
        }else{
            string cegidEntityCodeC =ListEntity[0].Entity_code__c;
            Map <string,object> mapToken = new Map<string,object>();

            Http httpToken = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(system.Label.Vue360SouscriptionToken);
            req.setMethod('POST');
            HttpResponse res = httpToken.send(req);
            string tokenResponse = res.getBody();
            mapToken=(Map<String, Object>) JSON.deserializeUntyped(TokenResponse);
            String token = string.valueof(mapToken.get('access_token'));

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            string endPoint=system.Label.GetMandatSepa+ Account_ERPNum+ '/codeSociete/'+CegidEntityCodeC +'/ics/'+PriceBook_EntityICSC+'/mandates';
            //string endPoint='https://dev-exp-cegid-account-mandates-api.de-c1.eu1.cloudhub.io/api/exp-cegid-account-mandates-development/v1/accounts/90085603/codeSociete/1002/ics/FR14ZZZ497659/mandates';
            request.setEndpoint(EndPoint);  
            request.setMethod('GET');
            request.setHeader('Authorization','Bearer '+Token);
            HttpResponse response = http.send(request);
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

            Map<String, Object> mapResp = (Map<String, Object>) JSON.deserializeUntyped(returnData);
            Map<String, Object> mapError = (Map<String, Object>)mapResp.get('error');  
            
            System.debug('mapError : ' + mapError);
            String errorMessage = '';
            String responseMessage = mapError.get('errorDescription').toString(); 
            
            if(responseMessage != null){
                if(responseMessage.contains('HTTP')){
                    errorMessage = system.Label.Error_Message_WS;
                }else{
                    errorMessage = mapError.get('errorDescription') + '  ';
                }
            }
                
            // if(mapError.get('errorMessage') != null){
            //     if(mapError.get('errorDescription')){
            //         errorMessage = system.Label.Error_Message_WS;
            //     }else{
            //         errorMessage = mapError.get('errorDescription') + '  ';
            //     }
                
            // }
            return new Map <String, Object>{
              'error' => errorMessage}; //+ system.Label.Error_Message_WS };
        }
    }

    // @AuraEnabled
    // public static WebCart createOrderRecord(List<Id> listCartIds, Map<String,String> mapMandatSepa){
    //     WebCart wcObject = [SELECT Id,Name,AccountId,WebStoreId,Bank_City__c,Bank_Name__c,BIC__c,IBAN__c,UMR__c,TECH_IsSepaCustom__c FROM WebCart WHERE Id =:listCartIds limit 1];

    //     wcObject.Bank_City__c = (mapMandatSepa.get('bankCity') != null? mapMandatSepa.get('bankCity'):'');
    //     wcObject.Bank_Name__c = (mapMandatSepa.get('bankName') != null? mapMandatSepa.get('bankName'):'');
    //     wcObject.BIC__c = (mapMandatSepa.get('bic') != null? mapMandatSepa.get('bic'):'');
    //     wcObject.IBAN__c = (mapMandatSepa.get('iban') != null? mapMandatSepa.get('iban'):'');
    //     wcObject.UMR__c = (mapMandatSepa.get('rum') != null? mapMandatSepa.get('rum'):'');
    //     wcObject.TECH_IsSepaCustom__c = (mapMandatSepa.get('isSepaCustom') == 'true')?'true':'false';
    //     update wcObject;

    //     return wcObject;
    // }
}