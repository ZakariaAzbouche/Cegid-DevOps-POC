/**
 * @author Shamina M - Comforth
 * @date Creation 08 May 2020
 * @description Custom trigger on ContentDocument
 *              
*/
trigger ContentDocumentTrigger on ContentDocument (after delete) {
    new TH_ContentDocument().run();
}