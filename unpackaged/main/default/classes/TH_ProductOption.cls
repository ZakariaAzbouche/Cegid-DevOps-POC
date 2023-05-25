/**
* @author Keshav - Comforth
* @date 2020-06-04
* @modified 2020-06-04
* @group TH_ProductOption
* @object Product Option
* @description 
*/

public without sharing class TH_ProductOption extends TriggerHandler {
    
    BypassTrigger__c getAuth = BypassTrigger__c.getOrgDefaults();

    public override void beforeInsert() {
        if(getAuth.Activatetrigger__c){
            SM002_ProductOption.checkDoubleRecords(Trigger.new, false); 
        }
    }
    
    public override void afterInsert() {
        if(getAuth.Activatetrigger__c){
            SM002_ProductOption.updatePurchasingPrice(Trigger.new, false);
        }
        
        //handle auto update of Tech_HasOnSiteArticle__c on configured SKU product2
        Set<Id> setIdProd2ConfSKU = new Set<Id>();
        for(SBQQ__ProductOption__c prodOpt:(List<SBQQ__ProductOption__c>)Trigger.new){
            if(canTriggerByFeature('FlagHasOnSiteArticle__c') && 
                prodOpt.SBQQ__ConfiguredSKU__c != null){
                setIdProd2ConfSKU.add(prodOpt.SBQQ__ConfiguredSKU__c);               
            }            
        }
        
        if(setIdProd2ConfSKU.size()>0){
            SM007_FlagProductHasOnSiteArticle.updateHasOnSiteArticle(setIdProd2ConfSKU);
        }
    }
    
    public override void afterUpdate() {
        if(getAuth.Activatetrigger__c){
            SM002_ProductOption.updatePurchasingPrice(Trigger.new, false);
        }
        //check changement des champs(duration/servicetrem, realization) si changement appeler methode 'resetParentHasonsitearticle'
        
        //handle auto update of Tech_HasOnSiteArticle__c on configured SKU product2
        Set<Id> setIdProd2ConfSKU = new Set<Id>();
        for(SBQQ__ProductOption__c prodOpt:(List<SBQQ__ProductOption__c>)Trigger.new){
            SBQQ__ProductOption__c oldProdOpt = (SBQQ__ProductOption__c)trigger.oldMap.get(prodOpt.Id);
            if(canTriggerByFeature('FlagHasOnSiteArticle__c') && 
                (oldProdOpt.SBQQ__OptionalSKU__c != prodOpt.SBQQ__OptionalSKU__c ||
                oldProdOpt.SBQQ__ConfiguredSKU__c != prodOpt.SBQQ__ConfiguredSKU__c)){
                setIdProd2ConfSKU.add(prodOpt.SBQQ__ConfiguredSKU__c);
                setIdProd2ConfSKU.add(oldProdOpt.SBQQ__ConfiguredSKU__c);                              
            }            
        }
        
        if(setIdProd2ConfSKU.size()>0){
            SM007_FlagProductHasOnSiteArticle.updateHasOnSiteArticle(setIdProd2ConfSKU);
        }
    }
    
    public override void beforeDelete() {
        if(getAuth.Activatetrigger__c){
            SM002_ProductOption.updatePurchasingPrice(Trigger.old, true);
        }
    }

    /**
     * @author Shamina M - Comforth Karoo
     * @date 2020-09-15
     * @description afterDelete logic          
    */
    public override void afterDelete() {
        //handle auto update of Tech_HasOnSiteArticle__c on configured SKU product2
        Set<Id> setIdProd2ConfSKU = new Set<Id>();
        for(SBQQ__ProductOption__c prodOpt:(List<SBQQ__ProductOption__c>)Trigger.old){
            if(canTriggerByFeature('FlagHasOnSiteArticle__c') && 
                prodOpt.SBQQ__ConfiguredSKU__c != null){
                setIdProd2ConfSKU.add(prodOpt.SBQQ__ConfiguredSKU__c);               
            }            
        }
        
        if(setIdProd2ConfSKU.size()>0){
            SM007_FlagProductHasOnSiteArticle.updateHasOnSiteArticle(setIdProd2ConfSKU);
        }       
    }
}