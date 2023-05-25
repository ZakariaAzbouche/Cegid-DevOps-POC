/**
 * @author Shamina M - Comforth
 * @date Creation 08 May 2020
 * @description TH_ContentDocument - Handler class for ContentDocumentTrigger
 *              
*/
public with sharing class TH_ContentDocument extends TriggerHandler {
    /**
     * @author Shamina M - Comforth
     * @date Creation 08 May 2020
     * @description afterDelete logic          
    */
    public override void afterDelete() {
        Set<Id> setContDocId = new Set<Id>();
        for(ContentDocument doc:(List<ContentDocument>)Trigger.old){
            
            if(canTriggerByFeature('ManageQuoteAdditionalDoc__c')){
                setContDocId.add(doc.Id);                  
            }
        }

        //handle deletion of additional document if linked to contentdoc deleted
        //No need to handle file name update, since send to docusign shows updated file name
        if(setContDocId.size()>0){
            SM003_ManageQuoteAdditionalDoc.deleteAdditionalDocument(setContDocId);
        }       
    }
}