/**
* @author Keshav M - Comforth Karoo
* @date 2021-07-01
*/
public class SM021_UpdateServiceLevelPrice {
    
    public static final String STANDARDPRICEBOOKID = getStdPriceBook();//System.Label.Standard_Pricebook_ID;
    
    public static Id getStdPriceBook() {
        return [select Id, Name, IsActive from PriceBook2 where IsStandard=True LIMIT 1].Id;   
    }
    
    public static void checkSLPSize(List<Service_Level_Price__c> listSLP){
        
        set<Id> productIds = new set<Id>();
        
        for(Service_Level_Price__c slp:listSLP){
            productIds.add(slp.Product__c);
        }
        
        List<Service_Level_Price__c> listSLPExt = [SELECT Id, Product__c,Service_Level__c FROM Service_Level_Price__c WHERE Product__c IN:productIds];
        
        if(listSLPExt.size() == 0){
            for(Service_Level_Price__c slp:listSLP){
                slp.Default__c = true;
            }
        }
    }
    
    public static void productServiceLevelUpdate(Set<Id> productIds){ 
        //Contains all serviceLevelPrice Value
        Set<String> setServiceLevelPrice = new Set<String>();
        
        //Get All Service Level Price which has the same product 
        List<Service_Level_Price__c> listSLP = [SELECT Id, Product__c,Service_Level__c FROM Service_Level_Price__c WHERE Product__c IN:productIds];
        List<Product2> listProdToUpdate = [SELECT Id,Service_Levels__c FROM Product2 where Id IN:productIds];
        for(Service_Level_Price__c slp:listSLP){
            String serviceLevel = slp.Service_Level__c;
            setServiceLevelPrice.addAll(serviceLevel.split(';'));
        }
        
        for(Product2 pro:listProdToUpdate){
            pro.Service_Levels__c = null;
            pro.Service_Levels__c = String.join(new List<String>(setServiceLevelPrice),';');
        }
        
        update listProdToUpdate;
        
    }
    /**
     * @author Keshav M - Comforth Karoo
     * @date 2021-8-9
     * @description Update SlpPricing           
    */
    Public static void slpPriceUpdate(List<Service_Level_Price__c> listSLP){
        system.debug('slpPriceUpdate'); 
        
        set<Id> setPricebook2Id = new set<Id>();
        set<Id> setProduct2Id = new set<Id>();
        set<Id> setPBIds = new set<Id>();
        set<String> setServiceLevelPrice = new set<String>();
        set<decimal> setLowerBound = new set<decimal>();
        set<decimal> setUpperBound= new set<decimal>();
        set<String> setSalesPurpose = new set<String>();
        
        //Update List
        list<Service_Level_Price__c> listSLPToUpdate = new list<Service_Level_Price__c>();
        list<Service_Level_Price__c> listSLPToCreate = new list<Service_Level_Price__c>();
        
        list<Service_Level_Price__c> listSLPToUpsert = new list<Service_Level_Price__c>();
        
        
        for(Service_Level_Price__c slp:listSLP){
            setPricebook2Id.add(slp.Price_Book__c);
            setProduct2Id.add(slp.Product__c);
            setServiceLevelPrice.add(slp.Service_Level__c);
            setLowerBound.add(slp.Lower_Bound__c);
            setUpperBound.add(slp.Upper_Bound__c);
            setSalesPurpose.add(slp.Sales_Purpose__c);
        }
        
        //Get other non-standard pricebooks
        for(PricebookEntry PE:[SELECT Id,Pricebook2Id,Name, pricebook2.Name FROM PricebookEntry 
                               WHERE Product2Id IN:setProduct2Id AND Pricebook2Id NOT IN:setPricebook2Id AND Pricebook2Id !=:STANDARDPRICEBOOKID]){
                                   setPBIds.add(PE.Pricebook2Id);
                                   system.debug('PE : ' + PE.pricebook2.Name);
                               }
        
        //Get SLP record Which different PriceBooks
        List<Service_Level_Price__c> listSLPLoop = [SELECT Id,Price_Book__c,Product__c,Service_Level__c,Lower_Bound__c,Upper_Bound__c,Sales_Purpose__c 
                                                    FROM Service_Level_Price__c WHERE Price_Book__c IN:setPBIds AND Product__c IN:setProduct2Id 
                                                    AND Service_Level__c IN:setServiceLevelPrice AND Lower_Bound__c IN:setLowerBound AND Upper_Bound__c IN:setUpperBound 
                                                    AND Sales_Purpose__c IN:setSalesPurpose]; 
        system.debug('listSLPLoop ' + listSLPLoop.size());
        system.debug('setPBIds ' + setPBIds.size());
        //Creation of Record && Update 
        for(Service_Level_Price__c slp:listSLP){
            //if(slp.Price_Book__c != STANDARDPRICEBOOKID){
            if(listSLPLoop.size()>0){
                //Handle Update
                for(Service_Level_Price__c slpUpdate:listSLPLoop){
                    slpUpdate.RegularPrice__c = slp.RegularPrice__c;
                    listSLPToUpdate.add(slpUpdate);
                    //listSLPToUpsert.add(slpUpdate);
                }
            }else{
                //Handle Creation
                for(Id pb2Id:setPBIds){
                    system.debug('pb2Id :' + pb2Id);
                    Service_Level_Price__c objslp = new Service_Level_Price__c(
                        Lower_Bound__c = slp.Lower_Bound__c,
                        Discount_Schedule__c = slp.Discount_Schedule__c,
                        //Conversion_rate__c = slp.Conversion_rate__c,
                        //Max_UpperBound__c = slp.Max_UpperBound__c,
                        Maximum_Price__c = slp.Maximum_Price__c,
                        Percent__c = slp.Percent__c,
                        Percent_of_Target_Product__c = slp.Percent_of_Target_Product__c,
                        Percent_of_Total_Field__c = slp.Percent_of_Total_Field__c,
                        Price_Book__c = pb2Id,
                        //Price_by_SLP__c = slp.Price_by_SLP__c,
                        Product__c = slp.Product__c,
                        //Reference_Number__c = slp.Reference_Number__c,
                        RegularPrice__c = slp.RegularPrice__c,
                        Sales_Purpose__c = slp.Sales_Purpose__c,
                        Upper_Bound__c = slp.Upper_Bound__c
                    );
                     listSLPToCreate.add(objslp);
                }                
            }
        //}
        }
        system.debug('listSLPToUpsert :' + listSLPToUpsert.size());
        for(Service_Level_Price__c sl:listSLPToUpsert){
            system.debug('sl : '+ sl.Id);
        }
        if(listSLPToCreate.size()>0){
            TriggerHandler.bypass('TH_ServiceLevelPriceAfterInsert');
            insert listSLPToCreate;
        }
        
        if(listSLPToUpdate.size()>0){
            TriggerHandler.bypass('TH_ServiceLevelPriceAfterUpdate');
            update listSLPToUpdate;
        }
        
               
    }
}