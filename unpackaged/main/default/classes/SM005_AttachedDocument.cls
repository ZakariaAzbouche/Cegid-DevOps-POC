/**
* @author Keshav - Comforth
* @date 2020-06-04
* @modified 2020-06-08
* @group TH_AttachedDocument
* @object Attached Document
* @description 
* @modification 7/2/2020 IsActive = true for product By Kmm
*/
public class SM005_AttachedDocument {
    
    public static void insertGeneralTermsAndConditionsLinkToProduct(Map<String,Set<String>> mapDocumentLinks, List<Product2> listproduct){
        
        for(product2 pro:listproduct){
            //Init field
            pro.General_Terms_And_Conditions__c = '';
            Set<String> setDocLinks = new Set<String>();
            
            if(mapDocumentLinks.containsKey('Lvl1_'+pro.Family)){
                setDocLinks.addAll(mapDocumentLinks.get('Lvl1_'+pro.Family));
            }
            if(mapDocumentLinks.containsKey('Lvl1_'+pro.Family+'Lvl2_'+pro.StructureLevel2__c)){
                setDocLinks.addAll(mapDocumentLinks.get('Lvl1_'+pro.Family+'Lvl2_'+pro.StructureLevel2__c));
            }
            if(!setDocLinks.isEmpty()){
                pro.General_Terms_And_Conditions__c = String.join(new List<String>(setDocLinks),';');
            }
            
        }
        update listproduct;
    }
    
    public static void insertServiceBookLinkToProduct(Map<String,Map<String,Set<String>>> mapDocumentLinks, Map<String,String> mapDocumentNameLink, List<Product2> listproduct){
        
        for(product2 pro:listproduct){
            //Init fields to update
            pro.TECHServiceBook__c = '';
            pro.Service_Book__c = '';
            
            Set<String> setDocLinks = new Set<String>();
            if(mapDocumentLinks.get('Lvl1_'+pro.Family+'Pl_'+pro.Product_Line__c).containsKey('EmptyIsAll')){
                setDocLinks.addAll(mapDocumentLinks.get('Lvl1_'+pro.Family+'Pl_'+pro.Product_Line__c).get('EmptyIsAll'));
            }
            if(pro.Service_Levels__c != null){
                for(String serlvl:pro.Service_Levels__c.split(';')){
                    if(mapDocumentLinks.get('Lvl1_'+pro.Family+'Pl_'+pro.Product_Line__c).containsKey(serlvl)){
                        setDocLinks.addAll(mapDocumentLinks.get('Lvl1_'+pro.Family+'Pl_'+pro.Product_Line__c).get(serlvl));
                    }
                }
            }
         	//Fill fields
            pro.TECHServiceBook__c = String.join(new List<String>(setDocLinks),';');
            for(String docLink:setDocLinks){
                system.debug('docLink : ' + docLink);
                pro.Service_Book__c +=  '<a href="'+ docLink +'">' + mapDocumentNameLink.get(docLink) +'</a><BR/>';
            }
        }
        
        update listproduct;
    }
}