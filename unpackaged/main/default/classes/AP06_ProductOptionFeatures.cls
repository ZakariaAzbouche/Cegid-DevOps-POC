/**
 * @description       : 
 * @author            : Keshav Matabadul
 * @group             : 
 * @last modified on  : 02-10-2022
 * @last modified by  : Keshav Matabadul
**/
public with sharing class AP06_ProductOptionFeatures {
    @InvocableMethod(label='Product Option ' description='List of Products Ids')
    public static void getProductOption(List<Product2> productIds){
        // Extract cart id and start processing
        //Id cartId = listWebcartIds[0];
        
        startOrderDeliveryMethod(productIds[0]);
    }

    private static void startOrderDeliveryMethod(Product2  productRecord){

        system.debug('productRecord : ' + productRecord);
        List<SBQQ__ProductOption__c> listPOUpdate = new list<SBQQ__ProductOption__c>();

        //Get All Associated ProductOption 
        List<SBQQ__ProductOption__c> listProductOptions = [SELECT Id,SBQQ__ConfiguredSKU__c,OriginalFeature__c FROM SBQQ__ProductOption__c WHERE SBQQ__ConfiguredSKU__c =:productRecord.Id AND OriginalFeature__c != null];
        system.debug('listProductOptions : ' + listProductOptions.size());

        //Get All Product Features 
        List<SBQQ__ProductFeature__c> listProductFeatures = [SELECT Id,SBQQ__ConfiguredSKU__c,Original_Feature_Id__c FROM SBQQ__ProductFeature__c WHERE  SBQQ__ConfiguredSKU__c =:productRecord.Id AND Original_Feature_Id__c != null];
        system.debug('listProductFeatures : ' + listProductFeatures.size());

        for(SBQQ__ProductOption__c po:listProductOptions){
            for(SBQQ__ProductFeature__c pf:listProductFeatures){
                if(po.OriginalFeature__c == pf.Original_Feature_Id__c){
                    po.SBQQ__Feature__c = pf.Id;
                }
            }
            listPOUpdate.add(po);
        }

        if(listPOUpdate.size()>0){
            update listPOUpdate;
        }

    }

}