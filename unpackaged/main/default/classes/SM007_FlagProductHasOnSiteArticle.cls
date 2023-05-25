/**
 * @author Shamina M - Comforth Karoo
 * @date 2020-09-14
 * @modified 2020-11-06
 * @description Update parent Product2 checkbox Tech_HasOnSiteArticle__c,Catalog__c
 *              based on equivalent flag on SBQQ__ProductOption__c (US W-001172) 
 *              Added to handle update on Product2(Product) when Product2(Article) flags have changed (US W-001416)
*/
public with sharing class SM007_FlagProductHasOnSiteArticle {
    /**
     * @author Shamina M - Comforth Karoo
     * @date 2020-09-14
     * @description update product2 checkbox Tech_HasOnSiteArticle__c, Catalog__c if same checkbox applicable on child product option
     * @param setIdProd2ConfSKU product2 ids (SBQQ__ConfiguredSKU__c)
     */
    public static void updateHasOnSiteArticle(Set<Id> setIdProd2ConfSKU){
        List<Product2> listProdToUpdate = new List<Product2>();
       //Add conditions Tech_ParentHasOnSiteArticle=False
        for( Product2 prod: [SELECT Id,Tech_ParentHasOnSiteArticle__c,Tech_HasOnSiteArticle__c,Schedulable__c,
                (Select ID,Tech_HasOnSiteArticle__c,Catalog__c,OPCA_Eligible__c,SBQQ__OptionalSKU__c,Schedulable__c,Service_Term__c,Duration__c,Max_Trainee__c,Realization_Conditions__c 
                    FROM SBQQ__Options__r 
                    WHERE  SBQQ__ConfiguredSKU__r.Family = '140' 
                    LIMIT 1
                ) 
            FROM Product2  
            WHERE /*Family != '140' ANDTech_ParentHasOnSiteArticle__c= false AND*/ Id IN :setIdProd2ConfSKU]){
            if(prod.SBQQ__Options__r.size()> 0){
                for(SBQQ__ProductOption__c prodOpt: prod.SBQQ__Options__r){
                    
                    system.debug('------prodOpT'+ prodOpt);
                    system.debug('------prod'+ prod);
                    prod.Tech_HasOnSiteArticle__c = prodOpt.Tech_HasOnSiteArticle__c;
                    system.debug('------prod.Tech_HasOnSiteArticle__c' + prod.Tech_HasOnSiteArticle__c);
                    prod.Realization_Conditions__c = prodOpt.Realization_Conditions__c;
                    prod.Catalog__c = prodOpt.Catalog__c;
                    prod.OPCA_Eligible__c = prodOpt.OPCA_Eligible__c;
                    prod.Schedulable__c = prodOpt.Schedulable__c;
                    prod.Service_Term__c = prodOpt.Service_Term__c;
                    prod.Duration__c = prodOpt.Duration__c;
                    //max trainee
                    prod.Max_Trainee__c  = prodOpt.Max_Trainee__c;
                    
                    system.debug('------prod.maxTraine' + prod.Max_Trainee__c);
                    system.debug('------prodOpT.maxTraine' + prodOpt.Max_Trainee__c);
                    
                    system.debug('------testParent------' + prod.Tech_ParentHasOnSiteArticle__c);
                    prod.Tech_ParentHasOnSiteArticle__c=true;
                    system.debug('------testParentAfter------' + prod.Tech_ParentHasOnSiteArticle__c);
                } 
            }else{
                prod.Tech_HasOnSiteArticle__c = false;
                prod.Catalog__c = false;
                prod.OPCA_Eligible__c = false;
                prod.Schedulable__c = false;
                prod.Duration__c = 0;
                prod.Realization_Conditions__c = null;  // ACO le 07/07/22 pour répondre au Bug 1808
                prod.Service_Term__c = null; // ACO le 07/07/22 pour répondre au Bug 1808
                prod.Max_Trainee__c = null; // ACO le 13/09/22 pour répondre au Bug 1801
            }
            listProdToUpdate.add(prod);
        }

        if(Product2.sObjectType.getDescribe().isUpdateable()){
            update listProdToUpdate;
        }
        

    }
    
    //creation methode 'ResetParentHAsonSiteArticle' qui va query product 
    /*for( Product2 prod: [SELECT Id,Tech_ParentHasOnSiteArticle__c,Tech_HasOnSiteArticle__c,Schedulable__c,
                (Select ID,Tech_HasOnSiteArticle__c,Catalog__c,OPCA_Eligible__c,SBQQ__OptionalSKU__c,Schedulable__c,Service_Term__c,Duration__c,Max_Trainee__c,Realization_Conditions__c 
                    FROM SBQQ__Options__r 
                    WHERE (Tech_HasOnSiteArticle__c = true OR Catalog__c = true OR OPCA_Eligible__c = true OR Schedulable__c = true OR Duration__c != null)
                    LIMIT 1
                ) 
            FROM Product2  
            WHERE Tech_ParentHasOnSiteArticle__c= true AND Id IN :setIdProd2ConfSKU]){ ==> update le champs ParentHAsOnsiteArticle
*/

    /**
     * @author Shamina M - Comforth Karoo
     * @date 2020-11-06
     * @description Update related Product2(Product) when Product2(Article) flags have changed (US W-001416)
     * @param setArticlesIds set product2 ids (Article)
     */
    public static void updatedRelatedProducts(Set<Id> setArticlesIds){
        system.debug('updatedRelatedProducts : ');
        Set<Id> setIdProd2ConfSKU = new Set<Id>();
        //Find related Product2(Product) to the Product2(Article) that were updated
        for(SBQQ__ProductOption__c prodOp : [Select ID,SBQQ__ConfiguredSKU__c
                    FROM SBQQ__ProductOption__c 
                    WHERE SBQQ__OptionalSKU__c IN :setArticlesIds //can be null in delete trigger context
                    AND SBQQ__ConfiguredSKU__r.RecordTypeId = :TH_Product2.PRODUCT_RECTYPEID]){
            setIdProd2ConfSKU.add(prodOp.SBQQ__ConfiguredSKU__c);          
        }
        system.debug('setIdProd2ConfSKU : ' + setIdProd2ConfSKU.size());

        updateHasOnSiteArticle(setIdProd2ConfSKU);
    }
}