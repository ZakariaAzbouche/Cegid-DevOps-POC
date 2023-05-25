/**
 * @author Keshav - Comforth Dev Team
 * @date 2020-02
 * @group Cegid
 * @description  class for LC002_ProductReport 
 * 
 * Si on part d’un Article : On affiche des Packages (Name de SBQQ__ConfiguredSKU__c), et reference_Number (à la place de Id) et Metric, Operating Typology, Functional, Functional Level, Brand, Offer, Product Line, StructureLevel1, StructureLevel2.
 * Si on part d’un Package : On affiche des Articles (Name de SBQQ_OptionalSKU__c), et Reference_Number et No Royalties, Brand, Buying Metric, Supplier Id, Purchasing Price. 
 */


public class LC002_ProductReport {
    @AuraEnabled 
    public static List<sObject> getProducts(String productId, String recType){
        
        if(recType == 'Article'){
            List<Product2> lisPro = [SELECT Name,Id,
                                     (SELECT SBQQ__ConfiguredSKU__c, Id,Name,SBQQ__OptionalSKU__r.Id,SBQQ__ConfiguredSKU__r.Id,SBQQ__ConfiguredSKU__r.Reference_Number__c,SBQQ__ConfiguredSKU__r.Name, tolabel(SBQQ__OptionalSKU__r.Metric__c), tolabel(SBQQ__ConfiguredSKU__r.Operating_Typology__c),tolabel(SBQQ__ConfiguredSKU__r.Core_Business__c),
                                      tolabel(SBQQ__ConfiguredSKU__r.Functional_Level__c), tolabel(SBQQ__ConfiguredSKU__r.Brand__c), tolabel(SBQQ__ConfiguredSKU__r.Offer__c),tolabel(SBQQ__ConfiguredSKU__r.Family),
                                      tolabel(SBQQ__ConfiguredSKU__r.StructureLevel2__c),SBQQ__OptionalSKU__r.Buying_Metric__c,SBQQ__OptionalSKU__r.Purchasing_Price__c,SBQQ__OptionalSKU__r.NoRoyalty__c
                                      FROM SBQQ__OptionalFor__r) 
                                     FROM Product2
                                     WHERE Id in (SELECT SBQQ__ConfiguredSKU__c from SBQQ__ProductOption__c WHERE SBQQ__OptionalSKU__c =: productId AND SBQQ__OptionalSKU__r.RecordType.DeveloperName =: recType) 
                                    ];
            
            List<sObject> listObj = new List<sObject>();
            for(Product2 p:lisPro){
                if(!p.SBQQ__OptionalFor__r.isEmpty()) {
                    listObj.addAll(p.SBQQ__OptionalFor__r);
                } 
            }
            return listObj;
            
        }else if(recType == 'Package'){
            List<Product2> lisPro =  [ SELECT Name,Id,
                                      (SELECT SBQQ__OptionalSKU__c, Id,Name,SBQQ__ConfiguredSKU__r.Id,SBQQ__OptionalSKU__r.Id,SBQQ__OptionalSKU__r.Reference_Number__c,SBQQ__OptionalSKU__r.Name, tolabel(SBQQ__ConfiguredSKU__r.Metric__c), SBQQ__ConfiguredSKU__r.Operating_Typology__c,SBQQ__ConfiguredSKU__r.Core_Business__c,
                                       SBQQ__ConfiguredSKU__r.Functional_Level__c, tolabel(SBQQ__OptionalSKU__r.Brand__c), SBQQ__ConfiguredSKU__r.Offer__c,SBQQ__ConfiguredSKU__r.Family,
                                       SBQQ__ConfiguredSKU__r.StructureLevel2__c,tolabel(SBQQ__OptionalSKU__r.Buying_Metric__c),SBQQ__OptionalSKU__r.Purchasing_Price__c,SBQQ__OptionalSKU__r.NoRoyalty__c 
                                       FROM SBQQ__Options__r) 
                                      FROM Product2
                                      WHERE Id in (SELECT SBQQ__OptionalSKU__c from SBQQ__ProductOption__c WHERE SBQQ__ConfiguredSKU__c =: productId AND SBQQ__ConfiguredSKU__r.RecordType.DeveloperName =: recType)
                                     ];
            
            List<sObject> listObj = new List<sObject>();
            for(Product2 p:lisPro){
                if(!p.SBQQ__Options__r.isEmpty()) {
                    listObj.addAll(p.SBQQ__Options__r);
                } 
            }
            return listObj;
        }
        return null;
        
    }
    
    @AuraEnabled
    public static Map<String, Object> getObjMetadata() { 
        return CEGID_UTIL.getMetadata();
    }
}