/**
* @author Keshav M - Comforth Karoo
* @date 2021-07-01
* @description Trigger handler class for Service_Level_Price__c
*/
public with sharing class TH_ServiceLevelPrice extends TriggerHandler{
    //Bypass
    public static Set<String> setBypassMethods = new Set<String>();
    
    public override void beforeInsert() {
        SM021_UpdateServiceLevelPrice.checkSLPSize((List<Service_Level_Price__c>)Trigger.new);
    }
    
    public override void afterInsert() {
        system.debug('isBypassed before insert: ' + isBypassed('TH_ServiceLevelPriceAfterInsert'));
        if(isBypassed('TH_ServiceLevelPriceAfterInsert')){
            return;
        }
        
        bypass('TH_ServiceLevelPriceAfterInsert');
        
        Set<Id> productIds = new Set<Id>();
        Set<Id> setDefaultIds = new Set<Id>();
        Map<Id,Decimal> mapProductPrice = new Map<Id,Decimal>();
        List<Service_Level_Price__c> listNewslp = new list<Service_Level_Price__c>();
        
        for(Service_Level_Price__c slp:(List<Service_Level_Price__c>)Trigger.new){
            productIds.add(slp.Product__c);
            if(slp.TECH_ProductGolbalPricing__c && slp.Price_Book__c != SM021_UpdateServiceLevelPrice.STANDARDPRICEBOOKID){
                listNewslp.add(slp);
            }
            
            system.debug('slp.Default__c :' + slp.Default__c);
            if(slp.Default__c){
                setDefaultIds.add(slp.Id);
                mapProductPrice.put(slp.Product__c,slp.RegularPrice__c);
            }
        }
        
        if(productIds.size()>0){
            SM021_UpdateServiceLevelPrice.productServiceLevelUpdate(productIds);
        }
        
        if(mapProductPrice.size()>0){
            SM023_UpdatePriceBookEntry.productPriceUpdate(mapProductPrice);
            
        }
        
        if(setDefaultIds.size()>0){
            SM023_UpdatePriceBookEntry.deactivatingDefault(setDefaultIds,productIds);
        }
        
        if(listNewslp.size()>0){
          SM021_UpdateServiceLevelPrice.slpPriceUpdate(listNewslp);  
        }
       
    }
    
    public override void afterUpdate() {
        system.debug('isBypassed  after Update: ' + isBypassed('TH_ServiceLevelPriceAfterUpdate'));
        if(isBypassed('TH_ServiceLevelPriceAfterUpdate')){
            return;
        }
        bypass('TH_ServiceLevelPriceAfterUpdate');
        
        Set<Id> productIds = new Set<Id>();
        Set<Id> setDefaultIds = new Set<Id>();
        Map<Id,Decimal> mapProductPrice = new Map<Id,Decimal>();
        Map<Id,Decimal> mapProductPriceDelete = new Map<Id,Decimal>();
        List<Service_Level_Price__c> listNewslp = new list<Service_Level_Price__c>();
        
        
        for(Service_Level_Price__c slp:(List<Service_Level_Price__c>)Trigger.new){
            Service_Level_Price__c oldSlp = (Service_Level_Price__c)trigger.oldMap.get(slp.Id);
            productIds.add(slp.Product__c);
            
            if(slp.TECH_ProductGolbalPricing__c && slp.Price_Book__c != SM021_UpdateServiceLevelPrice.STANDARDPRICEBOOKID/*&& slp.RegularPrice__c != oldSlp.RegularPrice__c*/){
                listNewslp.add(slp);
            }
            
            if(slp.Default__c){
                setDefaultIds.add(slp.Id);
                mapProductPrice.put(slp.Product__c,slp.RegularPrice__c);
            }else{
                mapProductPriceDelete.put(slp.Product__c,slp.RegularPrice__c);
            }
        }
        
        if(productIds.size()>0){
            SM021_UpdateServiceLevelPrice.productServiceLevelUpdate(productIds);
        }
        
        if(mapProductPrice.size()>0){
            SM023_UpdatePriceBookEntry.productPriceUpdate(mapProductPrice);
        }
        
        if(mapProductPriceDelete.size()>0){
            SM023_UpdatePriceBookEntry.deletePBE(mapProductPriceDelete);
        }
        
        if(setDefaultIds.size()>0){
            SM023_UpdatePriceBookEntry.deactivatingDefault(setDefaultIds,productIds);
        }
        
        if(listNewslp.size()>0){
          SM021_UpdateServiceLevelPrice.slpPriceUpdate(listNewslp);  
        }
        
        
    }
    
    public override void afterDelete() {
        Set<Id> productIds = new Set<Id>();
        Map<Id,Decimal> mapProductPriceDelete = new Map<Id,Decimal>();
        
        for(Service_Level_Price__c slp:(List<Service_Level_Price__c>)Trigger.old){
            productIds.add(slp.Product__c);
            mapProductPriceDelete.put(slp.Product__c,slp.RegularPrice__c);
        }
        
        if(productIds.size()>0){
            SM021_UpdateServiceLevelPrice.productServiceLevelUpdate(productIds);
        }
        
        if(mapProductPriceDelete.size()>0){
            SM023_UpdatePriceBookEntry.deletePBE(mapProductPriceDelete);
        }
    }
}