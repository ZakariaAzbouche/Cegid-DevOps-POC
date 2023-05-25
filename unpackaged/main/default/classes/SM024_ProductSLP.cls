public class SM024_ProductSLP {
    
    public static void productPriceUpdate(Map<Id,String> mapProduct){
        //PriceBook Id
        String pricebookB2B = System.Label.B2BStorePricebookId;
        List<PricebookEntry> listPBEUpsert = new list<PricebookEntry>();
        Boolean deletePBE = false;
        
        List<PricebookEntry> listPBE= [Select Product2Id,Product2.Name,CreatedDate,Pricebook2Id from PricebookEntry 
                                       WHERE Pricebook2Id =:pricebookB2B AND Product2Id IN:mapProduct.keySet() AND IsActive = true limit 1];
        
        List<Service_Level_Price__c> listSLP = [SELECT Id,Product__c,RegularPrice__c,Default__c FROM Service_Level_Price__c 
                                                WHERE Product__c IN:mapProduct.keySet() AND Default__c = true];
        
        for(Id p:mapProduct.keySet()){
            if(mapProduct.get(p) == 'Store/CPQ' || mapProduct.get(p) == 'Store Only'){
                for(Service_Level_Price__c slp:listSLP){
                    PricebookEntry objPBE = new PricebookEntry(
                        Product2Id = p,
                        Pricebook2Id = pricebookB2B,
                        IsActive = true,
                        //Si je coche un SLP à Default, je dois avoir un PricebookEntries automatiquement, reprenant le prix de ce SLP.
                        UnitPrice = slp.RegularPrice__c
                    ); 
                    listPBEUpsert.add(objPBE);
                }
               
            }else{
                deletePBE = true;
            }
        }
        
        if(listPBEUpsert.size()>0 && !deletePBE){
            upsert listPBEUpsert;
        }else if(deletePBE && listPBE.size()>0){
          delete listPBE;  
        } 
    }
    
}