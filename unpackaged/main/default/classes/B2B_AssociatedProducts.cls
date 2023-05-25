/**
 * @author Keshav - Comforth Dev Team
 * @date 2020-07
 * @group Cegid
 * @description  class for B2B_AssociatedProducts 
 * 
 */
public without sharing class B2B_AssociatedProducts {
    @AuraEnabled
    public static Map<String, Object> getProducts(String productId, String recType){

        List<SBQQ__ProductOption__c> listRelatedProduct = [SELECT Id, SBQQ__OptionalSKU__r.Name, SBQQ__OptionalSKU__r.Id, SBQQ__OptionalSKU__r.Reference_Number__c, SBQQ__OptionalSKU__r.Description, SBQQ__ConfiguredSKU__c, SBQQ__ConfiguredSKU__r.Reference_Number__c FROM SBQQ__ProductOption__c WHERE /* SBQQ__ConfiguredSKU__r.Recordtype.Developername = :recType AND */ SBQQ__ConfiguredSKU__c = :productId /* AND SBQQ__OptionalSKU__r.Reference_Number__c LIKE 'P%' */];

        Map<String, Object> mapResponse = new Map<String, Object>();

        if(listRelatedProduct.size() > 0){
            if(Test.isRunningTest()){
                Test.setMock(HttpCalloutMock.class, new WS003_GetSessionsFromXRP_TEST.WS003_GetSessionsFromXRP_MOCK());
            }

            mapResponse = getUnitaryProductSessions(listRelatedProduct[0].SBQQ__OptionalSKU__r.Reference_Number__c);
            return new Map<String, Object>{
                'relatedProductInfo' => listRelatedProduct[0],
                'relatedProductSessionInfo' => mapResponse
            };
        }else{
            return null;
        }
    }

    @AuraEnabled
    public static Product2 getProductCategoryLabel(String productId){
       return [SELECT toLabel(Category__c) FROM Product2 WHERE Id = :productId];
    }

    @AuraEnabled
    public static Map<String, Object> getUnitaryProductSessions(String productId){
        return WS003_GetSessionsFromXRP.getUnitaryProductSessions(productId);
    }

    /* private static String dummyReponseWithNoSessions(){
        return '{"success": true,"Result": {"sessions": []}}';
    } */
}