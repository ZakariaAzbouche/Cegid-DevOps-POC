/**
* @author Keshav - Comforth
* @date 2020-06-04
* @modified 2020-06-04
* @group TH_AttachedDocument
* @object Attached Document
* @description 
*/
trigger AttachedDocumentTrigger on Attached_Document__c (after insert, after update, before delete, after delete) {
    
    new TH_AttachedDocument().run();
    
}