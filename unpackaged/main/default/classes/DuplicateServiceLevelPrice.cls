/**
* @description       : 
* @author            : Keshav Matabadul
* @group             : 
* @last modified on  : 05-09-2022
* @last modified by  : Keshav Matabadul
**/
public with sharing class DuplicateServiceLevelPrice {
    
    public static final String STANDARDPRICEBOOKID = getStdPriceBook();
    
    //Can Input Multiple Variable at once in a flow 
    public class flowInputs {
        @InvocableVariable
        public Service_Level_Price__c objServiceLevelPrice;
        
        @InvocableVariable
        public String productRT;
    }
    
    public static Id getStdPriceBook() {
        return [select Id, Name, IsActive from PriceBook2 where IsStandard=True LIMIT 1].Id;   
    }
    
    @InvocableMethod(label='Insert SLP' description='Insert SLP for all Pricebook which is not standard')
    public static void CreateServiceLevelPrice(List<flowInputs> inputVariables) {
        
        set<String> setSalesPurpose = new set<String>();
        Set<Id> setProductIds = new set<Id>();
        map<Id,string> mapPB = new map<Id,string>();
        Set<Decimal> setLowerBound = new Set<Decimal>();
        Set<Decimal> setUpperBound = new Set<Decimal>();
        Set<String> setServiceLevel = new Set<String>();
        List<Service_Level_Price__c> listInsertSLP = new List<Service_Level_Price__c>();
        String productRecordType;
        String rtDevelopername;
        String pricebookId;
        Set<Id> setPriceBook = new Set<Id>();
        
        
        for(DuplicateServiceLevelPrice.flowInputs valuesFromFlow:inputVariables){
            
            productRecordType = valuesFromFlow.productRT;
            pricebookId = valuesFromFlow.objServiceLevelPrice.Price_Book__c;
            setProductIds.add(valuesFromFlow.objServiceLevelPrice.Product__c);
            setLowerBound.add(valuesFromFlow.objServiceLevelPrice.Lower_Bound__c);
            setUpperBound.add(valuesFromFlow.objServiceLevelPrice.Upper_Bound__c);
            setServiceLevel.add(valuesFromFlow.objServiceLevelPrice.Service_Level__c);
            
            if(valuesFromFlow.objServiceLevelPrice.Sales_Purposes__c.contains(';')){
                list<String> listSalesPurpose = valuesFromFlow.objServiceLevelPrice.Sales_Purposes__c.split(';');
                for (String str:listSalesPurpose){
                    setSalesPurpose.add(str);
                }
                
            }else{
                setSalesPurpose.add(valuesFromFlow.objServiceLevelPrice.Sales_Purposes__c);
            }
            
        }
        
        if(pricebookId == STANDARDPRICEBOOKID){
            for(PricebookEntry PE:[SELECT Id,Pricebook2Id,Name,Pricebook2.Currency__c, pricebook2.Name FROM PricebookEntry 
                                   WHERE Product2Id IN:setProductIds AND Pricebook2Id =:STANDARDPRICEBOOKID AND IsActive = true]){
                                       mapPB.put(PE.Pricebook2Id,PE.Pricebook2.Currency__c);
                                   }
        }else{//Get other non-standard pricebooks 01s1t0000048XiVAAU
            for(PricebookEntry PE:[SELECT Id,Pricebook2Id,Name,Pricebook2.Currency__c, pricebook2.Name FROM PricebookEntry 
                                   WHERE Product2Id IN:setProductIds AND Pricebook2Id !=:STANDARDPRICEBOOKID AND IsActive = true]){
                                       mapPB.put(PE.Pricebook2Id,PE.Pricebook2.Currency__c);
                                   }
        }
        
        //Query all Currency 
        Map<String,CurrencyType> mapAllCurrency = new Map<String,CurrencyType>();
        if(mapPB.size()>0){
            for(CurrencyType ct:[SELECT Id,ConversionRate,IsoCode,IsActive FROM CurrencyType WHERE IsActive = true AND IsoCode IN:mapPB.values()]){
                mapAllCurrency.put(ct.IsoCode, ct);
            }
        }
        
        
        //Set RecordType
        if(productRecordType =='Block'){
            rtDevelopername = 'Block_Pricing';
        }else{
            rtDevelopername = 'List_Pricing';
        }
        
        for(String str:setSalesPurpose){
            for(String pb:mapPB.keySet()){
                for(DuplicateServiceLevelPrice.flowInputs valuesFromFlow:inputVariables){
                    Service_Level_Price__c slp = new Service_Level_Price__c();
                    if(productRecordType =='Block'){
                        slp.Upper_Bound__c = valuesFromFlow.objServiceLevelPrice.Upper_Bound__c;
                        slp.Lower_Bound__c = valuesFromFlow.objServiceLevelPrice.Lower_Bound__c;
                    }else{
                        slp.Discount_Schedule__c = (valuesFromFlow.objServiceLevelPrice.Discount_Schedule__c != null?valuesFromFlow.objServiceLevelPrice.Discount_Schedule__c:null);
                    }
                   
                    slp.Service_Level__c = valuesFromFlow.objServiceLevelPrice.Service_Level__c;
                    slp.Price_Book__c =  pb;
                    slp.Product__c = valuesFromFlow.objServiceLevelPrice.Product__c;
                    slp.Sales_Purpose__c = str;
                    slp.recordTypeId = Schema.SObjectType.Service_Level_Price__c.getRecordTypeInfosByDeveloperName().get(rtDevelopername).getRecordTypeId();
                    slp.Sales_Purposes__c = null;
                    slp.RegularPrice__c = (valuesFromFlow.objServiceLevelPrice.RegularPrice__c != null?valuesFromFlow.objServiceLevelPrice.RegularPrice__c:0) * mapAllCurrency.get(mapPB.get(pb)).ConversionRate;                    
                    slp.Maximum_Price__c = valuesFromFlow.objServiceLevelPrice.Maximum_Price__c;
                    slp.CurrencyIsoCode = mapPB.get(pb);
                    listInsertSLP.add(slp);
                }
            }
        }
        
        if(listInsertSLP.size()>0){
            insert listInsertSLP;
        }
    }
    
    
    
}