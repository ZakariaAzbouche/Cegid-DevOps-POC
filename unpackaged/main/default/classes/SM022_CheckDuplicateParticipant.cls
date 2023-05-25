/**
* @author Keshav - Comforth Karoo
* @date 2021-08-26
* @description Check Duplicate 
*/

public class SM022_CheckDuplicateParticipant {
    
    public static void DuplicateVerification(List<Participant__c> listParticipant){
        set <String> setEmailAdd = new set<String>();
        set <String> setCartId = new set<String>();
        for(Participant__c part:listParticipant){
            setEmailAdd.add(part.CartItemId__c);
        }
        
        List<Participant__c> lisExtPart = [SELECT Id,CartItemId__c,Name,Prenom__c,EmailAddress__c 
                                         FROM Participant__c WHERE CartItemId__c IN:setEmailAdd];
        system.debug('lisExtPart : ' + lisExtPart);
        if(lisExtPart.size()>0){
            set<String> setDuplicateAccProdL = new set<String>();
            for(Participant__c part:lisExtPart){
                setDuplicateAccProdL.add(part.CartItemId__c+'-'+part.EmailAddress__c);
            }
            
            for(Participant__c exii:listParticipant){
                if(setDuplicateAccProdL.contains(exii.CartItemId__c+'-'+exii.EmailAddress__c)){
                    for(Participant__c newPart:listParticipant){
                        newPart.addError('Merci de bien vouloir saisir un e-mail distinct pour chaque participant à une session de formation.');
                    }
                }
            }
        }
        
    }
}