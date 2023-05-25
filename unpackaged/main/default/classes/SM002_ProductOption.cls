/**
* @author Keshav - Comforth
* @date 2020-06-04
* @modified 2020-06-04
* @group SM002_ProductOption
* @object Product Option
* @description 
*/
public class SM002_ProductOption {
    
    public static void updatePurchasingPrice(List<SBQQ__ProductOption__c> listProductOptions, Boolean isDelete){
        List<Product2> listProdUpdate = new  List<Product2>();
        Map<id,Product2> product2Map = new Map<id,Product2>();
        set<Id> prodIdsSet = new set<Id>();
        
        for(SBQQ__ProductOption__c po:listProductOptions){
            prodIdsSet.add(po.SBQQ__OptionalSKU__c);
            prodIdsSet.add(po.SBQQ__ConfiguredSKU__c);
        }
        
        Map<Id, Product2> mapProduct = new Map<Id, Product2>([Select id , recordtype.developername, Purchasing_Price__c,Schedulable__c from Product2 where Id IN:prodIdsSet]);
        
        for(SBQQ__ProductOption__c po:listProductOptions){
            
            Product2 tempArticle = new Product2();
            if(mapProduct.containsKey(po.OptionalSKU_ID__c)){
                tempArticle = mapProduct.get(po.OptionalSKU_ID__c);
            }
            
            Product2 tempProduct = new Product2();
            if(mapProduct.containsKey(po.SBQQ__ConfiguredSKU__c)){
                tempProduct = mapProduct.get(po.SBQQ__ConfiguredSKU__c);
            }
            
            
            if(tempArticle.recordtype.developername == 'Article' &&  tempProduct.recordtype.developername == 'Product' && isDelete == false){
                if(tempArticle.Purchasing_Price__c != null && po.SBQQ__Quantity__c != null){
                    //tempProduct.Purchasing_Price__c = (po.SBQQ__Quantity__c != null)?tempArticle.Purchasing_Price__c * po.SBQQ__Quantity__c:tempArticle.Purchasing_Price__c;
                    tempProduct.Purchasing_Price__c = tempArticle.Purchasing_Price__c * po.SBQQ__Quantity__c;
                }else{
                    tempProduct.Purchasing_Price__c = 0;
                }
                tempProduct.Schedulable__c = po.Schedulable__c;
                listProdUpdate.add(tempProduct);
            }else if(tempProduct.recordtype.developername == 'Product' && isDelete == false && (tempArticle.recordtype.developername != 'Article' || tempArticle == null )){
                tempProduct.Purchasing_Price__c = null;
                tempProduct.Schedulable__c = false;
                listProdUpdate.add(tempProduct);
            }else if(isDelete == true){
                tempProduct.Purchasing_Price__c = null;
                tempProduct.Schedulable__c = false;
                listProdUpdate.add(tempProduct);
            }
        }
        
        product2Map.putall(listProdUpdate);
        
        if(product2Map.size()>0){
            update product2Map.values();
        }
        //update listProdUpdate;
    }
    
    
    public static void checkDoubleRecords(List<SBQQ__ProductOption__c> listProductOptions, Boolean isDelete){

        System.debug('listProductOptions : ' + listProductOptions);
        
        set<Id> prodIdsSet = new set<Id>();
        
        for(SBQQ__ProductOption__c po:listProductOptions){
            prodIdsSet.add(po.SBQQ__ConfiguredSKU__c);
        }

        Map<Id, set<Id>>  mapProductOptions= new Map<Id, set<Id>>();

        for(SBQQ__ProductOption__c po:[SELECT Id, SBQQ__ConfiguredSKU__c,SBQQ__OptionalSKU__c 
                                      FROM  SBQQ__ProductOption__c WHERE SBQQ__ConfiguredSKU__c IN:prodIdsSet 
                                      AND SBQQ__ConfiguredSKU__r.recordtype.developername = 'Product' 
                                      AND SBQQ__OptionalSKU__r.recordtype.developername = 'Article']){

                                        set<Id> tempSetArticleIds =(mapProductOptions.get(po.SBQQ__ConfiguredSKU__c) != null)?mapProductOptions.get(po.SBQQ__ConfiguredSKU__c):new set<Id>();
                                        tempSetArticleIds.add(po.SBQQ__OptionalSKU__c);
                                        mapProductOptions.put(po.SBQQ__ConfiguredSKU__c,tempSetArticleIds);

        }
             
        
        for(SBQQ__ProductOption__c newPo:listProductOptions){

            set<Id> tempSetArticleIds =(mapProductOptions.get(newPo.SBQQ__ConfiguredSKU__c) != null)?mapProductOptions.get(newPo.SBQQ__ConfiguredSKU__c):new set<Id>();

            if(tempSetArticleIds.contains(newPo.SBQQ__OptionalSKU__c)){
                newPo.addError(System.Label.VR_checkDoubleArticleForProduct);
            }
            
        }
        
    }
    
    
    
}