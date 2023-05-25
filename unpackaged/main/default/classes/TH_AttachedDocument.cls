/**
* @author Keshav - Comforth
* @date 2020-06-04
* @modified 2020-06-08
* @group TH_AttachedDocument
* @object Attached Document
* @description 
*/

public without sharing class TH_AttachedDocument extends TriggerHandler{
	
    // Retrieve the RecordType Ids
    public static final Id rtGeneralTerms = Schema.SObjectType.Attached_Document__c.getRecordTypeInfosByDeveloperName().get('General_Terms_And_Conditions').getRecordTypeId();    
    public static final Id rtServiceBook = Schema.SObjectType.Attached_Document__c.getRecordTypeInfosByDeveloperName().get('Service_Book').getRecordTypeId();
    public static final Id rtProduct = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();
    
    public TH_AttachedDocument(){
        
    }

    public override void afterInsert() {
		List<Attached_Document__c> listAttachedDocGeneralTerms = new List<Attached_Document__c>();
        List<Attached_Document__c> listAttachedDocServiceBooks = new List<Attached_Document__c>();
        
        For(Attached_Document__c attDoc:(List<Attached_Document__c>)Trigger.new){
            if(attDoc.RecordTypeId == rtGeneralTerms){
                listAttachedDocGeneralTerms.add(attDoc);
            }else if(attDoc.RecordTypeId == rtServiceBook){
                listAttachedDocServiceBooks.add(attDoc);
            }
        }
        
        //Add Document link on all related products into Terms and Conditions field
        if(!listAttachedDocGeneralTerms.isEmpty()){
            APB001_InsertTermsLinkToProduct apb001 = new APB001_InsertTermsLinkToProduct(listAttachedDocGeneralTerms);
            Database.executeBatch(apb001, 200);
        }
        
        //Add Document link on all related products into Service Book field
        if(!listAttachedDocServiceBooks.isEmpty()){
            APB002_InsertServiceBookLinkToProduct apb002 = new APB002_InsertServiceBookLinkToProduct(listAttachedDocServiceBooks);
            Database.executeBatch(apb002, 200);
        }
    }

    public override void afterUpdate() {
        List<Attached_Document__c> listAttachedDocGeneralTerms = new List<Attached_Document__c>();
        List<Attached_Document__c> listAttachedDocServiceBooks = new List<Attached_Document__c>();
        
        For(Attached_Document__c attDoc:(List<Attached_Document__c>)Trigger.new){
            if(attDoc.RecordTypeId == rtGeneralTerms){
                listAttachedDocGeneralTerms.add(attDoc);
            }else if(attDoc.RecordTypeId == rtServiceBook){
                listAttachedDocServiceBooks.add(attDoc);
            }
        }
        
        //Add Document link on all related products into Terms and Conditions field
        if(!listAttachedDocGeneralTerms.isEmpty()){
            APB001_InsertTermsLinkToProduct apb001 = new APB001_InsertTermsLinkToProduct(listAttachedDocGeneralTerms);
            Database.executeBatch(apb001, 200);
        }
        
        //Add Document link on all related products into Service Book field
        if(!listAttachedDocServiceBooks.isEmpty()){
            APB002_InsertServiceBookLinkToProduct apb002 = new APB002_InsertServiceBookLinkToProduct(listAttachedDocServiceBooks);
            Database.executeBatch(apb002, 200);
        }
    }

    public override void afterDelete() {
        List<Attached_Document__c> listAttachedDocGeneralTerms = new List<Attached_Document__c>();
        List<Attached_Document__c> listAttachedDocServiceBooks = new List<Attached_Document__c>();
        
        For(Attached_Document__c attDoc:(List<Attached_Document__c>)Trigger.old){
            if(attDoc.RecordTypeId == rtGeneralTerms){
                listAttachedDocGeneralTerms.add(attDoc);
            }else if(attDoc.RecordTypeId == rtServiceBook){
                listAttachedDocServiceBooks.add(attDoc);
            }
        }
        
        //Add Document link on all related products into Terms and Conditions field
        if(!listAttachedDocGeneralTerms.isEmpty()){
            APB001_InsertTermsLinkToProduct apb001 = new APB001_InsertTermsLinkToProduct(listAttachedDocGeneralTerms);
            Database.executeBatch(apb001, 200);
        }
        
        //Add Document link on all related products into Service Book field
        if(!listAttachedDocServiceBooks.isEmpty()){
            APB002_InsertServiceBookLinkToProduct apb002 = new APB002_InsertServiceBookLinkToProduct(listAttachedDocServiceBooks);
            Database.executeBatch(apb002, 200);
        }
    }

}