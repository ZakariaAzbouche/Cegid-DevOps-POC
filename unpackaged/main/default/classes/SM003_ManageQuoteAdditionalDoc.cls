/**
 * @author Shamina M - Comforth
 * @date Creation 08 May 2020
 * @description Service Manager class to create/delete Additional document (SBQQ__RelatedContent__c) 
 *              related to SBQQ__Quote__c (US W-001024)
 *              
*/
public with sharing class SM003_ManageQuoteAdditionalDoc {
    /**
     * @author Shamina M - Comforth
     * @date Creation 08 May 2020
     * @param mapContentDocQuote map contentdoc Id by quote
     * @description Create SBQQ__RelatedContent__c records when PDF files attachments are added to SBQQ__Quote__c 
     *              These additional document can then be linked to quote sent for signture (send to docusign) 
    */
    public static void manageAdditionalDocument(Map<Id,Set<Id>> mapContentDocQuote){
        system.debug(LoggingLevel.DEBUG, 'mapContentDocQuote.size= ' + mapContentDocQuote.size());

        Map<Id,ContentDocument> mapContentDocPDF = new Map<Id,ContentDocument>();
        List<SBQQ__RelatedContent__c> listAdditionalDoc = new List<SBQQ__RelatedContent__c>();
        //check if contentdocument are of type PDF
        //only PDF files can be added quote document sent for signature
        for(ContentDocument contDoc : [SELECT Id, Title, FileExtension 
                                        FROM ContentDocument
                                        WHERE Id IN: mapContentDocQuote.keySet()
                                        AND FileExtension = 'pdf']){
            mapContentDocPDF.put(contDoc.Id, contDoc);                               
        }

        for(Id contDocId : mapContentDocQuote.keySet()){
            for(Id quoteId : mapContentDocQuote.get(contDocId)){
                if(mapContentDocPDF.get(contDocId) != null){
                    listAdditionalDoc.add(new SBQQ__RelatedContent__c(
                        SBQQ__ExternalId__c = contDocId,
                        SBQQ__Quote__c = quoteId,
                        SBQQ__DisplayOrder__c=null, 
                        SBQQ__Required__c = false, 
                        Name=mapContentDocPDF.get(contDocId).Title
                    ));
                }
            }
        }

        //insert additional document for PDF files attached to CQP quote
        if(SBQQ__RelatedContent__c.sObjectType.getDescribe().isCreateable()){
            insert listAdditionalDoc;
        }

    }

    /**
     * @author Shamina M - Comforth
     * @date Creation 08 May 2020
     * @param setContDocId set of contentdoc ids
     * @description If a contentdocument is deleted, check if linked to quote and delete related SBQQ__RelatedContent__c based on external id field 
    */
    public static void deleteAdditionalDocument(Set<Id> setContDocId){
        List<SBQQ__RelatedContent__c> listAddDocToDel = new List<SBQQ__RelatedContent__c>();
        for(SBQQ__RelatedContent__c addDoc : [SELECT SBQQ__ExternalId__c 
                                    FROM SBQQ__RelatedContent__c
                                    WHERE SBQQ__ExternalId__c IN :setContDocId]){
            listAddDocToDel.add(addDoc);                            
        }

        //delete additional document found by SBQQ__ExternalId__c
        if(SBQQ__RelatedContent__c.sObjectType.getDescribe().isDeletable()){
            delete listAddDocToDel;
        }
    }
}