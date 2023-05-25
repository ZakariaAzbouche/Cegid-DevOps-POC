/**
 * @author Shamina M - Comforth Karoo
 * @date 2020-11-06
 * @description TH_Product2 - Handler class for Product2 trigger
 * @modification 1/19/2021 new Method in AfterUpdate by Kmm B-0992 B-0484
 *              
*/
public without sharing class TH_Product2 extends TriggerHandler{

    public static final Id ARTICLE_RECTYPEID =Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Article').getRecordTypeId();
    public static final Id PRODUCT_RECTYPEID =Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();

    /**
     * @author Shamina M - Comforth Karoo
     * @date 2020-11-06
     * @description afterUpdate logic          
    */
    public override void afterUpdate() {
        Set<Id> setArticlesIds = new Set<Id>();
        Set<id> setProductIds = new Set<Id>();//B-0992 B-0484
        for(Product2 prod:(List<Product2>)Trigger.new){
            Product2 oldProd = (Product2)trigger.oldMap.get(prod.Id);
            //US W-001416 - handle update on products when article flags have changed
            if(canTriggerByFeature('FlagHasOnSiteArticle__c') && 
                prod.RecordTypeId == ARTICLE_RECTYPEID &&
                (prod.Realization_Conditions__c != oldProd.Realization_Conditions__c ||
                prod.Catalog__c != oldProd.Catalog__c ||
                prod.Schedulable__c != oldProd.Schedulable__c ||
                prod.OPCA_Eligible__c != oldProd.OPCA_Eligible__c || 
                prod.Service_Term__c != oldProd.Service_Term__c ||
                prod.Max_Trainee__c != oldProd.Max_Trainee__c || //B-1825
                prod.Duration__c != oldProd.Duration__c)){
                setArticlesIds.add(prod.Id);
            } 
            
            //B-0992 B-0484
            if( prod.Family != oldProd.Family || prod.StructureLevel2__c != oldProd.StructureLevel2__c 
            || prod.IsActive != oldProd.IsActive || prod.Product_Line__c != oldProd.Product_Line__c){
                setProductIds.add(prod.Id);
            }
        }
        
        if(setArticlesIds.size()>0){
            SM007_FlagProductHasOnSiteArticle.updatedRelatedProducts(setArticlesIds);
        }

        if(setProductIds.size()>0){
            SM015_FindCorrectAttachedDocument.updateLinkProduct(setProductIds);
        }

    }

    /**
     * @author Shamina M - Comforth Karoo
     * @date 2020-11-06
     * @description afterDelete logic          
    */
    public override void afterDelete() {
        Set<Id> setArticlesIds = new Set<Id>();
        for(Product2 oldProd:(List<Product2>)Trigger.old){
            //US W-001416 - handle update on products when article flags have changed
            if(canTriggerByFeature('FlagHasOnSiteArticle__c') && 
                oldProd.RecordTypeId == ARTICLE_RECTYPEID /*&&
                (oldProd.Realization_Conditions__c == 'On Site' ||
                oldProd.Catalog__c == true ||
                oldProd.OPCA_Eligible__c == true)*/){
                setArticlesIds.add(oldProd.Id);
            }             
        }
        
        if(setArticlesIds.size()>0){
            //sending null param to get SOQL query result because SBQQ__OptionalSKU__c field will be reset to null on SBQQ__ProductOption__c records 
            SM007_FlagProductHasOnSiteArticle.updatedRelatedProducts(null);
        }
    }
}