/**
 * @description       : 
 * @author            : keshav Matabadul
 * @group             : 
 * @last modified on  : 11-28-2021
 * @last modified by  : keshav Matabadul
**/
public class SM023_UpdatePriceBookEntry {
    
    public static void productPriceUpdate(Map<Id,Decimal> mapProductPrice){
        set<String> setValues = new set<String>{'Store/CPQ','Store Only'};
        List<PricebookEntry> listPBEUpsert = new list<PricebookEntry>();
        //PriceBook Id
        String pricebookB2B;

        if(Test.isRunningTest()){
            pricebookB2B = [select Id, Name, IsActive from PriceBook2 where IsStandard=True LIMIT 1].Id;
        }else{
            pricebookB2B = System.Label.B2BStorePricebookId;
        }
        
        System.debug('mapProductPrice.keySet() ' + mapProductPrice.keySet());
        System.debug('setValues  ' + setValues);
        //Les affirmations suivantes sont vraies seulement pour les produits dont le "Sales Canal" est Store Only ou Store/CPQ.
        List<product2> listProduct = [SELECT Id,Sales_Channel__c FROM Product2 WHERE Id IN:mapProductPrice.keySet() AND Sales_Channel__c IN:setValues];
        List<PricebookEntry> listPBE= [Select Product2Id,Product2.Name,CreatedDate,Pricebook2Id from PricebookEntry 
                                       WHERE Pricebook2Id =:pricebookB2B AND Product2Id IN:listProduct AND IsActive = true];
        
        for(product2 p:listProduct){
            PricebookEntry objPBE = new PricebookEntry(
                Product2Id = p.Id,
                Pricebook2Id = pricebookB2B,
                IsActive = true,
                //Si je coche un SLP à Default, je dois avoir un PricebookEntries automatiquement, reprenant le prix de ce SLP.
                UnitPrice = mapProductPrice.get(p.Id)
            );
            for(PricebookEntry pbe:listPBE){
                if(p.Id == pbe.Product2Id){
                    objPBE.Id = pbe.Id;
                }
            }
            
            listPBEUpsert.add(objPBE);
        }
        
        if(listPBEUpsert.size()>0){
            upsert listPBEUpsert;
        }

    }
    
    
    //Un produit ne peut avoir qu'un seul SLP Default : Quand je coche un SLP à Default, je décoche les autres s'il y en a. 
    public static void deactivatingDefault(Set<Id> setSLPIdsActivate, Set<Id> setProductIds){ 
        
        List<Service_Level_Price__c> listSLP = [SELECT Id,Product__c,RegularPrice__c,Default__c FROM Service_Level_Price__c 
                                                WHERE Id NOT IN:setSLPIdsActivate AND Product__c IN:setProductIds AND Default__c = true];
        
        if(listSLP.size()>0){
            for(Service_Level_Price__c slp:listSLP){
                slp.Default__c = false;
            }  
        }
        
        update listSLP;
    }
    
    public static void deletePBE(Map<Id,Decimal> mapProductPrice){
        set<String> setValues = new set<String>{'Store/CPQ','Store Only'};
        List<PricebookEntry> listPBEUpsert = new list<PricebookEntry>();
        //PriceBook Id
        String pricebookB2B;
        if(Test.isRunningTest()){
            pricebookB2B = [select Id, Name, IsActive from PriceBook2 where IsStandard=True LIMIT 1].Id;
        }else{
            pricebookB2B = System.Label.B2BStorePricebookId;
        }
        //Les affirmations suivantes sont vraies seulement pour les produits dont le "Sales Canal" est Store Only ou Store/CPQ.
        List<product2> listProduct = [SELECT Id,Sales_Channel__c FROM Product2 WHERE Id IN:mapProductPrice.keySet() AND Sales_Channel__c IN:setValues];
        List<PricebookEntry> listPBE= [Select Product2Id,Product2.Name,CreatedDate,Pricebook2Id from PricebookEntry 
                                       WHERE Pricebook2Id =:pricebookB2B AND Product2Id IN:listProduct AND IsActive = true];
        
        if(listPBE.size()>0){
            delete listPBE;
        }
    }
    

}