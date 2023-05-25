/**
* @author Easyfront
* @date 23/01/2023
* @description : Use to insert the Attached Document link on related product
*/
global without sharing class APB002_InsertServiceBookLinkToProduct implements Database.Batchable<sObject> {
    global List<Attached_Document__c> listAttachedDoc;
    global Map<String,Map<String,Set<String>>> mapDocumentLinks;
    global Map<String,String> mapDocumentNameLink;
    global Set<String> setStruc1;
    global Set<String> setProductLine;
    global Set<String> setServiceLevel;
    
    global APB002_InsertServiceBookLinkToProduct(List<Attached_Document__c> listAttachedDoc){
        Set<String> setStruc1 = new Set<String>();
        Set<String> setProductLine = new Set<String>();
        Map<String,Map<String,Set<String>>> mapDocumentLinks = new Map<String,Map<String,Set<String>>>();
        Map<String,String> mapDocumentNameLink = new Map<String,String>();
        
        //Get Struture Level 1 & Product Lines to retreive all related attached documents & products
        for(Attached_Document__c attDoc:listAttachedDoc){
            setStruc1.add(attDoc.StructureLevel1__c);
            setProductLine.add(attDoc.Product_Line__c);
            mapDocumentLinks.put('Lvl1_'+attDoc.StructureLevel1__c+'Pl_'+attDoc.Product_Line__c, new Map<String,Set<String>>()); //Init map (included deleted documents)
        }
        //Get all Attached Documents for these Structure Level 1 and Product Lines
        List<Attached_Document__c> listAttachedDocuments = [SELECT Id, StructureLevel1__c, Product_Line__c, Service_Level__c, Name, Document_Link__c FROM Attached_Document__c 
                                                            WHERE StructureLevel1__c IN: setStruc1 AND Product_Line__c IN: setProductLine  AND RecordTypeId =: TH_AttachedDocument.rtServiceBook];
        if(!listAttachedDocuments.isEmpty()){
            for(Attached_Document__c attDoc:listAttachedDocuments){
                mapDocumentNameLink.put(attDoc.Document_Link__c, attDoc.Name);
                if(attDoc.Service_Level__c != null){
                    for(String serlvl:attDoc.Service_Level__c.split(';')){
                        if(mapDocumentLinks.get('Lvl1_'+attDoc.StructureLevel1__c+'Pl_'+attDoc.Product_Line__c).containsKey(serlvl)){
                            mapDocumentLinks.get('Lvl1_'+attDoc.StructureLevel1__c+'Pl_'+attDoc.Product_Line__c).get(serlvl).add(attDoc.Document_Link__c);
                        }else{
                            mapDocumentLinks.get('Lvl1_'+attDoc.StructureLevel1__c+'Pl_'+attDoc.Product_Line__c).put(serlvl, new Set<String>{attDoc.Document_Link__c});
                        }
                    }
                }else{
                    if(mapDocumentLinks.get('Lvl1_'+attDoc.StructureLevel1__c+'Pl_'+attDoc.Product_Line__c).containsKey('EmptyIsAll')){
                        mapDocumentLinks.get('Lvl1_'+attDoc.StructureLevel1__c+'Pl_'+attDoc.Product_Line__c).get('EmptyIsAll').add(attDoc.Document_Link__c);
                    }else{
                        mapDocumentLinks.get('Lvl1_'+attDoc.StructureLevel1__c+'Pl_'+attDoc.Product_Line__c).put('EmptyIsAll', new Set<String>{attDoc.Document_Link__c});
                    }
                }
            }
        }
        
        //Assign variables
        this.mapDocumentLinks = mapDocumentLinks;
        this.setStruc1 = setStruc1;
        this.setProductLine = setProductLine;
        this.mapDocumentNameLink = mapDocumentNameLink;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator([SELECT id , name, Family, Service_Levels__c,TECHServiceBook__c, Service_Book__c,Product_Line__c 
                                         from product2 
                                         WHERE Family IN :setStruc1 
                                         AND IsActive = true
                                         AND Product_Line__c IN :setProductLine 
                                         AND RecordTypeId =: TH_AttachedDocument.rtProduct]);  
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        system.debug('scope batch >>>> '+scope);
        if(!scope.isEmpty()){
           SM005_AttachedDocument.insertServiceBookLinkToProduct(mapDocumentLinks, mapDocumentNameLink, scope);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
    
}