/**
 * @author Shamina M - Comforth
 * @date Creation 08 May 2020
 * @description ContentDocumentLinkTrigger - Custom trigger on ContentDocumentLink
 *              
*/
trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert, after delete) {
    new TH_ContentDocumentLink().run();
}