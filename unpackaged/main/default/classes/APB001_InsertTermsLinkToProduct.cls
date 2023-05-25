/**
* @author Easyfront
* @date 23/01/2023
* @description : Use to insert the Attached Document link on related product
*/
global without sharing class APB001_InsertTermsLinkToProduct implements Database.Batchable<sObject> {
    global List<Attached_Document__c> listAttachedDoc;
    global Map<String,Set<String>> mapDocumentLinks;
    global Set<String> setStruc1;
    global Set<String> setStruc2;
    
    global APB001_InsertTermsLinkToProduct(List<Attached_Document__c> listAttachedDoc){
        Set<String> setStruc1 = new Set<String>();
        Set<String> setStruc2 = new Set<String>();
        Map<String,Set<String>> mapDocumentLinks = new Map<String,Set<String>>();
        
        //Get Struture Level 1 & 2 to retreive all related attached documents & products
        for(Attached_Document__c attDoc:listAttachedDoc){
            setStruc1.add(attDoc.StructureLevel1__c);
            if(attDoc.StructureLevel2__c != null){
                setStruc2.add(attDoc.StructureLevel2__c);
            }
            mapDocumentLinks.put('Lvl1_'+attDoc.StructureLevel1__c+'Lvl2_'+attDoc.StructureLevel2__c, new Set<String>()); //Init map (included deleted documents)
        }
        List<Attached_Document__c> listAttachedDocuments = [SELECT Id, StructureLevel1__c, StructureLevel2__c, Document_Link__c FROM Attached_Document__c 
                                                            WHERE StructureLevel1__c IN: setStruc1 AND RecordTypeId =: TH_AttachedDocument.rtGeneralTerms];
        if(!listAttachedDocuments.isEmpty()){
            for(Attached_Document__c attDoc:listAttachedDocuments){
                 if(attDoc.StructureLevel2__c != null){
                        if(mapDocumentLinks.containsKey('Lvl1_'+attDoc.StructureLevel1__c+'Lvl2_'+attDoc.StructureLevel2__c)){
                            mapDocumentLinks.get('Lvl1_'+attDoc.StructureLevel1__c+'Lvl2_'+attDoc.StructureLevel2__c).add(attDoc.Document_Link__c);
                        }else{
                            mapDocumentLinks.put('Lvl1_'+attDoc.StructureLevel1__c+'Lvl2_'+attDoc.StructureLevel2__c, new Set<String>{attDoc.Document_Link__c});
                        }
                 }else{
                     if(mapDocumentLinks.containsKey('Lvl1_'+attDoc.StructureLevel1__c)){
                         mapDocumentLinks.get('Lvl1_'+attDoc.StructureLevel1__c).add(attDoc.Document_Link__c);
                     }else{
                         mapDocumentLinks.put('Lvl1_'+attDoc.StructureLevel1__c, new Set<String>{attDoc.Document_Link__c});
                     }
                 }
            }
        }
        
        //Assign variables
        this.mapDocumentLinks = mapDocumentLinks;
        this.setStruc1 = setStruc1;
        this.setStruc2 = setStruc2;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Get products for these Structure Level 1 & 2
        if(!setStruc2.isEmpty()){
            return Database.getQueryLocator([SELECT id , name, Family, StructureLevel2__c, General_Terms_And_Conditions__c from product2 
                                             WHERE Family IN:setStruc1 
                                             AND IsActive = true
                                             AND StructureLevel2__c IN:setStruc2
                                             AND RecordTypeId =: TH_AttachedDocument.rtProduct]);  
        }else{
            return Database.getQueryLocator([SELECT id , name, Family, StructureLevel2__c, General_Terms_And_Conditions__c from product2 
                                             WHERE Family IN:setStruc1 
                                             AND IsActive = true
                                             AND RecordTypeId =: TH_AttachedDocument.rtProduct]);  
        }
        
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        system.debug('scope batch >>>> '+scope);
        if(!scope.isEmpty()){
           SM005_AttachedDocument.insertGeneralTermsAndConditionsLinkToProduct(mapDocumentLinks, scope);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
    
}