/**
 * @author Shamina M - Comforth
 * @date Creation 08 May 2020
 * @description TH_ContentDocumentLink - Handler class for ContentDocumentLinkTrigger
 *              
*/
public with sharing class TH_ContentDocumentLink extends TriggerHandler{
    /**
     * @author Shamina M - Comforth
     * @date Creation 08 May 2020
     * @description afterInsert logic          
    */
    public override void afterInsert() {
        Set<Id> setQuoteIds;
        Map<Id,Set<Id>> mapContentDocQuote = new Map<Id,Set<Id>>();

        for(ContentDocumentLink doc:(List<ContentDocumentLink>)Trigger.New){                            
            //handle auto creation of additional document on related CPQ quote            
            if(canTriggerByFeature('ManageQuoteAdditionalDoc__c')){
                Id docLinkedEntityId = doc.LinkedEntityId;
                if(docLinkedEntityId.getSObjectType() == SBQQ__Quote__c.sObjectType){
                    if((setQuoteIds = mapContentDocQuote.get(doc.ContentDocumentId)) == null){
                        mapContentDocQuote.put(doc.ContentDocumentId, setQuoteIds=new Set<Id>{docLinkedEntityId});
                    }
                    setQuoteIds.add(docLinkedEntityId);               
                }
            }            
        }
        
        if(mapContentDocQuote.size()>0){
            SM003_ManageQuoteAdditionalDoc.manageAdditionalDocument(mapContentDocQuote);
        }       
    }

    /**
     * @author Shamina M - Comforth
     * @date Creation 08 May 2020
     * @description afterDelete logic          
    */
    public override void afterDelete() {
        Set<Id> setContDocId = new Set<Id>();
        for(ContentDocumentLink doc:(List<ContentDocumentLink>)Trigger.old){
            
            if(canTriggerByFeature('ManageQuoteAdditionalDoc__c')){
                setContDocId.add(doc.ContentDocumentId);                  
            }
        }

        //handle deletion of additional document if file is removed from quote record but contentdocument still exist
        if(setContDocId.size()>0){
            SM003_ManageQuoteAdditionalDoc.deleteAdditionalDocument(setContDocId);
        }       
    }

}